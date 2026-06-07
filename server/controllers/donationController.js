const DonationRequest = require("../models/DonationRequest");
const MedicalCenter = require("../models/MedicalCenter");
const { NotificationHelper } = require("../middleware/notificationHelper");
const {
  uploadImageService,
  deleteImageService,
} = require("../services/clopudinaryService");

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

    if (!medicalCenterId || !medicines || !medicines.length) {
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
    });

    await request.save();

    //* Notify the vendor if center is vendor-managed
    if (center.isVendorManaged && center.vendorUserId) {
      await NotificationHelper.createNotification(
        center.vendorUserId,
        "New Donation Request",
        `A new donation request has been submitted to ${center.name}`
      );
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
    const { status, page = 1, limit = 10 } = req.query;

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

    res.status(200).json({
      statusCode: 200,
      data: {
        requests,
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

    //* Delete medicine photos from Cloudinary
    if (request.medicinePhotos && request.medicinePhotos.length > 0) {
      await Promise.all(
        request.medicinePhotos.map((p) => deleteImageService(p.publicId))
      );
    }

    await DonationRequest.findByIdAndDelete(id);

    res.status(200).json({
      statusCode: 200,
      message: "Request cancelled successfully",
    });
  } catch (error) {
    console.error("Cancel request error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  submitRequest,
  getMyRequests,
  getRequestById,
  cancelRequest,
};
