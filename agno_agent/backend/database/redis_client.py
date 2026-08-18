import redis.asyncio as redis
from backend.config.settings import settings

_redis: redis.Redis = None


async def get_redis() -> redis.Redis:
    global _redis
    if _redis is None:
        _redis = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,
            socket_connect_timeout=1,  # fail fast if unavailable
            socket_timeout=1,
        )
    return _redis
