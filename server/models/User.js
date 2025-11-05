const mongoose = require("mongoose");

const badgeSchema = new mongoose.Schema({
  firstTimer: {
    achieved: { type: Boolean, default: false },
    unlockedAt: { type: Date },
  },
  ecoHelper: {
    achieved: { type: Boolean, default: false },
    unlockedAt: { type: Date },
  },
  greenChampion: {
    achieved: { type: Boolean, default: false },
    unlockedAt: { type: Date },
  },
});

const userSchema = new mongoose.Schema(
  {
    phoneNumber: {
      type: String,
      trim: true,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    otp: {
      code: String,
      expiresAt: Date,
    },
    // Profile Details
    fullName: {
      type: String,
      trim: true,
    },
    email: {
      required: true,
      type: String,
      trim: true,
      lowercase: true,
      unique: true,
    },
    // Optional Medical Details
    currentMedicines: [
      {
        name: String,
        dosage: String,
        frequency: String,
      },
    ],
    medicalConditions: [
      {
        condition: String,
        severity: String,
      },
    ],
    location: {
      name: String,
      coordinates: {
        latitude: Number,
        longitude: Number,
      },
    },
    medicineCount: {
      type: Number,
      default: 0,
    },
    // Profile Statistics (default 0)
    stats: {
      totalMedicinesTracked: { type: Number, default: 0 },
      expiringSoonCount: { type: Number, default: 0 },
      medicinesDisposedCount: { type: Number, default: 0 },
      campaignsJoinedCount: { type: Number, default: 0 },
    },
    // Badges
    badges: {
      type: badgeSchema,
      default: () => ({}),
    },
    // Saved Medical Centers
    savedMedicalCenters: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "MedicalCenter",
      },
    ],
    profileCompleted: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

//* Method to update badge achievements
userSchema.methods.updateBadges = function () {
  //* First Timer - dispose 1st medicine
  if (
    this.stats.medicinesDisposedCount >= 1 &&
    !this.badges.firstTimer.achieved
  ) {
    this.badges.firstTimer.achieved = true;
    this.badges.firstTimer.unlockedAt = new Date();
  }

  //* Eco Helper - dispose 5 medicines
  if (
    this.stats.medicinesDisposedCount >= 5 &&
    !this.badges.ecoHelper.achieved
  ) {
    this.badges.ecoHelper.achieved = true;
    this.badges.ecoHelper.unlockedAt = new Date();
  }

  //* Green Champion - dispose 20 medicines
  if (
    this.stats.medicinesDisposedCount >= 20 &&
    !this.badges.greenChampion.achieved
  ) {
    this.badges.greenChampion.achieved = true;
    this.badges.greenChampion.unlockedAt = new Date();
  }
};

module.exports = mongoose.model("User", userSchema);
