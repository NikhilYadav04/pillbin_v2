const mongoose = require("mongoose");

const centerReviewSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    medicalCenterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MedicalCenter",
      required: true,
    },
    donationRequestId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DonationRequest",
      required: true,
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      trim: true,
      maxlength: 500,
    },
  },
  {
    timestamps: true,
  }
);

//* One review per completed donation
centerReviewSchema.index({ donationRequestId: 1 }, { unique: true });
centerReviewSchema.index({ medicalCenterId: 1, createdAt: -1 });
centerReviewSchema.index({ medicalCenterId: 1, rating: 1, createdAt: -1 });

module.exports = mongoose.model("CenterReview", centerReviewSchema);
