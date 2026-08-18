const DonationRequest = require("../models/DonationRequest");
const MedicalCenter = require("../models/MedicalCenter");
const CenterReview = require("../models/CenterReview");
const { notify } = require("../services/notifyService");
const {
  uploadImageService,
  deleteImageService,
} = require("../services/clopudinaryService");

const MAX_PENDING_PER_CENTER = 3;

//* Submit a donation request
const submitRequest = async (req, res) => {
  try {
    const {
      medicalCenterId,
      medicines,
      userNote,
      contactPreference,
      scheduledDate,
    } = req.body;

    if (!medicalCenterId || !Array.isArray(medicines) || !medicines.length) {
      return res.status(400).json({
        statusCode: 400,
        message: "medicalCenterId and at least one medicine are required",
      });
    }

    const center = await MedicalCenter.findById(medicalCenterId);
    if (!center || !center.isActive) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    //* Only verified vendor-managed centers can receive requests —
    //* others have nobody able to approve them
    if (!center.isVendorManaged || center.verificationStatus !== "approved") {
      return res.status(400).json({
        statusCode: 400,
        message: "This center is not accepting donation requests",
      });
    }

    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const expiredNames = medicines
      .filter((m) => m.expiryDate && new Date(m.expiryDate) < startOfToday)
      .map((m) => m.name);

    if (expiredNames.length > 0) {
      return res.status(400).json({
        statusCode: 400,
        message: `Expired medicines cannot be donated: ${expiredNames.join(", ")}`,
      });
    }

    const pendingCount = await DonationRequest.countDocuments({
      userId: req.user.id,
      medicalCenterId,
      status: "pending",
    });

    if (pendingCount >= MAX_PENDING_PER_CENTER) {
      return res.status(429).json({
        statusCode: 429,
        message: `You already have ${pendingCount} pending requests with this center`,
      });
    }

    //* Upload medicine photos if provided (max 2)
    let medicinePhotos = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const result = await uploadImageService(
          file,
          `donations/${req.user.id}`
        );
        medicinePhotos.push({
          url: result.secure_url,
          publicId: result.public_id,
        });
      }
    }

    const request = new DonationRequest({
      userId: req.user.id,
      medicalCenterId,
      medicines,
      userNote,
      contactPreference: contactPreference || "either",
      scheduledDate: scheduledDate ? new Date(scheduledDate) : undefined,
      medicinePhotos,
      statusHistory: [{ status: "pending", by: req.user.id }],
    });

    await request.save();

    //* Notify the vendor if center is vendor-managed
    if (center.isVendorManaged && center.vendorUserId) {
      notify({
        recipientIds: [center.vendorUserId],
        type: "donation_submitted",
        title: "New Donation Request",
        description: `A new donation request has been submitted to ${center.name}`,
        status: "important",
        entityType: "donation_request",
        entityId: request._id,
      });
    }

    res.status(201).json({
      statusCode: 201,
      message: "Donation request submitted successfully",
      data: { request },
    });
  } catch (error) {
    console.error("Submit request error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get the logged-in user's donation requests
const getMyRequests = async (req, res) => {
  try {
    const { status, page = 1 } = req.query;
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 50);

    const query = { userId: req.user.id };
    if (status) query.status = status;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [requests, total] = await Promise.all([
      DonationRequest.find(query)
        .populate("medicalCenterId", "name address phoneNumber email facilityType")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      DonationRequest.countDocuments(query),
    ]);

    //* Attach the user's own review so the client knows what's already rated
    const reviews = await CenterReview.find({
      donationRequestId: { $in: requests.map((r) => r._id) },
    }).select("donationRequestId rating comment");

    const reviewByRequest = new Map(
      reviews.map((r) => [r.donationRequestId.toString(), r])
    );

    const withReviews = requests.map((r) => {
      const plain = r.toObject();
      const review = reviewByRequest.get(r._id.toString());
      if (review) {
        plain.myReview = {
          _id: review._id,
          rating: review.rating,
          comment: review.comment,
        };
      }
      return plain;
    });

    res.status(200).json({
      statusCode: 200,
      data: {
        requests: withReviews,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / parseInt(limit)),
          total,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Get my requests error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get a single request by ID
const getRequestById = async (req, res) => {
  try {
    const { id } = req.params;

    const request = await DonationRequest.findById(id)
      .populate("medicalCenterId", "name address phoneNumber email facilityType inventory")
      .populate("userId", "fullName email");

    if (!request) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Request not found" });
    }

    //* Only the requesting user or the vendor of the center can view it
    const isOwner = request.userId._id.toString() === req.user.id.toString();
    const isVendor =
      req.user.vendorCenterId &&
      request.medicalCenterId._id.toString() ===
        req.user.vendorCenterId.toString();

    if (!isOwner && !isVendor) {
      return res.status(403).json({ statusCode: 403, message: "Not authorized" });
    }

    res.status(200).json({
      statusCode: 200,
      data: { request },
    });
  } catch (error) {
    console.error("Get request by id error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Cancel a pending request (user only)
const cancelRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const request = await DonationRequest.findById(id);
    if (!request) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Request not found" });
    }

    if (request.userId.toString() !== req.user.id.toString()) {
      return res.status(403).json({ statusCode: 403, message: "Not authorized" });
    }

    if (request.status !== "pending") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only pending requests can be cancelled",
      });
    }

    //* Free the storage but keep the record for the audit trail
    if (request.medicinePhotos && request.medicinePhotos.length > 0) {
      await Promise.all(
        request.medicinePhotos.map((p) => deleteImageService(p.publicId))
      );
      request.medicinePhotos = [];
    }

    request.status = "cancelled";
    request.statusHistory.push({ status: "cancelled", by: req.user.id });
    await request.save();

    //* Notify the vendor if center is vendor-managed
    const center = await MedicalCenter.findById(request.medicalCenterId).select(
      "name isVendorManaged vendorUserId"
    );
    if (center && center.isVendorManaged && center.vendorUserId) {
      notify({
        recipientIds: [center.vendorUserId],
        type: "donation_cancelled",
        title: "Donation Request Cancelled",
        description: `A pending donation request to ${center.name} was cancelled by the donor.`,
        status: "normal",
        entityType: "donation_request",
        entityId: request._id,
      });
    }

    res.status(200).json({
      statusCode: 200,
      message: "Request cancelled successfully",
      data: { request },
    });
  } catch (error) {
    console.error("Cancel request error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Confidence constant — how many reviews before a center's own average
//* outweighs the neutral prior
const RATING_CONFIDENCE = 5;
const NEUTRAL_PRIOR = 3.5;

//* Applies one review's arrival (+1) or removal (-1) as running totals, then
//* derives the averages from them. No aggregation, so cost is flat no matter
//* how many reviews the center has.
const applyRatingDelta = async (medicalCenterId, rating, direction) => {
  const center = await MedicalCenter.findByIdAndUpdate(
    medicalCenterId,
    {
      $inc: {
        ratingSum: rating * direction,
        totalReviews: direction,
        [`ratingBreakdown.${rating}`]: direction,
      },
    },
    { new: true }
  );

  if (!center) return;

  //* Guard against drift from any legacy row written before counters existed
  const count = Math.max(center.totalReviews, 0);
  const sum = Math.max(center.ratingSum, 0);
  const average = count > 0 ? sum / count : 0;
  const weighted =
    (RATING_CONFIDENCE * NEUTRAL_PRIOR + sum) / (RATING_CONFIDENCE + count);

  await MedicalCenter.findByIdAndUpdate(medicalCenterId, {
    rating: Math.round(average * 10) / 10,
    totalReviews: count,
    ratingSum: sum,
    weightedRating: Math.round(weighted * 100) / 100,
  });
};

//* Review a completed donation
const submitReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;

    const numericRating = Number(rating);
    if (!Number.isInteger(numericRating) || numericRating < 1 || numericRating > 5) {
      return res.status(400).json({
        statusCode: 400,
        message: "rating must be a whole number between 1 and 5",
      });
    }

    const request = await DonationRequest.findById(id);
    if (!request) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Request not found" });
    }

    if (request.userId.toString() !== req.user.id.toString()) {
      return res
        .status(403)
        .json({ statusCode: 403, message: "Not authorized" });
    }

    if (request.status !== "completed") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only completed donations can be reviewed",
      });
    }

    const existing = await CenterReview.findOne({ donationRequestId: id });
    if (existing) {
      return res.status(409).json({
        statusCode: 409,
        message: "You have already reviewed this donation",
      });
    }

    const review = await CenterReview.create({
      userId: req.user.id,
      medicalCenterId: request.medicalCenterId,
      donationRequestId: id,
      rating: numericRating,
      comment,
    });

    await applyRatingDelta(request.medicalCenterId, numericRating, 1);

    res.status(201).json({
      statusCode: 201,
      message: "Review submitted successfully",
      data: { review },
    });
  } catch (error) {
    //* Unique index guards against a double submit racing the check above
    if (error.code === 11000) {
      return res.status(409).json({
        statusCode: 409,
        message: "You have already reviewed this donation",
      });
    }
    console.error("Submit review error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete your own review
const deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;

    const review = await CenterReview.findById(reviewId);
    if (!review) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Review not found" });
    }

    if (review.userId.toString() !== req.user.id.toString()) {
      return res
        .status(403)
        .json({ statusCode: 403, message: "Not authorized" });
    }

    const { medicalCenterId, rating } = review;
    await CenterReview.findByIdAndDelete(reviewId);
    await applyRatingDelta(medicalCenterId, rating, -1);

    res.status(200).json({
      statusCode: 200,
      message: "Review deleted successfully",
    });
  } catch (error) {
    console.error("Delete review error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Reviews for a center, newest first
const getCenterReviews = async (req, res) => {
  try {
    const { centerId } = req.params;
    const { page = 1 } = req.query;
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 50);
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const star = parseInt(req.query.rating, 10);
    const query = { medicalCenterId: centerId };
    if (star >= 1 && star <= 5) query.rating = star;

    const [reviews, total, center] = await Promise.all([
      CenterReview.find(query)
        .populate("userId", "fullName")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      CenterReview.countDocuments(query),
      MedicalCenter.findById(centerId).select(
        "rating totalReviews ratingBreakdown"
      ),
    ]);

    //* Flag the caller's own review so the client can offer delete
    const withOwnership = reviews.map((r) => {
      const plain = r.toObject();
      plain.isMine = r.userId && r.userId._id
        ? r.userId._id.toString() === req.user.id.toString()
        : false;
      return plain;
    });

    const breakdown = [1, 2, 3, 4, 5].reduce((acc, s) => {
      acc[s] = center?.ratingBreakdown?.[s] || 0;
      return acc;
    }, {});

    res.status(200).json({
      statusCode: 200,
      data: {
        reviews: withOwnership,
        summary: {
          rating: center ? center.rating : 0,
          totalReviews: center ? center.totalReviews : 0,
          ratingBreakdown: breakdown,
        },
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(total / parseInt(limit)),
          total,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Get center reviews error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  submitRequest,
  getMyRequests,
  getRequestById,
  cancelRequest,
  submitReview,
  deleteReview,
  getCenterReviews,
};
