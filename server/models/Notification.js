const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      maxlength: 1000,
    },
    status: {
      type: String,
      enum: ["important", "normal", "urgent", "alert"],
      default: "normal",
      required: true,
    },
    type: {
      type: String,
      required: true,
      trim: true,
    },
    entityType: {
      type: String,
      trim: true,
      default: null,
    },
    entityId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null,
    },
    dedupKey: {
      type: String,
    },
    groupKey: {
      type: String,
      default: null,
    },
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

//* Index for efficient querying
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ dedupKey: 1 }, { unique: true, sparse: true });
notificationSchema.index({ userId: 1, groupKey: 1 });

//* Update the updatedAt field before saving
notificationSchema.pre("save", function (next) {
  this.updatedAt = new Date();
  next();
});

module.exports = mongoose.model("Notification", notificationSchema);
