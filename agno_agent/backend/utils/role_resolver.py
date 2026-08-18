import time

import httpx

from backend.config.settings import settings
from backend.utils.logger import logger

_CACHE_TTL = 900
_cache: dict[str, tuple[str, float]] = {}


async def resolve_role(jwt_token: str, claimed_role: str = "user") -> str:
    fallback = "vendor" if (claimed_role or "").strip().lower() == "vendor" else "user"

    if not jwt_token:
        return fallback

    cached = _cache.get(jwt_token)
    if cached and cached[1] > time.time():
        return cached[0]

    try:
        async with httpx.AsyncClient(timeout=5) as client:
            resp = await client.get(
                f"{settings.NODE_JS_BASE_URL}/user/profile",
                headers={"Authorization": f"Bearer {jwt_token}"},
            )
            resp.raise_for_status()
            user = resp.json().get("data", {}).get("user", {})
            role = "vendor" if user.get("role") == "vendor" else "user"

        _cache[jwt_token] = (role, time.time() + _CACHE_TTL)

        if role != fallback:
            logger.warning(
                f"  ⚠️  role mismatch — client claimed '{fallback}', server says '{role}'"
            )

        return role
    except Exception as e:
        logger.warning(f"  ⚠️  role lookup failed ({e}), using claimed role '{fallback}'")
        return fallback
