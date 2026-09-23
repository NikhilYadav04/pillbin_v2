import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    NODE_JS_BASE_URL: str = os.getenv(
        "NODE_JS_BASE_URL", "https://pillbin-v2.onrender.com/api"
    )
    HISTORY_CONTEXT_LIMIT: int = 5
    CORS_ORIGINS: list[str] = os.getenv(
        "CORS_ORIGINS", "http://localhost:3000"
    ).split()

    # LLM Provider: "gemini" or "groq"
    LLM_PROVIDER: str = os.getenv("LLM_PROVIDER", "gemini")

    # Gemini
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_ROUTER_MODEL: str = os.getenv("GEMINI_ROUTER_MODEL", "gemini-2.0-flash-lite")
    GEMINI_AGENT_MODEL: str = os.getenv("GEMINI_AGENT_MODEL", "gemini-2.5-flash")

    # Groq
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY", "")
    GROQ_ROUTER_MODEL: str = os.getenv("GROQ_ROUTER_MODEL", "llama-3.1-8b-instant")
    GROQ_AGENT_MODEL: str = os.getenv("GROQ_AGENT_MODEL", "llama-3.3-70b-versatile")

    # Jev (TypeSafe) via Vercel AI Gateway
    JEV_ENABLED: bool = os.getenv("JEV_ENABLED", "false").strip().lower() == "true"
    JEV_API_KEY: str = os.getenv("JEV_API_KEY", "")
    JEV_BASE_URL: str = os.getenv("JEV_BASE_URL", "https://ai-gateway.vercel.sh")
    JEV_MODEL: str = os.getenv("JEV_MODEL", "typesafe-ai/jev")
    JEV_TIMEOUT: float = float(os.getenv("JEV_TIMEOUT", "2"))

    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    REDIS_HISTORY_TTL: int = 86400
    REDIS_MAX_MESSAGES: int = 20

    # SQLite
    SQLITE_PATH: str = os.getenv("SQLITE_PATH", "tmp/pillbin.db")

    # ChromaDB
    CHROMA_PATH: str = os.getenv("CHROMA_PATH", "tmp/chromadb")
    CHROMA_COLLECTION: str = os.getenv("CHROMA_COLLECTION", "pillbin_docs")
    CHUNK_SIZE: int = 1500
    CHUNK_OVERLAP: int = 200


settings = Settings()
