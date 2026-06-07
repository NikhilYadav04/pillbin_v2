from agno.agent import Agent
from backend.services.agents.llm_factory import get_fast_llm

# MCP tool names that belong to this agent's domain
INVENTORY_TOOL_NAMES = {
    "get_medicines",
    "get_inventory_summary_stats",
    "get_expiry_analytics",
    "check_medicine_stock",
    "get_deleted_medicine_history",
}


def build_inventory_agent(mcp_tools, token: str) -> Agent:
    """
    Inventory & Health Agent — handles private, authenticated user data
    via the PillBin MCP server. Uses the cheap fast model.
    """
    return Agent(
        name="Inventory Agent",
        role="Fetch and analyze personal prescriptions, inventory stats, and medication expiry data via MCP.",
        model=get_fast_llm(),
        tools=[mcp_tools],
        tool_call_limit=2,
        retries=1,
        instructions=(
        f"""<auth>
JWT: {token} — pass this as `token` to every MCP tool call. Never ask for it.
</auth>

<tools>
- get_medicines           → list active / expiring_soon / expired medicines
- get_inventory_summary_stats → counts and totals across all statuses
- get_expiry_analytics    → medicines expiring before a given date (YYYY-MM-DD)
- check_medicine_stock    → check if specific medicine names exist in stock or history
- get_deleted_medicine_history → history of removed medicines
</tools>

<rules>
- Always fetch from MCP. Never fabricate data.
- Return data clearly and accurately.
- Do NOT use directory or facility tools — those belong to the Directory Agent.
</rules>"""
        ),
    )
