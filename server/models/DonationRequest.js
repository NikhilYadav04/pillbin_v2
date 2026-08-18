const mongoose = require("mongoose");

const donationRequestSchema = new mongoose.Schema(
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
    medicines: [
      {
        medicineId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Medicine",
        },
        name: { type: String, required: true, trim: true },
        category: { type: String, trim: true },
        quantity: { type: String, trim: true },
        expiryDate: { type: Date },
        condition: {
          type: String,
          enum: ["sealed", "opened", "unknown"],
          default: "unknown",
        },
      },
    ],
    status: {
      type: String,
      enum: ["pending", "approved", "rejected", "completed", "cancelled"],
      default: "pending",
    },
    statusHistory: [
      {
        status: { type: String, required: true },
        at: { type: Date, default: Date.now },
        by: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        note: { type: String, trim: true },
      },
    ],
    userNote: {
      type: String,
      trim: true,
    },
    vendorNote: {
      type: String,
      trim: true,
    },
    contactPreference: {
      type: String,
      enum: ["call", "visit", "either"],
      default: "either",
    },
    scheduledDate: {
      type: Date,
    },
    medicinePhotos: [
      {
        url: { type: String, required: true },
        publicId: { type: String, required: true },
      },
    ],
  },
  {
    timestamps: true,
  }
);

//* Index for fast lookups by center and status
donationRequestSchema.index({ medicalCenterId: 1, status: 1 });
donationRequestSchema.index({ medicalCenterId: 1, createdAt: -1 });
donationRequestSchema.index({ userId: 1, createdAt: -1 });
//* Status-filtered pages sort by date — without createdAt in the index the
//* filtered tabs sort the whole matching set in memory on every page
donationRequestSchema.index({ medicalCenterId: 1, status: 1, createdAt: -1 });
donationRequestSchema.index({ userId: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model("DonationRequest", donationRequestSchema);
