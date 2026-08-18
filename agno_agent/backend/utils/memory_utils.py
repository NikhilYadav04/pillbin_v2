import json
from typing import List, Dict, Any


def _unwrap(message: str) -> str:
    """Agent rows are stored as serialized Output; show the prose to the LLM."""
    if not message.startswith("{"):
        return message
    try:
        payload = json.loads(message)
    except (ValueError, TypeError):
        return message
    if not isinstance(payload, dict) or "message" not in payload:
        return message

    text = str(payload.get("message", ""))
    columns = payload.get("tableColumns")
    rows = payload.get("tableRows")
    if payload.get("isTable") and columns and rows:
        header = " | ".join(str(c) for c in columns)
        body = "\n".join(" | ".join(str(c) for c in row) for row in rows)
        text = f"{text}\n{header}\n{body}"
    return text


def format_history_for_agent(history: List[Dict[str, Any]]) -> str:
    """
    Converts a list of chat_history rows into a readable
    conversation block to inject into the agent's instructions.

    Example output:
        User: What are my medicines?
        Agent: Based on your records, you are taking...
    """
    lines = []
    for entry in history:
        role = entry.get("role", "user").capitalize()
        message = _unwrap(entry.get("message", "")).strip()
        lines.append(f"{role}: {message}")
    return "\n".join(lines)


def prune_context_string(context: str, max_chars: int = 8000) -> str:
    """
    Ensures the context string doesn't exceed max_chars.
    If it does, it truncates from the start (keeps most recent content).
    """
    if len(context) <= max_chars:
        return context
    return "[...earlier context trimmed...]\n" + context[-max_chars:]
