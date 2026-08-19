import httpx
from agno.tools import Toolkit
from backend.config.settings import settings
from backend.tools.tool_utils import clamp_limit


class VendorCenterTools(Toolkit):
    def __init__(self, jwt_token: str):
        super().__init__(name="vendor_center_tools")
        self.jwt_token = jwt_token
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.get_my_center)
        self.register(self.get_center_analytics)
        self.register(self.get_center_reviews)

    def _headers(self):
        return {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
        }

    async def get_my_center(self) -> str:
        """Fetch this vendor's medical center: name, address, verification status,
        accepted medicine categories and operating details."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/vendor/my-center",
                headers=self._headers(),
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))

    async def get_center_analytics(self) -> str:
        """Fetch this center's performance: request counts by status, fulfilment
        rate, average approval time, rating and monthly timeline."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/vendor/analytics",
                headers=self._headers(),
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))

    async def get_center_reviews(self, limit: int = 10) -> str:
        """Fetch reviews donors left for this vendor's center."""
        async with httpx.AsyncClient() as client:
            center_resp = await client.get(
                f"{self.base_url}/vendor/my-center",
                headers=self._headers(),
            )
            center_resp.raise_for_status()
            center = center_resp.json().get("data", {}).get("center", {})
            center_id = center.get("_id")

            if not center_id:
                return str({"error": "No center found for this vendor"})

            resp = await client.get(
                f"{self.base_url}/donations/center/{center_id}/reviews",
                headers=self._headers(),
                params={"page": 1, "limit": clamp_limit(limit, 10)},
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}))
