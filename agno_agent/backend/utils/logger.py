import logging
import sys
import time
from contextvars import ContextVar

# Per-request trace ID
_request_id: ContextVar[str] = ContextVar("request_id", default="-")


def get_request_id() -> str:
    return _request_id.get()


def set_request_id(rid: str):
    _request_id.set(rid)


class TraceFormatter(logging.Formatter):
    COLORS = {
        "DEBUG":    "\033[2m",      # dim
        "INFO":     "\033[97m",     # white
        "WARNING":  "\033[93m",     # yellow
        "ERROR":    "\033[91m",     # red
        "CRITICAL": "\033[91;1m",   # bold red
    }
    ICONS = {
        "DEBUG":    "·",
        "INFO":     "│",
        "WARNING":  "⚠",
        "ERROR":    "✗",
        "CRITICAL": "✗",
    }
    RESET = "\033[0m"
    DIM = "\033[2m"
    CYAN = "\033[96m"
    MAGENTA = "\033[95m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"

    def format(self, record: logging.LogRecord) -> str:
        color = self.COLORS.get(record.levelname, "")
        icon = self.ICONS.get(record.levelname, "│")
        rid = _request_id.get()
        rid_str = f"{self.DIM}[{rid[:8]}]{self.RESET} " if rid != "-" else ""
        msg = record.getMessage()
        return f"{color}{icon}{self.RESET} {rid_str}{msg}"


def _setup_logger() -> logging.Logger:
    logger = logging.getLogger("pillbin")
    if logger.handlers:
        return logger

    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(TraceFormatter())
    logger.addHandler(handler)
    logger.propagate = False
    return logger


logger = _setup_logger()


# ── Trace helpers ─────────────────────────────────────────────

class Timer:
    def __init__(self):
        self._start = time.perf_counter()

    def elapsed(self) -> str:
        ms = (time.perf_counter() - self._start) * 1000
        return f"{ms:.0f}ms" if ms < 1000 else f"{ms/1000:.2f}s"


def log_request(token: str, message: str):
    logger.info(f"\033[96m━━ NEW REQUEST ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m")
    logger.info(f"  \033[1mToken:\033[0m  {token[:12]}...")
    logger.info(f"  \033[1mQuery:\033[0m  {message[:80]}{'...' if len(message) > 80 else ''}")


def log_history(count: int, source: str, elapsed: str):
    src_color = "\033[92m" if source == "Redis" else "\033[94m"
    logger.info(f"  \033[2m💾 History:\033[0m {count} msgs {src_color}({source})\033[0m \033[2m{elapsed}\033[0m")


def log_intent(intent: str, raw: str, elapsed: str):
    color = {
        "inventory": "\033[93m",
        "directory": "\033[94m",
        "knowledge": "\033[95m",
        "general":   "\033[96m",
        "history":   "\033[92m",
    }.get(intent, "\033[97m")
    logger.info(f"  \033[2m🎯 Intent:\033[0m  {color}{intent.upper()}\033[0m \033[2m({elapsed})\033[0m")
    if raw and raw.strip().lower() != intent:
        logger.debug(f"     raw → \"{raw[:60]}\"")


def log_agent_start(agent_name: str):
    logger.info(f"  \033[2m🧠 Agent:\033[0m   {agent_name}")


def log_tool_call(tool_name: str, detail: str = ""):
    d = f" \033[2m→ {detail}\033[0m" if detail else ""
    logger.info(f"  \033[2m🔧 Tool:\033[0m    {tool_name}{d}")


def log_response(message: str, is_table: bool, confidence: float, elapsed: str):
    preview = message[:80] + ("..." if len(message) > 80 else "")
    logger.info(f"  \033[2m✅ Response:\033[0m\033[92m {elapsed}\033[0m")
    logger.info(f"     \033[2mmsg:\033[0m       {preview}")
    logger.info(f"     \033[2misTable:\033[0m   {is_table} │ confidence: {confidence}")


def log_save(elapsed: str):
    logger.info(f"  \033[2m💾 Saved:\033[0m   Redis + SQLite \033[2m{elapsed}\033[0m")


def log_error(stage: str, error: str):
    logger.error(f"  ✗ [{stage}] {error}")
