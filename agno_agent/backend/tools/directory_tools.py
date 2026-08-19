import httpx
from agno.tools import Toolkit
from backend.config.settings import settings


class DirectoryTools(Toolkit):
    def __init__(self, latitude: str = "", longitude: str = ""):
        super().__init__(name="directory_tools")
        self.latitude = latitude
        self.longitude = longitude
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.find_nearby_medical_centers)
        self.register(self.search_medical_center_by_name)

    async def find_nearby_medical_centers(
        self, radius: int = 50, limit: int = 10
    ) -> str:
        """Find nearby hospitals, clinics, and pharmacies based on user location."""
        if not self.latitude or not self.longitude:
            return "Location not provided. Ask the user for their location or use search_medical_center_by_name."
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medical-center/nearby",
                params={
                    "latitude": self.latitude,
                    "longitude": self.longitude,
                    "radius": radius,
                    "limit": limit,
                    "page": 1,
                },
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}).get("medicalCenters", []))

    async def search_medical_center_by_name(
        self, query: str, limit: int = 10
    ) -> str:
        """Search for a medical center by name."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medical-center/search",
                params={"query": query, "page": 1, "limit": limit},
            )
            resp.raise_for_status()
            return str(resp.json().get("data", {}).get("medicalCenters", []))
