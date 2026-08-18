const mongoose = require("mongoose");

const medicalCenterSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    address: {
      type: String,
      required: true,
      trim: true,
    },
    phoneNumber: {
      type: String,
      required: true,
      trim: true,
    },
    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },
      coordinates: {
        type: [Number], //* [longitude, latitude] - GeoJSON format
        required: true,
        // removed: index: "2dsphere"
      },
    },
    distance: {
      type: Number, //* Will be calculated dynamically when searching
      default: 0,
    },
    //* Additional fields for medicine disposal
    acceptedMedicineTypes: [
      {
        type: String,
        enum: [
          "tablets",
          "capsules",
          "syrups",
          "injections",
          "ointments",
          "inhalers",
          "drops",
          "all",
        ],
        default: "all",
      },
    ],
    operatingHours: {
      monday: { open: String, close: String },
      tuesday: { open: String, close: String },
      wednesday: { open: String, close: String },
      thursday: { open: String, close: String },
      friday: { open: String, close: String },
      saturday: { open: String, close: String },
      sunday: { open: String, close: String },
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0,
    },
    totalReviews: {
      type: Number,
      default: 0,
    },
    //* Running totals so a rating change is an $inc, never a recount
    ratingSum: {
      type: Number,
      default: 0,
    },
    ratingBreakdown: {
      1: { type: Number, default: 0 },
      2: { type: Number, default: 0 },
      3: { type: Number, default: 0 },
      4: { type: Number, default: 0 },
      5: { type: Number, default: 0 },
    },
    //* Bayesian-adjusted rating used for ranking — an unrated center sits at
    //* the neutral prior instead of below every 1-star center
    weightedRating: {
      type: Number,
      default: 3.5,
    },
    facilityType: {
      type: String,
      enum: ["hospital", "clinic", "pharmacy", "health_center"],
      default: "pharmacy",
    },
    website: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
    },
    specialServices: [
      {
        type: String,
      },
    ],
    //* Vendor ownership
    vendorUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    isVendorManaged: {
      type: Boolean,
      default: false,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    //* Rich inventory: what categories/medicines this center accepts
    inventory: [
      {
        category: {
          type: String,
          required: true,
          trim: true,
        },
        specificNames: [{ type: String, trim: true }],
        acceptanceStatus: {
          type: String,
          enum: ["accepting", "full", "not_accepting"],
          default: "accepting",
        },
        notes: {
          type: String,
          trim: true,
        },
      },
    ],
    donationCount: {
      type: Number,
      default: 0,
    },
    images: [
      {
        url: { type: String, required: true },
        publicId: { type: String, required: true },
      },
    ],
    //* Vendor verification
    verificationStatus: {
      type: String,
      enum: ["unverified", "pending", "approved", "rejected"],
      default: "unverified",
    },
    verificationDocuments: [
      {
        url: { type: String, required: true },
        publicId: { type: String, required: true },
        uploadedAt: { type: Date, default: Date.now },
      },
    ],
    verifiedAt: {
      type: Date,
      default: null,
    },
    verificationRejectionReason: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

//* Index for geospatial queries
medicalCenterSchema.index({ location: "2dsphere" });

//* Static method to find medical centers within radius
medicalCenterSchema.statics.findNearby = async function (
  latitude,
  longitude,
  radiusKm = 10
) {
  const radiusInMeters = radiusKm * 1000;

  const centers = await this.aggregate([
    {
      $geoNear: {
        near: {
          type: "Point",
          coordinates: [longitude, latitude], //* GeoJSON uses [lng, lat] format
        },
        distanceField: "distance",
        maxDistance: radiusInMeters,
        spherical: true,
        query: {
          isActive: true,
          $or: [
            { isVendorManaged: false },
            { isVendorManaged: true, verificationStatus: "approved" },
          ],
        },
      },
    },
    {
      $addFields: {
        distance: { $round: [{ $divide: ["$distance", 1000] }, 2] }, //* Convert to km and round to 2 decimal places
      },
    },
    {
      $sort: { distance: 1 },
    },
  ]);

  return centers;
};

//* Pre-save middleware to ensure coordinates are in correct format
medicalCenterSchema.pre("save", function (next) {
  if (this.location && this.location.coordinates) {
    //* Ensure coordinates are numbers and in [lng, lat] format
    if (
      Array.isArray(this.location.coordinates) &&
      this.location.coordinates.length === 2
    ) {
      this.location.coordinates = [
        parseFloat(this.location.coordinates[0]), //* longitude
        parseFloat(this.location.coordinates[1]), //* latitude
      ];
    }
  }
  next();
});

module.exports = mongoose.model("MedicalCenter", medicalCenterSchema);
