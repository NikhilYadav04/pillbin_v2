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
    lastNotifiedStatus: {
      type: String,
      enum: ["expiring_soon", "expired", null],
      default: null,
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
    image: {
      url: {
        type: String,
        default: null,
      },
      publicId: {
        type: String,
        default: null,
      },
    },
    productLinks: {
      tata1mg: { type: String },
      pharmeasy: { type: String },
      netmeds: { type: String },
    },
    isDeleted: {
      type: Boolean,
      default: false,
    },
    familyMemberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "FamilyMember",
      default: null,
    },
    isRecurring: {
      type: Boolean,
      default: false,
    },
    refillIntervalDays: {
      type: Number,
      min: 1,
      default: null,
    },
    nextRefillAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

//* Index for efficient querying
medicineSchema.index({ userId: 1, status: 1 });
medicineSchema.index({ expiryDate: 1 });
medicineSchema.index({ status: 1, lastNotifiedStatus: 1, isDeleted: 1 });
medicineSchema.index({ isRecurring: 1, nextRefillAt: 1, isDeleted: 1 });
medicineSchema.index({ userId: 1, familyMemberId: 1 });

medicineSchema.methods.applyRecurrence = function (isRecurring, refillIntervalDays) {
  if (isRecurring === undefined && refillIntervalDays === undefined) return;

  const nextIsRecurring =
    isRecurring !== undefined ? Boolean(isRecurring) : this.isRecurring;
  const nextInterval =
    refillIntervalDays !== undefined
      ? refillIntervalDays === null
        ? null
        : Number(refillIntervalDays)
      : this.refillIntervalDays;

  this.isRecurring = nextIsRecurring;
  this.refillIntervalDays = nextIsRecurring ? nextInterval : null;

  if (this.isRecurring && this.refillIntervalDays > 0) {
    const base = this.addedDate || new Date();
    this.nextRefillAt = new Date(
      base.getTime() + this.refillIntervalDays * 24 * 60 * 60 * 1000
    );
  } else {
    this.nextRefillAt = null;
  }
};

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
  const medicines = await this.find({ isDeleted: false });
  const transitions = [];

  for (let medicine of medicines) {
    const previousStatus = medicine.status;
    medicine.updateStatus();

    if (previousStatus !== medicine.status) {
      await medicine.save();
      transitions.push({
        medicineId: medicine._id,
        userId: medicine.userId,
        name: medicine.name,
        previousStatus,
        status: medicine.status,
      });
    }
  }

  return transitions;
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
