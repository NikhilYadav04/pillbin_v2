import asyncio
import sys
import uuid
import json

sys.path.insert(0, "n:/Dev/Agno")

from backend.main import app
from fastapi.testclient import TestClient
from backend.database.chat_repository import fetch_recent


async def run_test():
    client = TestClient(app)
    test_token = f"test_user_{uuid.uuid4()}"

    print(f"Testing with token: {test_token}")

    response = client.post(
        "/query",
        data={
            "token": test_token,
            "user_message": "Hello! Just testing the system. Reply with 'hi'."
        }
    )

    print(f"Status Code: {response.status_code}")
    print(f"Response text raw: \n{response.text}\n---\n")

    lines = response.text.replace("\r", "").split("\n")

    parsed_id = None
    for line in lines:
        if '"id"' in line and "{" in line:
            try:
                start = line.find('{')
                end = line.rfind('}') + 1
                if start != -1 and end != 0:
                    obj = json.loads(line[start:end])
                    if "id" in obj:
                        parsed_id = obj["id"]
                        print(f"Found ID in response stream JSON: {parsed_id}")
            except Exception:
                pass

    recent = await fetch_recent(test_token, limit=10)
    print(f"Recent from DB: {len(recent)} messages")
    for msg in recent:
        print(f"Role: {msg.get('role')} | MsgID: {msg.get('id')} | Msg: {msg.get('message')[:50]}")

    if parsed_id:
        db_has_it = any(msg.get('id') == parsed_id for msg in recent)
        if db_has_it:
            print("SUCCESS: The message ID returned in the JSON matches the database!")
        else:
            print("FAILURE: database does not contain the returned ID")
    else:
        print("COULD NOT FIND ID IN STREAM.")

if __name__ == "__main__":
    asyncio.run(run_test())
