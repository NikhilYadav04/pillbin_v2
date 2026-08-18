import json
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List

from backend.config.settings import settings
from backend.database.sqlite_client import get_db
from backend.database.redis_client import get_redis

TABLE = "chat_history"
REDIS_KEY_PREFIX = "chat:"


def _redis_key(token: str) -> str:
    return f"{REDIS_KEY_PREFIX}{token}"


async def insert_message(
    token: str, role: str, message: str, message_id: str = None
) -> None:
    msg_id = message_id or str(uuid.uuid4())
    ts = datetime.now(timezone.utc).isoformat()
    data = {"id": msg_id, "role": role, "message": message, "timestamp": ts}

    # Redis (best-effort)
    try:
        r = await get_redis()
        key = _redis_key(token)
        await r.rpush(key, json.dumps(data))
        await r.ltrim(key, -settings.REDIS_MAX_MESSAGES, -1)
        await r.expire(key, settings.REDIS_HISTORY_TTL)
    except Exception as e:
        print(f"[Redis write skip]: {e}")

    # SQLite (source of truth)
    db = await get_db()
    await db.execute(
        f"INSERT INTO {TABLE} (id, token, role, message, timestamp) VALUES (?, ?, ?, ?, ?)",
        (msg_id, token, role, message, ts),
    )
    await db.commit()
    await db.close()


async def fetch_recent(token: str, limit: int = 10) -> List[Dict[str, Any]]:
    # Redis first
    try:
        r = await get_redis()
        key = _redis_key(token)
        cached = await r.lrange(key, -limit, -1)
        if cached:
            return [json.loads(msg) for msg in cached]
    except Exception as e:
        print(f"[Redis read skip]: {e}")

    # SQLite fallback
    db = await get_db()
    cursor = await db.execute(
        f"SELECT id, role, message, timestamp FROM {TABLE} WHERE token = ? ORDER BY timestamp DESC LIMIT ?",
        (token, limit),
    )
    rows = await cursor.fetchall()
    await db.close()
    messages = [dict(row) for row in reversed(rows)]

    # Warm Redis
    if messages:
        try:
            r = await get_redis()
            key = _redis_key(token)
            pipe = r.pipeline()
            await pipe.delete(key)
            for msg in messages:
                await pipe.rpush(key, json.dumps(msg))
            await pipe.expire(key, settings.REDIS_HISTORY_TTL)
            await pipe.execute()
        except Exception:
            pass

    return messages


async def fetch_all(token: str, page: int = 1, limit: int = 20) -> Dict[str, Any]:
    db = await get_db()
    offset = (page - 1) * limit

    cursor = await db.execute(
        f"SELECT COUNT(*) as cnt FROM {TABLE} WHERE token = ?", (token,)
    )
    row = await cursor.fetchone()
    total = row["cnt"] if row else 0

    cursor = await db.execute(
        f"SELECT id, role, message, timestamp FROM {TABLE} WHERE token = ? ORDER BY timestamp DESC LIMIT ? OFFSET ?",
        (token, limit, offset),
    )
    rows = await cursor.fetchall()
    await db.close()

    return {"data": [dict(r) for r in reversed(rows)], "total": total}


async def delete_all(token: str) -> None:
    # Clear Redis
    try:
        r = await get_redis()
        await r.delete(_redis_key(token))
    except Exception:
        pass

    # Clear SQLite
    db = await get_db()
    await db.execute(f"DELETE FROM {TABLE} WHERE token = ?", (token,))
    await db.commit()
    await db.close()
