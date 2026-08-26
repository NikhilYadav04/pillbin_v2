const mongoose = require("mongoose");

const familyMemberSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    relation: {
      type: String,
      trim: true,
    },
  },
  { timestamps: true }
);

familyMemberSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model("FamilyMember", familyMemberSchema);
