from fastapi import APIRouter, HTTPException, Query
from backend.services import knowledge_service

router = APIRouter()


@router.delete("/knowledge")
async def clear_knowledge(token: str = Query(..., description="User token")):
    if not token or not token.strip():
        raise HTTPException(status_code=400, detail="token is required.")
    try:
        await knowledge_service.clear_user_documents(token)
        return {"status": "success", "message": "Knowledge base cleared."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to clear knowledge: {e}")
