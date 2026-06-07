const mongoose = require("mongoose");

const commentSchema = new mongoose.Schema(
  {
    blog: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Blog",
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: {
      type: String,
      required: true,
      maxlength: 2000,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Primary query: comments for a blog, newest first
commentSchema.index({ blog: 1, createdAt: -1 });

// Author's comment history
commentSchema.index({ author: 1, createdAt: -1 });

module.exports = mongoose.model("Comment", commentSchema);
