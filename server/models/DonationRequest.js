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
      enum: ["pending", "approved", "rejected", "completed"],
      default: "pending",
    },
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
donationRequestSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model("DonationRequest", donationRequestSchema);
