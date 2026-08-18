const { getMessaging, isConfigured } = require("../config/firebase");
const DeviceToken = require("../models/DeviceToken");

const DEAD_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

const URGENT_STATUSES = new Set(["urgent", "alert"]);

function stringifyData(data = {}) {
  const out = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) continue;
    out[key] = typeof value === "string" ? value : JSON.stringify(value);
  }
  return out;
}

async function deactivateTokens(tokens) {
  if (!tokens.length) return;
  await DeviceToken.updateMany(
    { fcmToken: { $in: tokens } },
    { $set: { isActive: false } }
  );
}

async function sendPushToUsers(userIds, { title, body, status }, data = {}) {
  try {
    if (!isConfigured()) return;

    const recipients = [...new Set((userIds || []).filter(Boolean).map(String))];
    if (!recipients.length) return;

    const rows = await DeviceToken.find({
      userId: { $in: recipients },
      isActive: true,
    }).select("fcmToken");

    const tokens = [...new Set(rows.map((r) => r.fcmToken))];
    if (!tokens.length) return;

    const channelId = URGENT_STATUSES.has(status)
      ? "action_required_channel"
      : "informational_channel";

    const payload = stringifyData(data);

    const messaging = getMessaging();

    const results = await Promise.allSettled(
      tokens.map((token) =>
        messaging.send({
          token,
          notification: { title, body },
          data: payload,
          android: {
            priority: "high",
            notification: { channelId },
          },
          apns: {
            headers: { "apns-priority": "10" },
            payload: { aps: { sound: "default", badge: 1 } },
          },
        })
      )
    );

    const dead = results
      .map((result, index) => {
        if (result.status !== "rejected") return null;
        const code = result.reason?.errorInfo?.code || result.reason?.code;
        return DEAD_TOKEN_CODES.has(code) ? tokens[index] : null;
      })
      .filter(Boolean);

    if (dead.length) await deactivateTokens(dead);
  } catch (error) {
    console.error("sendPushToUsers failed:", error.message);
  }
}

module.exports = { sendPushToUsers, deactivateTokens };
