from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.routes import query_route, history_route, knowledge_route
from backend.config.settings import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    from backend.database.sqlite_client import get_db
    from backend.database.redis_client import get_redis
    from backend.services.llm_factory import get_router_llm, get_agent_llm
    from backend.services.knowledge_service import knowledge_base

    # SQLite
    db = await get_db()
    await db.close()
    print("💾 SQLite ready")

    # Redis (optional)
    try:
        r = await get_redis()
        await r.ping()
        print("📦 Redis ready")
    except Exception:
        print("📦 Redis unavailable (fallback to SQLite)")

    # LLM models
    get_router_llm()
    get_agent_llm()
    print(f"🧠 LLM ready ({settings.LLM_PROVIDER})")

    # ChromaDB
    _ = knowledge_base.vector_db
    print("🔍 ChromaDB ready")

    print("🚀 All services initialized\n")
    yield
    print("👋 Shutting down")


app = FastAPI(
    title="PillBin Agent API",
    description="FastAPI backend for the PillBin medical chatbot.",
    version="3.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(query_route.router, tags=["Query"])
app.include_router(history_route.router, tags=["History"])
app.include_router(knowledge_route.router, tags=["Knowledge"])


@app.get("/health", tags=["Health"])
async def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
