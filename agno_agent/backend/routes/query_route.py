import time
import uuid
from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, Header, UploadFile

from backend.database import chat_repository
from backend.services import agent_service, knowledge_service
from backend.utils.role_resolver import resolve_role
from backend.utils.logger import (
    logger, Timer,
    set_request_id, log_request, log_history, log_save, log_error
)

router = APIRouter()


@router.post("/query")
async def query(
    authorization: Optional[str] = Header(None),
    token: str = Form(...),
    user_message: str = Form(...),
    latitude: str = Form(""),
    longitude: str = Form(""),
    role: str = Form("user"),
    file: Optional[UploadFile] = File(None),
):
    if not token or not token.strip():
        raise HTTPException(status_code=400, detail="token is required.")
    if not user_message or not user_message.strip():
        raise HTTPException(status_code=400, detail="user_message is required.")

    # Set per-request trace ID
    rid = str(uuid.uuid4())[:8]
    set_request_id(rid)
    log_request(token, user_message)

    # Index uploaded PDF if present
    if file and file.filename:
        try:
            file_bytes = await file.read()
            logger.info(f"  📄 Indexing: {file.filename} ({len(file_bytes)//1024}KB)")
            await knowledge_service.index_document(file_bytes, file.filename, token)
            logger.info(f"     ✅ Indexed into ChromaDB")
        except Exception as e:
            log_error("index", str(e))

    # Fetch history
    t = Timer()
    try:
        recent_history = await chat_repository.fetch_recent(token, limit=10)
        import time as _time
        elapsed_ms = (time.perf_counter() - t._start) * 1000
        source = "Redis" if elapsed_ms < 5 else "SQLite"
        log_history(len(recent_history), source, t.elapsed())
    except Exception as e:
        log_error("history_fetch", str(e))
        raise HTTPException(status_code=500, detail=f"Failed to fetch history: {e}")

    user_msg_id = str(uuid.uuid4())
    agent_msg_id = str(uuid.uuid4())

    jwt_token = ""
    if authorization and authorization.startswith("Bearer "):
        jwt_token = authorization.split("Bearer ")[1]

    verified_role = await resolve_role(jwt_token, role)

    result = await agent_service.get_agent_response(
        token, user_message, recent_history,
        agent_msg_id, jwt_token, latitude, longitude,
        role=verified_role,
    )

    # Save to DB
    t = Timer()
    try:
        await chat_repository.insert_message(token, "user", user_message, message_id=user_msg_id)
        await chat_repository.insert_message(token, "agent", result.model_dump_json(), message_id=agent_msg_id)
        log_save(t.elapsed())
    except Exception as e:
        log_error("save", str(e))

    logger.info(f"\033[2m{'─' * 52}\033[0m")
    return result.model_dump()
