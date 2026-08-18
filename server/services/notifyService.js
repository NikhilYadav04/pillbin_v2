const Notification = require("../models/Notification.js");
const { sendPushToUsers } = require("./pushService");

const MAX_PER_USER = 50;

async function trimToLimit(userId) {
  const excess = await Notification.find({ userId })
    .sort({ createdAt: -1 })
    .skip(MAX_PER_USER)
    .select("_id")
    .lean();

  if (excess.length > 0) {
    await Notification.deleteMany({ _id: { $in: excess.map((d) => d._id) } });
  }
}

async function notify({
  recipientIds,
  type,
  title,
  description,
  status = "normal",
  entityType = null,
  entityId = null,
  dedupKey = null,
  groupKey = null,
  push = true,
}) {
  try {
    const recipients = [
      ...new Set((recipientIds || []).filter(Boolean).map(String)),
    ];
    if (recipients.length === 0) return [];

    const inserted = [];

    for (const userId of recipients) {
      try {
        const row = await Notification.create({
          userId,
          type,
          title,
          description,
          status,
          entityType,
          entityId,
          groupKey,
          ...(dedupKey ? { dedupKey: `${dedupKey}|${userId}` } : {}),
        });

        inserted.push(row);
        await trimToLimit(userId);
      } catch (error) {
        if (error.code !== 11000) {
          console.error(`notify: row failed for ${userId}:`, error.message);
        }
      }
    }

    if (push && inserted.length > 0) {
      await sendPushToUsers(
        inserted.map((row) => row.userId),
        { title, body: description, status },
        {
          type,
          entity_type: entityType,
          entity_id: entityId,
          notification_id: inserted.length === 1 ? inserted[0]._id : null,
        }
      );
    }

    return inserted;
  } catch (error) {
    console.error("notify failed:", error.message);
    return [];
  }
}

module.exports = { notify };
