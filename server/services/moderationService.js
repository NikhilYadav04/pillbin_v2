const User = require("../models/User");
const { notify } = require("./notifyService");

const HIDDEN_STATUSES = ["pending", "rejected"];

const PUBLISH_THRESHOLD = 0.7;
const REJECT_THRESHOLD = 0.85;
const REJECTABLE = new Set(["spam", "abusive", "selling_medicines"]);

const CATEGORY_CRITERIA = {
  ok: "Normal, on-topic content that is safe to publish",
  spam: "Advertising, promotions, links, repeated or meaningless text",
  abusive: "Insults, harassment, hate, threats or sexual content",
  selling_medicines:
    "Offering to sell, buy or trade medicines, prescriptions or controlled drugs",
  dangerous_advice:
    "Medical advice that could cause harm, such as stopping prescribed treatment, unsafe doses or unproven cures",
};

const KIND_CONTEXT = {
  blog: "A community post in PillBin, an app for tracking, disposing and donating unused medicines.",
  comment: "A comment on a community post in PillBin, an app for tracking, disposing and donating unused medicines.",
  review: "A review of a medical center where the user donated unused medicines through the PillBin app.",
};

const PUBLISHED = { status: "published", label: null, probability: null };

const isEnabled = () =>
  process.env.JEV_ENABLED === "true" && Boolean(process.env.JEV_API_KEY);

async function evaluate(state) {
  const baseUrl = (process.env.JEV_BASE_URL || "https://ai-gateway.vercel.sh").replace(/\/$/, "");
  const timeoutMs = Number(process.env.JEV_TIMEOUT_MS) || 2000;

  const response = await fetch(`${baseUrl}/v1/evaluate`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.JEV_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: process.env.JEV_MODEL || "typesafe-ai/jev",
      state,
      questions: {
        category: {
          type: "choice",
          instructions: "Which category best describes this text?",
          criteria: CATEGORY_CRITERIA,
        },
      },
    }),
    signal: AbortSignal.timeout(timeoutMs),
  });

  const body = await response.text();
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${body.slice(0, 200)}`);
  }
  return JSON.parse(body);
}

function readCategory(data) {
  const answers = data && typeof data === "object" ? data.answers || data : null;
  const answer = answers && answers.category;
  const label = answer && answer.choice;
  const probability = answer && answer.probabilities && answer.probabilities[label];
  if (typeof label !== "string" || typeof probability !== "number") return null;
  return { label, probability };
}

async function moderate(kind, text) {
  if (!isEnabled() || !text || !text.trim()) return PUBLISHED;

  let data;
  try {
    data = await evaluate(`${KIND_CONTEXT[kind]}\n\nText:\n${text}`);
  } catch (error) {
    console.error(`[moderation] Jev unavailable, publishing ${kind}: ${error.message}`);
    return PUBLISHED;
  }

  const category = readCategory(data);
  if (!category) {
    console.error(
      `[moderation] unrecognised Jev response, publishing ${kind}:`,
      JSON.stringify(data).slice(0, 300)
    );
    return PUBLISHED;
  }

  const { label, probability } = category;
  let status = "pending";
  if (label === "ok" && probability >= PUBLISH_THRESHOLD) status = "published";
  else if (REJECTABLE.has(label) && probability >= REJECT_THRESHOLD) status = "rejected";

  console.log(`[moderation] ${kind} → ${label}:${probability.toFixed(2)} → ${status}`);
  return { status, label, probability };
}

function moderationFields(result) {
  if (!result.label) return {};
  return {
    moderationStatus: result.status,
    moderation: {
      label: result.label,
      probability: result.probability,
      checkedAt: new Date(),
    },
  };
}

async function notifyAdminsOfPending(kind, entityId) {
  const admins = await User.find({ role: "admin" }).select("_id").lean();
  if (admins.length === 0) return;

  notify({
    recipientIds: admins.map((a) => a._id),
    type: "moderation_pending",
    title: "Content waiting for review",
    description: `A new ${kind} was held by automatic moderation and needs your review.`,
    status: "important",
    entityType: kind,
    entityId,
  });
}

const REJECTED_MESSAGE =
  "This can't be posted because it goes against PillBin's community guidelines.";

module.exports = {
  HIDDEN_STATUSES,
  REJECTED_MESSAGE,
  moderate,
  moderationFields,
  notifyAdminsOfPending,
};
