from typing import Any, Optional

import httpx

from backend.config.settings import settings
from backend.utils.logger import log_error

_client: Optional[httpx.AsyncClient] = None


def is_enabled() -> bool:
    return settings.JEV_ENABLED and bool(settings.JEV_API_KEY)


def _get_client() -> httpx.AsyncClient:
    global _client
    if _client is None:
        _client = httpx.AsyncClient(
            base_url=settings.JEV_BASE_URL.rstrip("/"),
            timeout=settings.JEV_TIMEOUT,
            headers={"Authorization": f"Bearer {settings.JEV_API_KEY}"},
        )
    return _client


async def evaluate(state: str, questions: dict) -> Optional[dict[str, Any]]:
    if not is_enabled():
        return None

    try:
        response = await _get_client().post(
            "/v1/evaluate",
            json={"model": settings.JEV_MODEL, "state": state, "questions": questions},
        )
    except httpx.HTTPError as e:
        log_error("jev", f"{type(e).__name__}: {e}")
        return None

    if response.status_code != 200:
        log_error("jev", f"HTTP {response.status_code}: {response.text[:200]}")
        return None

    try:
        data = response.json()
    except ValueError:
        log_error("jev", "response was not JSON")
        return None

    answers = data.get("answers", data) if isinstance(data, dict) else None
    if not isinstance(answers, dict):
        log_error("jev", "response had no answers")
        return None
    return answers


def boolean_probability(answer: Any) -> Optional[float]:
    if not isinstance(answer, dict):
        return None
    value = answer.get("probability", answer.get("noul"))
    return float(value) if isinstance(value, (int, float)) else None


def top_choice(answer: Any) -> tuple[Optional[str], float]:
    if not isinstance(answer, dict):
        return None, 0.0
    choice = answer.get("choice")
    probabilities = answer.get("probabilities") or {}
    probability = probabilities.get(choice) if isinstance(probabilities, dict) else None
    if not isinstance(choice, str) or not isinstance(probability, (int, float)):
        return None, 0.0
    return choice, float(probability)
