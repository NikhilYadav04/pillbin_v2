import httpx
from agno.tools import Toolkit
from backend.config.settings import settings
from backend.tools.tool_utils import clamp_limit


class NotificationTools(Toolkit):
    def __init__(self, jwt_token: str):
        super().__init__(name="notification_tools")
        self.jwt_token = jwt_token
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.get_notifications)
        self.register(self.get_unread_count)

    def _headers(self):
        return {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
        }

    async def get_notifications(self, limit: int = 15) -> str:
        """Fetch this user's notifications, newest first. Each has a title,
        description, type, severity, read state and timestamp."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/notifications",
                headers=self._headers(),
            )
            resp.raise_for_status()
            data = resp.json().get("data", {})
            notifications = data.get("notifications", [])
            capped = clamp_limit(limit, 15)
            return str(
                {
                    "total": data.get("totalCount", len(notifications)),
                    "unread": data.get("unreadCount", 0),
                    "notifications": notifications[:capped],
                }
            )

    async def get_unread_count(self) -> str:
        """Count how many notifications this user has not read yet."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/notifications/unread-count",
                headers=self._headers(),
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))
