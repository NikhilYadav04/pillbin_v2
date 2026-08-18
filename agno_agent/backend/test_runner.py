"""
PillBin Agent — API Test Runner
Run: python -m backend.test_runner
Requires server running on port 8000
"""
import asyncio
import time
import json
import sys
import os

import httpx

BASE_URL = "http://localhost:8000"


class C:
    BOLD = "\033[1m"
    DIM = "\033[2m"
    GREEN = "\033[92m"
    CYAN = "\033[96m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    MAGENTA = "\033[95m"
    BLUE = "\033[94m"
    WHITE = "\033[97m"
    RESET = "\033[0m"


ICONS = {
    "pass": "✅", "fail": "❌", "warn": "⚠️", "rocket": "🚀",
    "brain": "🧠", "bolt": "⚡", "db": "💾", "cache": "📦",
    "search": "🔍", "doc": "📄", "trash": "🗑️", "globe": "🌐",
    "key": "🔑", "clock": "⏱️",
}


def header(text):
    w = 62
    print(f"\n{C.CYAN}{C.BOLD}{'━' * w}")
    print(f"  {text}")
    print(f"{'━' * w}{C.RESET}")


def sub_header(text):
    print(f"\n  {C.BLUE}{C.BOLD}▸ {text}{C.RESET}")


def ok(label, detail=""):
    d = f" {C.DIM}→ {detail}{C.RESET}" if detail else ""
    print(f"    {ICONS['pass']}  {C.GREEN}{label}{C.RESET}{d}")


def fail(label, detail=""):
    d = f" {C.DIM}→ {detail}{C.RESET}" if detail else ""
    print(f"    {ICONS['fail']}  {C.RED}{label}{C.RESET}{d}")


def warn(label, detail=""):
    d = f" {C.DIM}→ {detail}{C.RESET}" if detail else ""
    print(f"    {ICONS['warn']}  {C.YELLOW}{label}{C.RESET}{d}")


def info(label, detail=""):
    d = f" {C.DIM}→ {detail}{C.RESET}" if detail else ""
    print(f"         {C.DIM}{label}{C.RESET}{d}")


def t_str(elapsed):
    return f"{elapsed*1000:.0f}ms" if elapsed < 1 else f"{elapsed:.2f}s"


def show_architecture():
    header(f"{ICONS['rocket']} PillBin Agent v3.0 — API Test Runner")
    print(f"""
  {C.DIM}┌─────────────────────────────────────────────────────────┐
  │                    ARCHITECTURE                        │
  │                                                        │
  │  Test Runner (httpx)                                   │
  │      │                                                 │
  │      ▼                                                 │
  │  {C.CYAN}POST /query{C.DIM} ──▶ {C.YELLOW}Redis{C.DIM} (cache) ──▶ {C.GREEN}SQLite{C.DIM} (fallback) │
  │      │                                                 │
  │      ▼                                                 │
  │  {C.MAGENTA}Intent Router{C.DIM} (lightweight LLM)                     │
  │      │                                                 │
  │      ├── history   → answer from context (0 calls)     │
  │      ├── inventory → Inventory Agent + HTTP tools      │
  │      ├── directory → Directory Agent + HTTP tools      │
  │      ├── knowledge → {C.YELLOW}Knowledge Agent + ChromaDB{C.DIM}        │
  │      └── general   → General Agent + Web Search        │
  │                                                        │
  │  {C.BOLD}Data Stores:{C.DIM}                                           │
  │    {C.YELLOW}ChromaDB{C.DIM} (hybrid search) │ {C.GREEN}SQLite{C.DIM} (chat) │ {C.YELLOW}Redis{C.DIM}    │
  └─────────────────────────────────────────────────────────┘{C.RESET}
""")


def parse_response(resp):
    """Parse API response and display it."""
    if resp.status_code != 200:
        fail(f"HTTP {resp.status_code}", resp.text[:100])
        return None
    try:
        data = resp.json()
        msg = data.get("message", "")[:120]
        msg_display = msg + ("..." if len(data.get("message", "")) > 120 else "")
        info("Message", msg_display)
        info("isTable", str(data.get("isTable", False)))
        info("Confidence", str(data.get("confidence", "?")))
        if data.get("isTable") and data.get("tableColumns"):
            info("Columns", str(data["tableColumns"]))
            rows = data.get("tableRows", [])
            info("Rows", f"{len(rows)} rows")
        return data
    except Exception as e:
        fail("Parse error", str(e)[:80])
        return None


async def run_all():
    show_architecture()

    token = "test_runner_user"

    async with httpx.AsyncClient(timeout=90.0) as client:

        # ── 1. Health ──
        header(f"{ICONS['bolt']} Infrastructure")

        sub_header("Health Check")
        t = time.time()
        try:
            resp = await client.get(f"{BASE_URL}/health")
            if resp.status_code == 200:
                ok("Server healthy", t_str(time.time() - t))
            else:
                fail(f"Server error: {resp.status_code}")
                return
        except httpx.ConnectError:
            fail("Server not running")
            print(f"\n    {C.DIM}Start with: uvicorn backend.main:app --port 8000{C.RESET}\n")
            return

        # ── 2. General Query (DuckDuckGo) ──
        header(f"{ICONS['brain']} Agent Pipeline Tests")

        sub_header("Test 1: General Query (Web Search)")
        print(f"    {C.WHITE}{ICONS['search']} \"What is paracetamol used for?\"{C.RESET}")
        t = time.time()
        resp = await client.post(f"{BASE_URL}/query", data={
            "token": token,
            "user_message": "What is paracetamol used for?",
        })
        elapsed = time.time() - t
        ok(f"Response in {t_str(elapsed)}")
        parse_response(resp)

        # ── 3. Directory Query ──
        sub_header("Test 2: Directory Query (Facility Search)")
        print(f"    {C.WHITE}{ICONS['search']} \"Find hospitals near me\"{C.RESET}")
        t = time.time()
        resp = await client.post(f"{BASE_URL}/query", data={
            "token": token,
            "user_message": "Find hospitals near me",
            "latitude": "19.076",
            "longitude": "72.877",
        })
        elapsed = time.time() - t
        ok(f"Response in {t_str(elapsed)}")
        parse_response(resp)

        # ── 4. Inventory Query (needs JWT) ──
        sub_header("Test 3: Inventory Query (with JWT)")
        jwt = os.getenv("TEST_JWT", "")
        if jwt:
            print(f"    {C.WHITE}{ICONS['search']} \"Show my active medicines\"{C.RESET}")
            t = time.time()
            resp = await client.post(f"{BASE_URL}/query",
                data={"token": token, "user_message": "Show my active medicines"},
                headers={"Authorization": f"Bearer {jwt}"},
            )
            elapsed = time.time() - t
            ok(f"Response in {t_str(elapsed)}")
            parse_response(resp)
        else:
            warn("Skipped (no TEST_JWT env var)", "Set TEST_JWT to test inventory")

        # ── 5. Follow-up (History) ──
        sub_header("Test 4: Follow-up (Should use History)")
        print(f"    {C.WHITE}{ICONS['search']} \"Tell me more about that\"{C.RESET}")
        t = time.time()
        resp = await client.post(f"{BASE_URL}/query", data={
            "token": token,
            "user_message": "Tell me more about what you just said",
        })
        elapsed = time.time() - t
        ok(f"Response in {t_str(elapsed)}")
        parse_response(resp)

        # ── 6. History API ──
        header(f"{ICONS['db']} History API")

        sub_header("GET /history")
        t = time.time()
        resp = await client.get(f"{BASE_URL}/history", params={"token": token})
        elapsed = time.time() - t
        if resp.status_code == 200:
            data = resp.json()
            count = len(data.get("history", []))
            total = data.get("pagination", {}).get("total", 0)
            ok(f"Fetched {count} messages (total: {total})", t_str(elapsed))
        else:
            fail(f"HTTP {resp.status_code}")

        # ── 7. Cleanup ──
        header(f"{ICONS['trash']} Cleanup")
        resp = await client.delete(f"{BASE_URL}/history", params={"token": token})
        if resp.status_code == 200:
            ok("Test history cleared")
        else:
            fail(f"Cleanup failed: {resp.status_code}")

    # ── Summary ──
    header(f"{ICONS['pass']} All Tests Complete")
    print(f"    {C.DIM}Tests ran against {BASE_URL}")
    print(f"    For inventory tests, set: $env:TEST_JWT=\"your_jwt_here\"{C.RESET}\n")


if __name__ == "__main__":
    asyncio.run(run_all())
