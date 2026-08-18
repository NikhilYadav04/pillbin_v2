import asyncio
import traceback
import time
from typing import Any, Dict, List, Optional

from agno.agent import Agent
from agno.tools.websearch import WebSearchTools

from backend.models.output_schema import Output
from backend.services.llm_factory import get_router_llm, get_agent_llm
from backend.services.knowledge_service import knowledge_base
from backend.tools.inventory_tools import InventoryTools
from backend.tools.directory_tools import DirectoryTools
from backend.tools.donation_tools import UserDonationTools, VendorRequestTools
from backend.tools.vendor_tools import VendorCenterTools
from backend.tools.notification_tools import NotificationTools
from backend.utils.memory_utils import format_history_for_agent, prune_context_string
from backend.utils.logger import (
    logger,
    Timer,
    log_intent,
    log_agent_start,
    log_tool_call,
    log_response,
    log_error,
)

USER_ROUTER_INSTRUCTIONS = """
You are an intent classifier for a medical chatbot called PillBot.
You are serving a PATIENT/DONOR user.
You receive the user's query and recent conversation history.

STEP 1: Check if the conversation history already contains enough information to fully answer the query.
- If YES → respond with: history: <your answer here>
- If NO → proceed to Step 2.

STEP 2: Classify the query into exactly one category:
- inventory → medicines, prescriptions, expiry, stock, medication, deleted meds
- directory → nearby hospitals, clinics, pharmacies, medical centers, facilities
- donations → THEIR OWN donation requests they submitted, donation status, approvals, pickups
- notifications → their alerts, notifications, unread messages, 'what did I miss'
- knowledge → user's OWN uploaded documents, personal reports, lab results, test results, 'my report', 'my document'
- general → medical questions, symptoms, drug info, health advice, greetings, anything else (answered via live web search)

RULES:
- NEVER use history for inventory, directory, donations, notifications, or knowledge queries. These always need fresh data from tools. Only use history for conversational follow-ups like "tell me more", "explain that", "what did I ask before".
- If the query is a follow-up referencing previous conversation ("tell me more", "what about the expired ones", "explain that"), check history FIRST.
- Respond with ONLY the category name OR history: <answer>.
- Never add explanation.
"""

VENDOR_ROUTER_INSTRUCTIONS = """
You are an intent classifier for PillBot, serving a VENDOR who runs a medical
collection center. This person manages a center, they are NOT asking about
personal medicine at home.
You receive the vendor's query and recent conversation history.

STEP 1: Check if the conversation history already contains enough information to fully answer the query.
- If YES → respond with: history: <your answer here>
- If NO → proceed to Step 2.

STEP 2: Classify the query into exactly one category:
- requests → donation requests sent TO their center, pending approvals, incoming donations, donated medicines
- center → their center profile, analytics, performance, fulfilment rate, ratings, reviews, verification status
- notifications → their alerts, notifications, unread messages
- outofscope → anything about the vendor's OWN personal medicine cabinet, personal prescriptions, personal expiry tracking, nearby hospitals to visit, or their own uploaded documents
- general → medical questions, drug info, health advice, greetings, anything else

RULES:
- 'my medicines' or 'my inventory' from a vendor means the medicines DONATED TO THEIR CENTER → requests. It does NOT mean a personal medicine cabinet.
- Only use outofscope when the vendor is clearly asking about themselves as a patient (e.g. 'when does my paracetamol at home expire', 'my lab report').
- NEVER use history for requests, center, or notifications queries. These always need fresh data from tools.
- Respond with ONLY the category name OR history: <answer>.
- Never add explanation.
"""

AGENT_INSTRUCTIONS = {
    "inventory": (
        "You are PillBot's Inventory Specialist. "
        "Fetch real data using your tools. Never fabricate medicine data. "
        "Return results clearly. Always use the tools."
    ),
    "directory": (
        "You are PillBot's Directory Specialist. "
        "Find medical facilities using your tools. Return name, address, contact info. "
        "If location is unavailable, use search_medical_center_by_name instead."
    ),
    "knowledge": (
        "You are PillBot's Document Analyst. "
        "Search the user's uploaded documents to answer their question. "
        "Quote relevant sections from the documents. "
        "If no relevant documents are found, say so clearly."
    ),
    "donations": (
        "You are PillBot's Donation Specialist. "
        "Fetch the user's own donation requests using your tools. Never fabricate. "
        "Explain the status plainly: pending means the center has not replied yet, "
        "approved means they accepted and will collect, completed means it was handed over. "
        "Always use the tools."
    ),
    "notifications": (
        "You are PillBot's Notifications Assistant. "
        "Fetch the user's notifications using your tools and summarise what matters. "
        "Lead with anything unread. Never fabricate notifications."
    ),
    "requests": (
        "You are PillBot's Center Operations Assistant, helping a vendor who runs a "
        "medical collection center. "
        "Fetch donation requests submitted TO their center using your tools. "
        "Highlight pending ones that need their action. Never fabricate. "
        "Always use the tools."
    ),
    "center": (
        "You are PillBot's Center Operations Assistant, helping a vendor who runs a "
        "medical collection center. "
        "Fetch their center profile, analytics and reviews using your tools. "
        "Present numbers plainly and point out what needs attention. Never fabricate."
    ),
    "outofscope": (
        "You are PillBot, assisting a vendor who runs a medical collection center. "
        "The vendor asked about something this assistant does not cover in vendor mode "
        "(their personal medicine cabinet, personal documents, or finding centers to visit). "
        "Politely explain that here you help with their center's donation requests, "
        "center performance and notifications. "
        "Tell them personal medicine tracking lives in their personal PillBin account. "
        "Be brief and friendly. Do not attempt to answer the original question."
    ),
    "general": (
        """
You are PillBot, a medical information assistant.

- Use web search only when needed for factual medical claims (symptoms, conditions, treatments, drug info). Don't search for greetings or general chat.
- Base answers on search results, not memory presented as fact. If results are thin or conflicting, say so.
- Do not diagnose — describe possible general causes only, and say a professional is needed to confirm.
- Do not give specific dosing, titration, or drug-combination advice beyond standard labeling. Redirect drug-safety questions to a pharmacist/doctor.
- Do not interpret personal lab results, scans, or reports.
- If symptoms suggest an emergency (chest pain, trouble breathing, stroke signs, severe bleeding, suicidal ideation, allergic reaction), lead with advice to seek immediate care — before anything else.
- Be factual and concise, but never drop a safety caveat for brevity. Always close by recommending a qualified professional for the user's specific situation.
"""
    ),
}

_TIMEOUT = 60

VENDOR_ROLE = "vendor"

ROUTER_BY_ROLE = {
    VENDOR_ROLE: VENDOR_ROUTER_INSTRUCTIONS,
    "user": USER_ROUTER_INSTRUCTIONS,
}

INTENTS_BY_ROLE = {
    VENDOR_ROLE: ("requests", "center", "notifications", "outofscope", "general"),
    "user": (
        "inventory",
        "directory",
        "donations",
        "notifications",
        "knowledge",
        "general",
    ),
}


def _normalise_role(role: str) -> str:
    return VENDOR_ROLE if (role or "").strip().lower() == VENDOR_ROLE else "user"


async def classify_intent(
    user_message: str, history_block: str, role: str = "user"
) -> tuple[str, Optional[str]]:
    prompt = user_message
    if history_block:
        prompt = f"{history_block}\n\nUser query: {user_message}"

    role = _normalise_role(role)

    t = Timer()
    router_agent = Agent(
        name="IntentRouter",
        model=get_router_llm(),
        instructions=ROUTER_BY_ROLE[role],
        markdown=False,
    )
    response = await router_agent.arun(prompt)
    raw = response.content.strip()

    # History check
    if raw.lower().startswith("history:"):
        answer = raw[len("history:") :].strip()
        log_intent("history", raw, t.elapsed())
        return "history", answer

    # Loose keyword scan — handles verbose model outputs
    for keyword in INTENTS_BY_ROLE[role]:
        if keyword in raw.lower():
            log_intent(f"{role}:{keyword}", raw, t.elapsed())
            return keyword, None

    log_intent(f"{role}:general", raw, t.elapsed())
    return "general", None


def _build_tools(
    intent: str, jwt_token: str, lat: str, lng: str, role: str = "user"
) -> list:
    role = _normalise_role(role)

    shared = {
        "notifications": lambda: [NotificationTools(jwt_token=jwt_token)],
        "general": lambda: [
            WebSearchTools(backend="duckduckgo", fixed_max_results=3, timeout=15)
        ],
    }

    if role == VENDOR_ROLE:
        tools_map = {
            **shared,
            "requests": lambda: [VendorRequestTools(jwt_token=jwt_token)],
            "center": lambda: [VendorCenterTools(jwt_token=jwt_token)],
        }
    else:
        tools_map = {
            **shared,
            "inventory": lambda: [InventoryTools(jwt_token=jwt_token)],
            "directory": lambda: [DirectoryTools(latitude=lat, longitude=lng)],
            "donations": lambda: [UserDonationTools(jwt_token=jwt_token)],
        }

    return tools_map.get(intent, lambda: [])()


async def get_agent_response(
    token: str,
    user_message: str,
    recent_history: List[Dict[str, Any]],
    agent_message_id: str = "",
    jwt_token: str = "",
    latitude: str = "",
    longitude: str = "",
    role: str = "user",
) -> Output:
    history_text = prune_context_string(format_history_for_agent(recent_history))
    history_block = f"## Recent Conversation\n{history_text}" if history_text else ""

    role = _normalise_role(role)
    intent, direct_answer = await classify_intent(user_message, history_block, role)

    if intent == "history" and direct_answer:
        log_response(direct_answer, False, 0.9, "0ms (history)")
        return Output(
            id=agent_message_id or "history",
            message=direct_answer,
            confidence=0.9,
        )

    instructions = AGENT_INSTRUCTIONS.get(intent, AGENT_INSTRUCTIONS["general"])
    instructions += (
        f"\n\nUse '{agent_message_id}' for the `id` field in your response. "
        "Set isTable=true when response contains lists, stats, or tabular data."
    )

    if intent == "knowledge" and role != VENDOR_ROLE:
        agent_name = "KnowledgeAgent (ChromaDB)"
        agent = Agent(
            name="PillBot",
            model=get_agent_llm(),
            knowledge=knowledge_base,
            search_knowledge=True,
            knowledge_filters={"user_id": token},
            output_schema=Output,
            tool_call_limit=3,
            retries=1,
            instructions=instructions,
        )
    else:
        tools = _build_tools(intent, jwt_token, latitude, longitude, role)
        agent_name = (
            f"{role}:{intent.capitalize()}Agent "
            f"({type(tools[0]).__name__ if tools else 'no tools'})"
        )
        agent = Agent(
            name="PillBot",
            model=get_agent_llm(),
            tools=tools,
            output_schema=Output,
            tool_call_limit=3,
            retries=1,
            instructions=instructions,
        )

    log_agent_start(agent_name)
    t = Timer()

    try:
        async with asyncio.timeout(_TIMEOUT):
            agent_prompt = user_message
            if history_block:
                agent_prompt = f"{history_block}\n\nUser query: {user_message}"
                
            response = await agent.arun(agent_prompt)
            content = response.content

            # Log tool calls if available
            if hasattr(response, "messages"):
                for msg in response.messages:
                    if hasattr(msg, "tool_calls") and msg.tool_calls:
                        for tc in msg.tool_calls:
                            fn = getattr(tc, "function", None)
                            name = getattr(fn, "name", str(tc)) if fn else str(tc)
                            log_tool_call(name)

            if isinstance(content, Output):
                result = content
            elif hasattr(content, "model_dump"):
                result = Output(**content.model_dump())
            else:
                result = Output(
                    id=agent_message_id or "fallback",
                    message=str(content),
                    confidence=0.5,
                )

            log_response(result.message, result.isTable, result.confidence, t.elapsed())
            return result

    except asyncio.TimeoutError:
        log_error("timeout", f"Agent exceeded {_TIMEOUT}s")
        return Output(
            id=agent_message_id or "error",
            message="Request timed out. Please try again.",
            confidence=0.0,
        )
    except Exception as e:
        log_error("agent", f"{type(e).__name__}: {e}")
        traceback.print_exc()
        return Output(
            id=agent_message_id or "error",
            message=f"An error occurred: {str(e)}",
            confidence=0.0,
        )
