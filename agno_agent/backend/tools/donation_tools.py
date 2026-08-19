import httpx
from agno.tools import Toolkit
from backend.config.settings import settings
from backend.tools.tool_utils import clamp_limit


class UserDonationTools(Toolkit):
    def __init__(self, jwt_token: str):
        super().__init__(name="user_donation_tools")
        self.jwt_token = jwt_token
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.get_my_donation_requests)
        self.register(self.get_donation_request_detail)
        self.register(self.get_donation_summary)

    def _headers(self):
        return {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
        }

    async def get_my_donation_requests(
        self, status: str = "", limit: int = 10
    ) -> str:
        """Fetch donation requests the user submitted. Optional status filter:
        'pending', 'approved', 'rejected', 'completed', 'cancelled'."""
        params = {"page": 1, "limit": clamp_limit(limit, 10)}
        if status:
            params["status"] = status

        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/donations/my-requests",
                headers=self._headers(),
                params=params,
            )
            resp.raise_for_status()
            data = resp.json().get("data", {})
            requests = data.get("requests", data)
            return str(requests)

    async def get_donation_request_detail(self, request_id: str) -> str:
        """Fetch one donation request by its id, including status history."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/donations/{request_id}",
                headers=self._headers(),
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))

    async def get_donation_summary(self) -> str:
        """Count the user's donation requests grouped by status."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/donations/my-requests",
                headers=self._headers(),
                params={"page": 1, "limit": 100},
            )
            resp.raise_for_status()
            data = resp.json().get("data", {})
            requests = data.get("requests", [])

            counts = {}
            for req in requests:
                key = req.get("status", "unknown")
                counts[key] = counts.get(key, 0) + 1

            return str({"total": len(requests), "by_status": counts})


class VendorRequestTools(Toolkit):
    def __init__(self, jwt_token: str):
        super().__init__(name="vendor_request_tools")
        self.jwt_token = jwt_token
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.get_incoming_requests)
        self.register(self.get_pending_requests)
        self.register(self.get_donated_medicines)

    def _headers(self):
        return {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
        }

    async def get_incoming_requests(self, status: str = "", limit: int = 20) -> str:
        """Fetch donation requests submitted TO this vendor's medical center.
        Optional status: 'pending', 'approved', 'rejected', 'completed', 'cancelled'."""
        params = {"page": 1, "limit": clamp_limit(limit, 20)}
        if status:
            params["status"] = status

        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/vendor/requests",
                headers=self._headers(),
                params=params,
            )
            resp.raise_for_status()
            data = resp.json().get("data", {})
            return str(data.get("requests", data))

    async def get_pending_requests(self) -> str:
        """Fetch only the requests still awaiting this vendor's approval."""
        return await self.get_incoming_requests(status="pending", limit=25)

    async def get_donated_medicines(self, limit: int = 20) -> str:
        """Fetch medicines that were actually donated to this vendor's center."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/vendor/analytics/medicines",
                headers=self._headers(),
                params={"limit": clamp_limit(limit, 20)},
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))
