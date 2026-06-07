// models/blog.model.js
const mongoose = require("mongoose");

const blogSchema = new mongoose.Schema(
  {
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    content: {
      type: String,
      required: true,
      maxlength: 10000,
    },
    role: {
      type: String,
      enum: ["normal", "doctor", "expert", "educator", "student"],
      required: true,
    },
    experience: {
      type: String,
      maxlength: 500,
    },
    phone: {
      type: String,
      maxlength: 20,
    },
    name: {
      type: String,
      maxlength: 20,
    },
    email: {
      type: String,
      maxlength: 100,
      lowercase: true,
      trim: true,
    },
    images: [
      {
        url: {
          type: String,
          required: true,
        },
        publicId: {
          type: String,
          required: true,
        },
      },
    ],
    likesCount: {
      type: Number,
      default: 0,
      index: true,
    },
    commentsCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

blogSchema.index({ createdAt: -1 });
blogSchema.index({ author: 1, createdAt: -1 });

module.exports = mongoose.model("Blog", blogSchema);
