const mongoose = require("mongoose");

const deviceTokenSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    fcmToken: {
      type: String,
      required: true,
      unique: true,
    },
    deviceId: {
      type: String,
      default: null,
    },
    deviceType: {
      type: String,
      enum: ["android", "ios", "web"],
      default: "android",
    },
    deviceModel: {
      type: String,
      trim: true,
      default: null,
    },
    appVersion: {
      type: String,
      trim: true,
      default: null,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

deviceTokenSchema.index({ userId: 1, isActive: 1 });
deviceTokenSchema.index({ deviceId: 1, isActive: 1 });

module.exports = mongoose.model("DeviceToken", deviceTokenSchema);
