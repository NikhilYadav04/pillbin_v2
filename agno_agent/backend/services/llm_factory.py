from agno.models.base import Model
from backend.config.settings import settings

_router_llm: Model | None = None
_agent_llm: Model | None = None


def _create_model(model_id: str) -> Model:
    provider = settings.LLM_PROVIDER.lower()
    if provider == "groq":
        from agno.models.groq import Groq
        return Groq(id=model_id, api_key=settings.GROQ_API_KEY)
    else:
        from agno.models.google import Gemini
        return Gemini(id=model_id, api_key=settings.GEMINI_API_KEY)


def get_router_llm() -> Model:
    """Lightweight model for intent classification."""
    global _router_llm
    if _router_llm is None:
        provider = settings.LLM_PROVIDER.lower()
        model_id = (
            settings.GROQ_ROUTER_MODEL if provider == "groq"
            else settings.GEMINI_ROUTER_MODEL
        )
        _router_llm = _create_model(model_id)
    return _router_llm


def get_agent_llm() -> Model:
    """Capable model for agent execution."""
    global _agent_llm
    if _agent_llm is None:
        provider = settings.LLM_PROVIDER.lower()
        model_id = (
            settings.GROQ_AGENT_MODEL if provider == "groq"
            else settings.GEMINI_AGENT_MODEL
        )
        _agent_llm = _create_model(model_id)
    return _agent_llm
