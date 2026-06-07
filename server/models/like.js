// models/like.model.js
const mongoose = require("mongoose");

const likeSchema = new mongoose.Schema(
  {
    blog: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Blog",
      required: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Ensures one like per user per blog — also serves as the lookup index
likeSchema.index({ blog: 1, user: 1 }, { unique: true });

// For "all blogs liked by a user" queries
likeSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model("Like", likeSchema);
