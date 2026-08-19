import asyncio
from datetime import datetime
from typing import List

import httpx
from agno.tools import Toolkit
from backend.config.settings import settings
from backend.tools.tool_utils import clamp_limit


class InventoryTools(Toolkit):
    def __init__(self, jwt_token: str):
        super().__init__(name="inventory_tools")
        self.jwt_token = jwt_token
        self.base_url = settings.NODE_JS_BASE_URL
        self.register(self.get_medicines)
        self.register(self.get_inventory_summary_stats)
        self.register(self.get_expiry_analytics)
        self.register(self.check_medicine_stock)
        self.register(self.get_deleted_medicine_history)

    def _headers(self):
        return {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
        }

    async def get_medicines(
        self, status: str = "active", limit: int = 10, page: int = 1
    ) -> str:
        """Fetch medicines by status: 'active', 'expiring_soon', or 'expired'."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medicine/inventory",
                headers=self._headers(),
                params={"page": page, "limit": clamp_limit(limit, 10)},
            )
            resp.raise_for_status()
            inventory = resp.json().get("data", {}).get("inventory", {})
            mapping = {
                "active": "activeMedicines",
                "expiring_soon": "expiringSoonMedicines",
                "expired": "expiredMedicines",
            }
            return str(inventory.get(mapping.get(status, "activeMedicines"), []))

    async def get_inventory_summary_stats(self) -> str:
        """Get counts: active, expired, expiring_soon, and total medicines."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medicine/inventory",
                headers=self._headers(),
                params={"limit": 1},
            )
            resp.raise_for_status()
            counts = (
                resp.json().get("data", {}).get("inventory", {}).get("counts", {})
            )
            return str(counts)

    async def get_expiry_analytics(self, until_date: str) -> str:
        """Find medicines expiring before a date (YYYY-MM-DD)."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medicine/inventory",
                headers=self._headers(),
                params={"limit": 100},
            )
            resp.raise_for_status()
            inventory = resp.json().get("data", {}).get("inventory", {})
            combined = inventory.get("activeMedicines", []) + inventory.get(
                "expiringSoonMedicines", []
            )
            target = datetime.fromisoformat(until_date).date()
            results = [
                {"name": m["name"], "expiryDate": m["expiryDate"], "status": m["status"]}
                for m in combined
                if datetime.fromisoformat(
                    m["expiryDate"].replace("Z", "+00:00")
                ).date()
                <= target
            ]
            return str({
                "target_date": until_date,
                "count": len(results),
                "medications": results[:10],
            })

    async def check_medicine_stock(self, names: List[str]) -> str:
        """Check if medicines exist in current stock or deleted history."""
        headers = self._headers()
        async with httpx.AsyncClient() as client:
            inv_resp, hist_resp = await asyncio.gather(
                client.get(
                    f"{self.base_url}/medicine/inventory",
                    headers=headers,
                    params={"limit": 100},
                ),
                client.get(
                    f"{self.base_url}/medicine/deleted-inventory",
                    headers=headers,
                ),
            )
            inv_data = inv_resp.json().get("data", {}).get("inventory", {})
            active_list = inv_data.get("activeMedicines", []) + inv_data.get(
                "expiringSoonMedicines", []
            )
            active_names = {m["name"].lower(): m for m in active_list}

            hist_list = hist_resp.json().get("data", {}).get("medicines", [])
            hist_names = {m["name"].lower(): m for m in hist_list}

            results = {}
            for name in names:
                key = name.lower()
                if key in active_names:
                    med = active_names[key]
                    results[name] = {
                        "exists": True,
                        "location": "inventory",
                        "status": med.get("status"),
                        "expiryDate": med.get("expiryDate"),
                    }
                elif key in hist_names:
                    med = hist_names[key]
                    results[name] = {
                        "exists": False,
                        "location": "history",
                        "status": "deleted",
                        "removedDate": med.get("updatedAt"),
                    }
                else:
                    results[name] = {"exists": False, "location": "not_found"}
            return str(results)

    async def get_deleted_medicine_history(self, limit: int = 10) -> str:
        """Fetch history of deleted/removed medicines."""
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{self.base_url}/medicine/deleted-inventory",
                headers=self._headers(),
            )
            resp.raise_for_status()
            data = resp.json().get("data", {}).get("medicines", [])
            return str(data[:clamp_limit(limit, 10)])
