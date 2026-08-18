const titlesExpiringSoon = [
  "⚠️ Medicine Expiry Alert!",
  "⏰ Your Medicine Is About to Expire!",
  "💊 Expiry Coming Up Soon!",
  "🚨 Medicine Nearing Expiry – Take Action!",
  "🕒 Check Before It's Too Late!",
];

const titlesExpired = [
  "💀 Medicine Expired!",
  "⚠️ Expired Medicine Alert!",
  "🚫 Time's Up! Medicine Expired.",
  "⛔ Medicine Past Its Expiry Date!",
  "🩺 Expired Medicine Detected!",
];

const descExpiringSoon = [
  "is nearing its expiry date. Please review it and remove it from your inventory if it's no longer safe to use.",
  "is close to expiring. Check your list and consider removing it soon to keep your inventory accurate and safe.",
  "is about to expire soon. Review your list to ensure everything stays up to date.",
];

const descExpired = [
  "has expired. Please remove it immediately to keep your tracker clean and up to date.",
  "has crossed its expiry date. Discard it safely to maintain a reliable inventory.",
  "has expired. Please remove it from your inventory to keep it accurate and safe.",
];

const pick = (list) => list[Math.floor(Math.random() * list.length)];

function nameList(names) {
  if (names.length <= 3) {
    if (names.length === 1) return names[0];
    return `${names.slice(0, -1).join(", ")} and ${names[names.length - 1]}`;
  }
  return `${names.slice(0, 3).join(", ")} and ${names.length - 3} more`;
}

function buildExpiryMessage(status, names) {
  const isExpired = status === "expired";
  const count = names.length;

  if (count === 1) {
    return {
      title: pick(isExpired ? titlesExpired : titlesExpiringSoon),
      description: `${names[0]} ${pick(
        isExpired ? descExpired : descExpiringSoon
      )}`,
    };
  }

  return {
    title: isExpired
      ? `💀 ${count} Medicines Expired!`
      : `⚠️ ${count} Medicines Expiring Soon!`,
    description: isExpired
      ? `${nameList(
          names
        )} have expired. Please remove them from your inventory to keep it accurate and safe.`
      : `${nameList(
          names
        )} are nearing their expiry date. Review your inventory and dispose of anything that is no longer safe to use.`,
  };
}

module.exports = { buildExpiryMessage };
