from fastapi import APIRouter, HTTPException, Query
from backend.database import chat_repository

router = APIRouter()


@router.get("/history")
async def get_history(
    token: str = Query(..., description="User token"),
    page: int = Query(1, ge=1),
    limit: int = Query(40, ge=1, le=100),
):
    if not token or not token.strip():
        raise HTTPException(status_code=400, detail="token is required.")
    try:
        result = await chat_repository.fetch_all(token, page, limit)
        total_pages = (result["total"] + limit - 1) // limit if result["total"] > 0 else 0
        return {
            "token": token,
            "history": result["data"],
            "pagination": {
                "page": page,
                "limit": limit,
                "total": result["total"],
                "totalPages": total_pages,
                "hasMore": page < total_pages,
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch history: {e}")


@router.delete("/history")
async def clear_history(token: str = Query(..., description="User token")):
    if not token or not token.strip():
        raise HTTPException(status_code=400, detail="token is required.")
    try:
        await chat_repository.delete_all(token)
        return {"status": "success", "message": "History cleared."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to clear history: {e}")
