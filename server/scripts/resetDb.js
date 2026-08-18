/**
 * Clears every collection except users, and resets the denormalised fields on
 * User that point at the dropped data. Accounts, phone numbers and roles stay
 * intact so you can log straight back in.
 *
 * Cloudinary assets are NOT touched — clear those separately.
 *
 *   node scripts/resetDb.js              (dry run — shows counts, changes nothing)
 *   node scripts/resetDb.js --confirm    (performs the wipe)
 */

const mongoose = require("mongoose");
require("dotenv").config();

const User = require("../models/User");

const COLLECTIONS_TO_CLEAR = [
  "Medicine",
  "MedicalCenter",
  "DonationRequest",
  "CenterReview",
  "Notification",
  "blog",
  "chat",
  "comment",
  "like",
  "rag",
];

const args = process.argv.slice(2);
const confirmed = args.includes("--confirm");

const run = async () => {
  const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/chatapp";
  await mongoose.connect(uri);

  const dbName = mongoose.connection.name;
  console.log(`\n🗄️  Database: ${dbName}`);
  console.log(`🔗 ${uri.replace(/\/\/[^@]*@/, "//***@")}\n`);

  const models = COLLECTIONS_TO_CLEAR.map((name) => {
    try {
      return require(`../models/${name}`);
    } catch (e) {
      console.warn(`⚠️  Skipping ${name} — model not found`);
      return null;
    }
  }).filter(Boolean);

  console.log("Will DELETE:");
  for (const model of models) {
    const count = await model.countDocuments();
    console.log(`   ${model.modelName.padEnd(16)} ${count}`);
  }

  const userCount = await User.countDocuments();
  const vendorCount = await User.countDocuments({
    vendorCenterId: { $ne: null },
  });

  console.log("\nWill KEEP (but reset):");
  console.log(`   User             ${userCount}  (${vendorCount} with a linked center)`);
  console.log(
    "   → clearing vendorCenterId, savedMedicalCenters, medicineCount, stats, badges"
  );
  console.log("   → keeping _id, phone, email, name, role, tokens\n");

  if (!confirmed) {
    console.log("🔍 Dry run. Nothing changed.");
    console.log("   Re-run with --confirm to perform the wipe.\n");
    await mongoose.disconnect();
    return;
  }

  for (const model of models) {
    const result = await model.deleteMany({});
    console.log(`🗑️  ${model.modelName}: removed ${result.deletedCount}`);
  }

  const reset = await User.updateMany(
    {},
    {
      $set: {
        vendorCenterId: null,
        savedMedicalCenters: [],
        medicineCount: 0,
        "stats.totalMedicinesTracked": 0,
        "stats.expiringSoonCount": 0,
        "stats.medicinesDisposedCount": 0,
        "stats.campaignsJoinedCount": 0,
        "badges.firstTimer.achieved": false,
        "badges.firstTimer.unlockedAt": null,
        "badges.ecoHelper.achieved": false,
        "badges.ecoHelper.unlockedAt": null,
        "badges.greenChampion.achieved": false,
        "badges.greenChampion.unlockedAt": null,
      },
    }
  );

  console.log(`\n♻️  Reset ${reset.modifiedCount} users`);
  console.log("✅ Done. Vendor accounts can now register a fresh center.\n");

  await mongoose.disconnect();
};

run().catch(async (error) => {
  console.error("❌ Reset failed:", error);
  await mongoose.disconnect();
  process.exit(1);
});
