from fastapi import FastAPI, HTTPException
from datetime import datetime, date
from app.config1.redis_client import redis_client

app = FastAPI()

PDF_LIMIT = 2

QUERY_LIMIT = 10

# reset limits if not today


async def reset_if_new_day(user_id: str):
    updated_key = f"user:{user_id}:updated_at"
    pdf_key = f"user:{user_id}:pdf_count"
    query_key = f"query:{user_id}:query_count"

    last_updated = await redis_client.get(updated_key)

    today = date.today()

    if last_updated:
        last_date = datetime.fromisoformat(last_updated).date()

        # If not today → reset counts
        if last_date != today:
            await redis_client.delete(pdf_key)
            await redis_client.delete(query_key)
    else:
        # First time user → no previous date
        pass


# check pdf upload limit
async def check_upload_count(user_id: str):
    pdf_key = f"user:{user_id}:pdf_count"
    updated_key = f"user:{user_id}:updated_at"

    # Reset if day changed
    await reset_if_new_day(user_id)

    count = await redis_client.incr(pdf_key)

    if count > PDF_LIMIT:
        return False

    await redis_client.set(updated_key, datetime.utcnow().isoformat())

    return True


# check query limit
async def check_query_count(user_id: str):
    query_key = f"query:{user_id}:query_count"
    updated_key = f"user:{user_id}:updated_at"

    #  Reset if day changed
    await reset_if_new_day(user_id)

    count = await redis_client.incr(query_key)

    if count > QUERY_LIMIT:
        return False

    await redis_client.set(updated_key, datetime.utcnow().isoformat())

    return True
