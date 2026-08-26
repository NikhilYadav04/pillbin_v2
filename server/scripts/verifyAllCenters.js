/**
 * Bulk-approves every medical center's verification status — mirrors exactly
 * what the admin "approve center" endpoint does (adminController.js), so a
 * center verified by this script is indistinguishable from one approved by
 * hand. For local/dev testing, not production use.
 *
 *   node scripts/verifyAllCenters.js              approve every non-approved center
 *   node scripts/verifyAllCenters.js --pending-only   only touch verificationStatus="pending"
 *   node scripts/verifyAllCenters.js --dry-run     report what would change, do nothing
 */

const mongoose = require("mongoose");
require("dotenv").config();

const { connectDB } = require("../config/database");
const MedicalCenter = require("../models/MedicalCenter");
const { deleteImageService } = require("../services/clopudinaryService");
const { notify } = require("../services/notifyService");

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const pendingOnly = args.includes("--pending-only");

(async () => {
  await connectDB();

  const query = pendingOnly
    ? { verificationStatus: "pending" }
    : { verificationStatus: { $ne: "approved" } };

  const centers = await MedicalCenter.find(query);

  if (centers.length === 0) {
    console.log("Nothing to verify — every center already matches.");
    await mongoose.connection.close();
    process.exit(0);
  }

  console.log(
    `${dryRun ? "[dry run] " : ""}found ${centers.length} center(s) to verify:\n`
  );

  for (const center of centers) {
    console.log(
      `  ${center.name}  (${center.verificationStatus} -> approved)` +
        (center.isVendorManaged ? "" : "  [no vendor assigned yet]")
    );
  }

  if (dryRun) {
    console.log("\n--dry-run set — no changes made.");
    await mongoose.connection.close();
    process.exit(0);
  }

  console.log();
  let touched = 0;

  for (const center of centers) {
    if (center.verificationDocuments && center.verificationDocuments.length > 0) {
      await Promise.all(
        center.verificationDocuments.map((doc) =>
          deleteImageService(doc.publicId).catch(() => null)
        )
      );
    }

    center.verificationStatus = "approved";
    center.isVerified = true;
    center.verifiedAt = new Date();
    center.verificationDocuments = [];
    center.verificationRejectionReason = null;
    await center.save();
    touched++;

    if (center.vendorUserId) {
      notify({
        recipientIds: [center.vendorUserId],
        type: "center_verified",
        title: "Center Verified",
        description: `Your medical center "${center.name}" has been verified and is now live.`,
        status: "important",
        entityType: "medical_center",
        entityId: center._id,
      });
    }
  }

  console.log(`verified ${touched} center(s).`);
  console.log(
    "\nNote: a center also needs isVendorManaged=true to accept donation " +
      "requests — this script only touches verification status."
  );

  await mongoose.connection.close();
  process.exit(0);
})().catch(async (err) => {
  console.error("FAILED:", err);
  process.exit(1);
});
