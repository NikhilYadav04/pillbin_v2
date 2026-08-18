/**
 * Generates realistic donation history so the vendor analytics charts have
 * something to show. Development only — never run this against production.
 *
 *   node scripts/seedDonations.js --count=60 --months=6
 *   node scripts/seedDonations.js --center=<centerId> --user=<userId>
 *   node scripts/seedDonations.js --clean          (removes seeded data only)
 */

const mongoose = require("mongoose");
require("dotenv").config();

const MedicalCenter = require("../models/MedicalCenter");
const DonationRequest = require("../models/DonationRequest");
const CenterReview = require("../models/CenterReview");
const User = require("../models/User");

const SEED_NOTE = "[seed]";

const MEDICINES = [
  ["Paracetamol", "tablet"],
  ["Amoxicillin", "capsule"],
  ["Ibuprofen", "tablet"],
  ["Cetirizine", "tablet"],
  ["Metformin", "tablet"],
  ["Azithromycin", "tablet"],
  ["Omeprazole", "capsule"],
  ["Cough Syrup", "syrup"],
  ["Vitamin D3", "tablet"],
  ["Insulin", "injection"],
];

const args = process.argv.slice(2).reduce((acc, arg) => {
  const [key, value] = arg.replace(/^--/, "").split("=");
  acc[key] = value === undefined ? true : value;
  return acc;
}, {});

const randomInt = (min, max) =>
  Math.floor(Math.random() * (max - min + 1)) + min;
const pick = (arr) => arr[randomInt(0, arr.length - 1)];

//* Weighted so the charts look like a real centre, not a uniform mush
const rollStatus = () => {
  const roll = Math.random();
  if (roll < 0.55) return "completed";
  if (roll < 0.7) return "approved";
  if (roll < 0.85) return "pending";
  if (roll < 0.95) return "rejected";
  return "cancelled";
};

const buildHistory = (createdAt, status, userId, vendorId) => {
  const history = [{ status: "pending", at: new Date(createdAt), by: userId }];
  if (status === "pending") return history;

  if (status === "cancelled") {
    history.push({
      status: "cancelled",
      at: new Date(createdAt.getTime() + randomInt(1, 72) * 3600000),
      by: userId,
    });
    return history;
  }

  //* Reply within 2–48h
  const decidedAt = new Date(
    createdAt.getTime() + randomInt(2, 48) * 3600000
  );

  if (status === "rejected") {
    history.push({
      status: "rejected",
      at: decidedAt,
      by: vendorId,
      note: "Not accepting this category currently",
    });
    return history;
  }

  history.push({ status: "approved", at: decidedAt, by: vendorId });

  if (status === "completed") {
    history.push({
      status: "completed",
      at: new Date(decidedAt.getTime() + randomInt(12, 120) * 3600000),
      by: vendorId,
    });
  }
  return history;
};

const run = async () => {
  await mongoose.connect(
    process.env.MONGODB_URI || "mongodb://localhost:27017/chatapp"
  );
  console.log("✅ Connected");

  if (args.clean) {
    const requests = await DonationRequest.find({ userNote: SEED_NOTE }).select(
      "_id"
    );
    const ids = requests.map((r) => r._id);
    const reviews = await CenterReview.deleteMany({
      donationRequestId: { $in: ids },
    });
    const removed = await DonationRequest.deleteMany({ userNote: SEED_NOTE });
    console.log(
      `🧹 Removed ${removed.deletedCount} seeded requests and ${reviews.deletedCount} reviews`
    );
    await mongoose.disconnect();
    return;
  }

  const center = args.center
    ? await MedicalCenter.findById(args.center)
    : await MedicalCenter.findOne({
        isVendorManaged: true,
        verificationStatus: "approved",
      });

  if (!center) {
    console.error(
      "❌ No verified vendor-managed center found. Pass --center=<id>."
    );
    await mongoose.disconnect();
    process.exit(1);
  }

  const donors = args.user
    ? [await User.findById(args.user)]
    : await User.find({ _id: { $ne: center.vendorUserId } }).limit(8);

  if (!donors.length || !donors[0]) {
    console.error("❌ No donor users found. Pass --user=<id>.");
    await mongoose.disconnect();
    process.exit(1);
  }

  const count = parseInt(args.count) || 60;
  const months = parseInt(args.months) || 6;
  const vendorId = center.vendorUserId;

  const earliest = new Date();
  earliest.setMonth(earliest.getMonth() - (months - 1));
  earliest.setDate(1);
  earliest.setHours(0, 0, 0, 0);
  const span = Date.now() - earliest.getTime();

  const docs = [];
  const completedRefs = [];

  for (let i = 0; i < count; i++) {
    //* Skew recent so the trend line rises rather than sitting flat
    const bias = Math.pow(Math.random(), 0.65);
    const createdAt = new Date(earliest.getTime() + bias * span);
    const status = rollStatus();
    const donor = pick(donors);

    const medicines = Array.from({ length: randomInt(1, 3) }, () => {
      const [name, type] = pick(MEDICINES);
      const expiry = new Date(createdAt);
      expiry.setMonth(expiry.getMonth() + randomInt(2, 18));
      return {
        name,
        category: type,
        quantity: `${randomInt(1, 30)}`,
        expiryDate: expiry,
        condition: pick(["sealed", "opened", "unknown"]),
      };
    });

    const history = buildHistory(createdAt, status, donor._id, vendorId);

    docs.push({
      userId: donor._id,
      medicalCenterId: center._id,
      medicines,
      status,
      userNote: SEED_NOTE,
      contactPreference: pick(["call", "visit", "either"]),
      statusHistory: history,
      createdAt,
      updatedAt: history[history.length - 1].at,
    });
  }

  const inserted = await DonationRequest.insertMany(docs, { timestamps: false });
  console.log(`📦 Inserted ${inserted.length} donation requests`);

  for (const doc of inserted) {
    if (doc.status === "completed" && Math.random() < 0.6) {
      completedRefs.push({
        userId: doc.userId,
        medicalCenterId: center._id,
        donationRequestId: doc._id,
        //* Mostly positive with a few poor ones, like real review data
        rating: Math.random() < 0.75 ? randomInt(4, 5) : randomInt(1, 3),
        comment: SEED_NOTE,
      });
    }
  }

  if (completedRefs.length) {
    await CenterReview.insertMany(completedRefs);
    const sum = completedRefs.reduce((s, r) => s + r.rating, 0);
    const avg = sum / completedRefs.length;
    const weighted = (5 * 3.5 + sum) / (5 + completedRefs.length);

    await MedicalCenter.findByIdAndUpdate(center._id, {
      rating: Math.round(avg * 10) / 10,
      totalReviews: completedRefs.length,
      weightedRating: Math.round(weighted * 100) / 100,
    });
    console.log(
      `⭐ Inserted ${completedRefs.length} reviews (avg ${avg.toFixed(1)})`
    );
  }

  const completedCount = inserted.filter((d) => d.status === "completed").length;
  await MedicalCenter.findByIdAndUpdate(center._id, {
    $inc: { donationCount: completedCount },
  });

  console.log(`\n🏥 Center: ${center.name}`);
  console.log(`📊 ${count} requests across ${months} months`);
  console.log(`✅ ${completedCount} completed`);
  console.log(`\nRun with --clean to remove everything this script created.`);

  await mongoose.disconnect();
};

run().catch(async (error) => {
  console.error("❌ Seed failed:", error);
  await mongoose.disconnect();
  process.exit(1);
});
