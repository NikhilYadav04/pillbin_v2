const crypto = require("crypto");
const cron = require("node-cron");
const Medicine = require("../models/Medicine");
require("../models/FamilyMember");
const { notify } = require("../services/notifyService");
const { buildExpiryMessage } = require("../utils/expiryMessages");

const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

const dayBucket = (date = new Date()) =>
  new Date(date.getTime() + IST_OFFSET_MS).toISOString().slice(0, 10);

const sha = (value) =>
  crypto.createHash("sha256").update(value).digest("hex");

//* "Paracetamol" for the account owner, "Paracetamol (Mom)" for a tagged
//* family member's medicine
const displayName = (medicine) =>
  medicine.familyMemberId && medicine.familyMemberId.name
    ? `${medicine.name} (${medicine.familyMemberId.name})`
    : medicine.name;

const STATUS_META = {
  expiring_soon: { type: "medicine_expiring_soon", severity: "important" },
  expired: { type: "medicine_expired", severity: "alert" },
};

async function runRefillCheck(bucketDay) {
  const now = new Date();

  const due = await Medicine.find({
    isDeleted: false,
    isRecurring: true,
    nextRefillAt: { $lte: now },
  })
    .select("_id userId name refillIntervalDays nextRefillAt familyMemberId")
    .populate("familyMemberId", "name");

  if (due.length === 0) return 0;

  const buckets = new Map();
  for (const medicine of due) {
    const key = String(medicine.userId);
    if (!buckets.has(key)) buckets.set(key, []);
    buckets.get(key).push(medicine);
  }

  let sent = 0;

  for (const [userId, items] of buckets) {
    const names = items.map(displayName);
    const title =
      items.length === 1 ? "Time to refill" : `Time to refill ${items.length} medicines`;
    const description =
      items.length === 1
        ? `You're due to refill ${names[0]}.`
        : `You're due to refill: ${names.join(", ")}.`;

    const key = sha(`refill|${userId}|${bucketDay}`);

    const inserted = await notify({
      recipientIds: [userId],
      type: "medicine_refill_due",
      title,
      description,
      status: "normal",
      entityType: "medicine",
      entityId: items.length === 1 ? items[0]._id : null,
      dedupKey: key,
      groupKey: key,
    });

    sent += inserted.length;
  }

  await Promise.all(
    due.map((medicine) =>
      Medicine.updateOne(
        { _id: medicine._id },
        {
          $set: {
            nextRefillAt: new Date(
              now.getTime() + medicine.refillIntervalDays * 24 * 60 * 60 * 1000
            ),
          },
        }
      )
    )
  );

  return sent;
}

let isRunning = false;

async function runExpiryJob() {
  if (isRunning) {
    console.log("[expiryJob] previous run still active, skipping tick");
    return { skipped: true };
  }

  isRunning = true;
  const startedAt = Date.now();

  try {
    await Medicine.updateAllStatuses();

    await Medicine.updateMany(
      { status: "active", lastNotifiedStatus: { $ne: null } },
      { $set: { lastNotifiedStatus: null } }
    );

    const pending = await Medicine.find({
      isDeleted: false,
      status: { $in: Object.keys(STATUS_META) },
      $expr: { $ne: ["$status", "$lastNotifiedStatus"] },
    })
      .select("_id userId name status familyMemberId")
      .populate("familyMemberId", "name");

    const buckets = new Map();
    for (const medicine of pending) {
      const key = `${medicine.userId}|${medicine.status}`;
      if (!buckets.has(key)) {
        buckets.set(key, {
          userId: medicine.userId,
          status: medicine.status,
          items: [],
        });
      }
      buckets.get(key).items.push(medicine);
    }

    const bucketDay = dayBucket();
    let sent = 0;

    for (const { userId, status, items } of buckets.values()) {
      const meta = STATUS_META[status];
      const { title, description } = buildExpiryMessage(
        status,
        items.map(displayName)
      );

      const key = sha(`expiry|${userId}|${status}|${bucketDay}`);

      const inserted = await notify({
        recipientIds: [userId],
        type: meta.type,
        title,
        description,
        status: meta.severity,
        entityType: "medicine",
        entityId: items.length === 1 ? items[0]._id : null,
        dedupKey: key,
        groupKey: key,
      });

      await Medicine.updateMany(
        { _id: { $in: items.map((i) => i._id) } },
        { $set: { lastNotifiedStatus: status } }
      );

      sent += inserted.length;
    }

    if (process.env.EXPIRY_CLEANUP_ENABLED === "true") {
      const deleted = await Medicine.cleanupExpiredMedicines();
      console.log(`[expiryJob] cleanup removed ${deleted} medicines`);
    }

    const refillsSent = await runRefillCheck(bucketDay);

    const summary = {
      pending: pending.length,
      notified: sent,
      refillsSent,
      ms: Date.now() - startedAt,
    };
    console.log(`[expiryJob] ${JSON.stringify(summary)}`);
    return summary;
  } catch (error) {
    console.error("[expiryJob] failed:", error.message);
    return { error: error.message };
  } finally {
    isRunning = false;
  }
}

function scheduleExpiryJob() {
  const expression = process.env.EXPIRY_CRON || "0 9 * * *";

  if (!cron.validate(expression)) {
    console.error(`[expiryJob] invalid EXPIRY_CRON "${expression}", not scheduled`);
    return null;
  }

  const task = cron.schedule(expression, runExpiryJob, {
    timezone: "Asia/Kolkata",
  });

  console.log(`[expiryJob] scheduled "${expression}" (Asia/Kolkata)`);
  return task;
}

module.exports = { runExpiryJob, scheduleExpiryJob };
