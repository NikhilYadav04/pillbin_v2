const mongoose = require("mongoose");
const { connectDB } = require("../config/database");
const { notify } = require("../services/notifyService");
const DeviceToken = require("../models/DeviceToken");

const userId = process.argv[2];

(async () => {
  if (!userId) {
    console.error("usage: node scripts/testNotification.js <userId>");
    process.exit(1);
  }

  await connectDB();

  const tokens = await DeviceToken.find({ userId, isActive: true });
  console.log(`active device tokens for this user: ${tokens.length}`);
  if (tokens.length === 0) {
    console.log("no tokens — the row will save but no push will be sent");
  }

  const rows = await notify({
    recipientIds: [userId],
    type: "medicine_expiring_soon",
    title: "🧪 PillBin Test",
    description:
      "If this arrived on your phone, push notifications are working end to end.",
    status: "important",
    entityType: "medicine",
  });

  console.log(`notification rows inserted: ${rows.length}`);

  await mongoose.disconnect();
  process.exit(0);
})();
