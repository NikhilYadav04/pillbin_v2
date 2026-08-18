import asyncio
import httpx
import json

BASE_URL = "http://localhost:8000"


async def run_tests():
    token = "test_user_123"
    print(f"=== Starting API Tests using token: {token} ===\n")

    async with httpx.AsyncClient(timeout=60.0) as client:
        # 1. Health Check
        print("1. Testing GET /health ...")
        res = await client.get(f"{BASE_URL}/health")
        print(f"Status: {res.status_code} | Body: {res.text}\n")

        # 2. Query
        print("2. Testing POST /query ...")
        res = await client.post(
            f"{BASE_URL}/query",
            data={
                "token": token,
                "user_message": "Hello! Please reply with exactly 'hi'.",
            },
        )
        print(f"Status: {res.status_code}")

        parsed_id = None
        for line in res.text.replace("\r", "").split("\n"):
            if '"id"' in line and "{" in line:
                try:
                    start = line.find("{")
                    end = line.rfind("}") + 1
                    if start != -1 and end != 0:
                        parsed_id = json.loads(line[start:end]).get("id")
                except Exception:
                    pass
        print(f"Stream output captured. Agent Message ID: {parsed_id}\n")

        # 3. Get History
        print("3. Testing GET /history ...")
        res = await client.get(f"{BASE_URL}/history", params={"token": token})
        print(f"Status: {res.status_code}")
        history_cnt = len(res.json().get("history", []))
        print(f"Total messages in history: {history_cnt}\n")

        # 4. Clear History
        print("4. Testing DELETE /history ...")
        res = await client.delete(f"{BASE_URL}/history", params={"token": token})
        print(f"Status: {res.status_code} | Body: {res.text}\n")

        # 5. Verify History Cleared
        print("5. Verifying History is empty ...")
        res = await client.get(f"{BASE_URL}/history", params={"token": token})
        print(
            f"Status: {res.status_code} | History Length: {len(res.json().get('history', []))}\n"
        )

    print("=== All Tests Completed ===")


if __name__ == "__main__":
    asyncio.run(run_tests())
