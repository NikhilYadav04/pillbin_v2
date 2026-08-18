const mongoose = require("mongoose");
const { connectDB } = require("../config/database");
const Medicine = require("../models/Medicine");

(async () => {
  await connectDB();

  const transitions = await Medicine.updateAllStatuses();

  const counts = {};
  for (const t of transitions) {
    const key = `${t.previousStatus} -> ${t.status}`;
    counts[key] = (counts[key] || 0) + 1;
  }

  const users = new Set(transitions.map((t) => String(t.userId)));

  console.log(`updated ${transitions.length} medicines across ${users.size} users`);
  for (const [key, count] of Object.entries(counts)) {
    console.log(`  ${key}: ${count}`);
  }

  await mongoose.disconnect();
  process.exit(0);
})();
