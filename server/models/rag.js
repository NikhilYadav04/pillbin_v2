const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const queryRAGSchema = new Schema({
  content: {
    type: String,
    required: true,
  },
  byUser: {
    type: Boolean,
    default: false,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const healthRAGSchema = new Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  pdfName: {
    type: String,
    required: true,
    trim: true,
  },
  pdfDescription: {
    type: String,
    required: false,
  },
  queries: [queryRAGSchema],

  uploadedAt: {
    type: Date,
    default: Date.now,
  },
});

healthRAGSchema.index({ userId: 1 });

const HealthRAG = mongoose.model("HealthRAG", healthRAGSchema);

module.exports = HealthRAG;
