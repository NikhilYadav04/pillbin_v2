/**
 * Generates notifications so the feed has enough rows to page through.
 * Development only — never run this against production.
 *
 *   node scripts/seedNotifications.js --count=45
 *   node scripts/seedNotifications.js --user=<userId> --count=60 --unread=30
 *   node scripts/seedNotifications.js --clean          (removes seeded rows only)
 */

const mongoose = require("mongoose");
require("dotenv").config();

const { connectDB } = require("../config/database");
const Notification = require("../models/Notification");
const User = require("../models/User");

const SEED_TYPE = "seed_test";

const TEMPLATES = [
  ["important", "Donation approved", "Sunrise Medical Center approved your donation request."],
  ["normal", "Donation completed", "Your medicines were received. Thanks for donating!"],
  ["alert", "Medicine expiring soon", "Paracetamol 500mg expires in 7 days."],
  ["urgent", "Medicine expired", "Amoxicillin has expired. Dispose of it safely."],
  ["normal", "New donation request", "A donor submitted a request to your center."],
  ["important", "Center verified", "Your medical center has been verified."],
  ["normal", "Review received", "A donor left you a 5-star review."],
  ["alert", "Request cancelled", "A pending donation request was cancelled."],
];

const args = process.argv.slice(2).reduce((acc, arg) => {
  const [key, value] = arg.replace(/^--/, "").split("=");
  acc[key] = value === undefined ? true : value;
  return acc;
}, {});

const randomInt = (min, max) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

(async () => {
  await connectDB();

  if (args.clean) {
    const result = await Notification.deleteMany({ type: SEED_TYPE });
    console.log(`removed ${result.deletedCount} seeded notifications`);
    await mongoose.connection.close();
    process.exit(0);
  }

  let userId = args.user;

  if (!userId) {
    const user = await User.findOne({ isVerified: true }).sort({
      createdAt: -1,
    });
    if (!user) {
      console.error("no verified user found — pass --user=<userId>");
      await mongoose.connection.close();
      process.exit(1);
    }
    userId = user._id;
    console.log(`using most recent verified user: ${user.email}`);
  }

  const count = parseInt(args.count) || 45;

  //* Default to roughly two thirds unread so the badge cannot be confused
  //* with either the page size or the total
  const unreadTarget =
    args.unread !== undefined
      ? Math.min(parseInt(args.unread) || 0, count)
      : Math.round(count * 0.65);

  const now = Date.now();
  const rows = [];

  for (let i = 0; i < count; i++) {
    const [status, title, description] = TEMPLATES[i % TEMPLATES.length];

    //* Spread over the last 30 days, newest first, so ordering is visible
    const createdAt = new Date(
      now - i * randomInt(20, 90) * 60 * 1000 - randomInt(0, 3600) * 1000
    );

    rows.push({
      userId,
      title: `${title} #${count - i}`,
      description,
      status,
      type: SEED_TYPE,
      isRead: i >= unreadTarget,
      createdAt,
      updatedAt: createdAt,
    });
  }

  await Notification.insertMany(rows);

  const total = await Notification.countDocuments({ userId });
  const unread = await Notification.countDocuments({ userId, isRead: false });

  console.log(`\ninserted ${rows.length} notifications`);
  console.log(`user now has ${total} total, ${unread} unread`);
  console.log(`\nexpect the bell badge to read ${unread} and stay there while`);
  console.log(`scrolling — it must not climb as more pages load.`);
  console.log(`\nclean up with: node scripts/seedNotifications.js --clean`);

  await mongoose.connection.close();
  process.exit(0);
})();
