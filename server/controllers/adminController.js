const MedicalCenter = require("../models/MedicalCenter");
const { deleteImageService } = require("../services/clopudinaryService");
const { notify } = require("../services/notifyService");

//* List all centers with pending verification
const getPendingVerifications = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [centers, total] = await Promise.all([
      MedicalCenter.find({ verificationStatus: "pending" })
        .select("name address facilityType verificationDocuments verificationStatus createdAt vendorUserId")
        .populate("vendorUserId", "fullName email phoneNumber")
        .sort({ updatedAt: 1 })
        .skip(skip)
        .limit(parseInt(limit)),
      MedicalCenter.countDocuments({ verificationStatus: "pending" }),
    ]);

    res.status(200).json({
      statusCode: 200,
      data: {
        centers,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / parseInt(limit)),
          total,
        },
      },
    });
  } catch (error) {
    console.error("Get pending verifications error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Approve a center's verification — deletes uploaded docs from Cloudinary
const approveVerification = async (req, res) => {
  try {
    const { centerId } = req.params;

    const center = await MedicalCenter.findById(centerId);
    if (!center) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    if (center.verificationStatus !== "pending") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only pending centers can be approved",
      });
    }

    //* Delete verification docs from Cloudinary (no longer needed)
    if (center.verificationDocuments && center.verificationDocuments.length > 0) {
      await Promise.all(
        center.verificationDocuments.map((doc) =>
          deleteImageService(doc.publicId)
        )
      );
    }

    center.verificationStatus = "approved";
    center.isVerified = true;
    center.verifiedAt = new Date();
    center.verificationDocuments = [];
    center.verificationRejectionReason = null;
    await center.save();

    //* Notify the vendor
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

    res.status(200).json({
      statusCode: 200,
      message: "Center verified successfully",
      data: { verificationStatus: center.verificationStatus },
    });
  } catch (error) {
    console.error("Approve verification error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Reject a center's verification — stores reason, keeps docs for re-submission reference
const rejectVerification = async (req, res) => {
  try {
    const { centerId } = req.params;
    const { reason } = req.body;

    if (!reason || !reason.trim()) {
      return res.status(400).json({
        statusCode: 400,
        message: "A rejection reason is required",
      });
    }

    const center = await MedicalCenter.findById(centerId);
    if (!center) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    if (center.verificationStatus !== "pending") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only pending centers can be rejected",
      });
    }

    //* Delete the submitted docs — vendor must re-upload on next attempt
    if (center.verificationDocuments && center.verificationDocuments.length > 0) {
      await Promise.all(
        center.verificationDocuments.map((doc) =>
          deleteImageService(doc.publicId)
        )
      );
    }

    center.verificationStatus = "rejected";
    center.verificationDocuments = [];
    center.verificationRejectionReason = reason.trim();
    await center.save();

    //* Notify the vendor
    if (center.vendorUserId) {
      notify({
        recipientIds: [center.vendorUserId],
        type: "center_verification_rejected",
        title: "Verification Not Approved",
        description: `Your center "${center.name}" verification was not approved. Reason: ${reason.trim()}`,
        status: "important",
        entityType: "medical_center",
        entityId: center._id,
      });
    }

    res.status(200).json({
      statusCode: 200,
      message: "Center verification rejected",
      data: { verificationStatus: center.verificationStatus },
    });
  } catch (error) {
    console.error("Reject verification error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  getPendingVerifications,
  approveVerification,
  rejectVerification,
};
