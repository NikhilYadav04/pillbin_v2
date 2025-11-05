const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
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
    purchaseDate: {
      type: Date,
      required: true,
    },
    expiryDate: {
      type: Date,
      required: true,
    },
    status: {
      type: String,
      enum: ["active", "expiring_soon", "expired"],
      default: "active",
    },
    addedDate: {
      type: Date,
      default: Date.now,
    },
    notes: {
      type: String,
      trim: true,
    },
    dosage: {
      type: String,
      trim: true,
    },
    manufacturer: {
      type: String,
      trim: true,
    },
    type: {
      type: String,
      trim: true,
    },
    batchNumber: {
      type: String,
      trim: true,
    },
    isDeleted: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

//* Index for efficient querying
medicineSchema.index({ userId: 1, status: 1 });
medicineSchema.index({ expiryDate: 1 });

//* Method to update medicine status based on expiry date
medicineSchema.methods.updateStatus = function () {
  const now = new Date();
  const expiryDate = new Date(this.expiryDate);
  const daysUntilExpiry = Math.ceil((expiryDate - now) / (1000 * 60 * 60 * 24));

  if (daysUntilExpiry <= 0) {
    this.status = "expired";
  } else if (daysUntilExpiry <= 5) {
    this.status = "expiring_soon";
  } else {
    this.status = "active";
  }

  return this.status;
};

//* Static method to update all medicines status
medicineSchema.statics.updateAllStatuses = async function () {
  const medicines = await this.find({});

  for (let medicine of medicines) {
    const oldStatus = medicine.status;
    medicine.updateStatus();

    if (oldStatus !== medicine.status) {
      await medicine.save();
    }
  }
};

//* Static method to clean up expired medicines (remove after 2 days of expiry)
medicineSchema.statics.cleanupExpiredMedicines = async function () {
  const twoDaysAgo = new Date();
  twoDaysAgo.setDate(twoDaysAgo.getDate() - 15);

  const result = await this.deleteMany({
    status: "expired",
    expiryDate: { $lt: twoDaysAgo },
  });

  return result.deletedCount;
};

module.exports = mongoose.model("Medicine", medicineSchema);
