import aiosqlite
from backend.config.settings import settings

_db_path: str = None

def _get_path() -> str:
    global _db_path
    if _db_path is None:
        _db_path = settings.SQLITE_PATH
    return _db_path


async def get_db() -> aiosqlite.Connection:
    db = await aiosqlite.connect(_get_path())
    db.row_factory = aiosqlite.Row
    await db.execute("""
        CREATE TABLE IF NOT EXISTS chat_history (
            id TEXT PRIMARY KEY,
            token TEXT NOT NULL,
            role TEXT NOT NULL,
            message TEXT NOT NULL,
            timestamp TEXT NOT NULL
        )
    """)
    await db.execute("""
        CREATE INDEX IF NOT EXISTS idx_chat_token ON chat_history(token)
    """)
    await db.commit()
    return db
