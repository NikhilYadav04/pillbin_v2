const MedicalCenter = require("../models/MedicalCenter");
const User = require("../models/User");
const DonationRequest = require("../models/DonationRequest");
const { NotificationHelper } = require("../middleware/notificationHelper");
const {
  uploadImageService,
  deleteImageService,
} = require("../services/clopudinaryService");

//* Register or claim a medical center as a vendor
const registerCenter = async (req, res) => {
  try {
    const vendorId = req.user.id;

    //* Vendor can only manage one center
    if (req.user.vendorCenterId) {
      return res.status(400).json({
        statusCode: 400,
        message: "You are already managing a medical center",
      });
    }

    const {
      centerId, //* If claiming an existing center
      name,
      address,
      phoneNumber,
      location,
      facilityType,
      website,
      contactEmail,
      operatingHours,
      specialServices,
    } = req.body;

    let medicalCenter;

    if (centerId) {
      //* Claiming an existing center
      medicalCenter = await MedicalCenter.findById(centerId);
      if (!medicalCenter) {
        return res
          .status(404)
          .json({ statusCode: 404, message: "Medical center not found" });
      }
      if (medicalCenter.isVendorManaged) {
        return res.status(400).json({
          statusCode: 400,
          message: "This center is already claimed by another vendor",
        });
      }
    } else {
      //* Registering a brand new center
      if (!name || !address || !phoneNumber || !location) {
        return res.status(400).json({
          statusCode: 400,
          message: "name, address, phoneNumber, and location are required",
        });
      }

      let coordinates;
      if (location.coordinates && Array.isArray(location.coordinates)) {
        coordinates = location.coordinates;
      } else if (location.latitude && location.longitude) {
        coordinates = [location.longitude, location.latitude];
      } else if (
        location.coordinates &&
        location.coordinates.latitude &&
        location.coordinates.longitude
      ) {
        coordinates = [
          location.coordinates.longitude,
          location.coordinates.latitude,
        ];
      } else {
        return res
          .status(400)
          .json({ statusCode: 400, message: "Invalid location format" });
      }

      medicalCenter = new MedicalCenter({
        name,
        address,
        phoneNumber,
        location: { type: "Point", coordinates },
        facilityType: facilityType || "pharmacy",
        website,
        email: contactEmail,
        operatingHours: operatingHours || {},
        specialServices: specialServices || [],
        acceptedMedicineTypes: ["all"],
      });
    }

    //* Link vendor to center
    medicalCenter.vendorUserId = vendorId;
    medicalCenter.isVendorManaged = true;
    if (contactEmail) medicalCenter.email = contactEmail;
    await medicalCenter.save();

    //* Update user's vendorCenterId
    await User.findByIdAndUpdate(vendorId, {
      vendorCenterId: medicalCenter._id,
    });

    res.status(201).json({
      statusCode: 201,
      message: "Medical center registered successfully",
      data: { medicalCenter },
    });
  } catch (error) {
    console.error("Register center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get the vendor's own center details
const getMyCenter = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const medicalCenter = await MedicalCenter.findById(req.user.vendorCenterId);

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    res.status(200).json({
      statusCode: 200,
      data: { medicalCenter },
    });
  } catch (error) {
    console.error("Get my center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Update the vendor's center info
const updateMyCenter = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const medicalCenter = await MedicalCenter.findById(req.user.vendorCenterId);
    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    const allowedFields = [
      "name",
      "address",
      "phoneNumber",
      "operatingHours",
      "facilityType",
      "website",
      "email",
      "specialServices",
      "isActive",
      "acceptedMedicineTypes",
    ];

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        medicalCenter[field] = req.body[field];
      }
    });

    //* Handle location update
    if (req.body.location) {
      const loc = req.body.location;
      let coordinates;
      if (loc.coordinates && Array.isArray(loc.coordinates)) {
        coordinates = loc.coordinates;
      } else if (loc.latitude && loc.longitude) {
        coordinates = [loc.longitude, loc.latitude];
      }
      if (coordinates) {
        medicalCenter.location = { type: "Point", coordinates };
      }
    }

    await medicalCenter.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medical center updated successfully",
      data: { medicalCenter },
    });
  } catch (error) {
    console.error("Update my center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Update inventory (what medicines the center accepts)
const updateInventory = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const { inventory } = req.body;

    if (!Array.isArray(inventory)) {
      return res.status(400).json({
        statusCode: 400,
        message: "inventory must be an array",
      });
    }

    const medicalCenter = await MedicalCenter.findById(req.user.vendorCenterId);
    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    medicalCenter.inventory = inventory;
    await medicalCenter.save();

    res.status(200).json({
      statusCode: 200,
      message: "Inventory updated successfully",
      data: { inventory: medicalCenter.inventory },
    });
  } catch (error) {
    console.error("Update inventory error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get donation requests for this vendor's center
const getRequests = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const { status, page = 1, limit = 10 } = req.query;

    const query = { medicalCenterId: req.user.vendorCenterId };
    if (status) query.status = status;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [requests, total] = await Promise.all([
      DonationRequest.find(query)
        .populate("userId", "fullName email phoneNumber")
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
    console.error("Get requests error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Approve or reject a donation request
const updateRequestStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, vendorNote } = req.body;

    if (!["approved", "rejected"].includes(status)) {
      return res.status(400).json({
        statusCode: 400,
        message: "status must be 'approved' or 'rejected'",
      });
    }

    const request = await DonationRequest.findById(id);
    if (!request) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Request not found" });
    }

    //* Ensure this request belongs to the vendor's center
    if (
      request.medicalCenterId.toString() !==
      req.user.vendorCenterId.toString()
    ) {
      return res
        .status(403)
        .json({ statusCode: 403, message: "Not authorized" });
    }

    if (request.status !== "pending") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only pending requests can be approved or rejected",
      });
    }

    request.status = status;
    if (vendorNote) request.vendorNote = vendorNote;
    await request.save();

    //* Notify the user
    const center = await MedicalCenter.findById(req.user.vendorCenterId).select(
      "name"
    );
    const notificationMessage =
      status === "approved"
        ? `Your donation request to ${center.name} has been approved. ${vendorNote || ""}`
        : `Your donation request to ${center.name} was not accepted. ${vendorNote || ""}`;

    await NotificationHelper.createNotification(
      request.userId,
      status === "approved" ? "Donation Request Approved" : "Donation Request Rejected",
      notificationMessage
    );

    res.status(200).json({
      statusCode: 200,
      message: `Request ${status} successfully`,
      data: { request },
    });
  } catch (error) {
    console.error("Update request status error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Mark a request as completed (after pickup)
const completeRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const request = await DonationRequest.findById(id);
    if (!request) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Request not found" });
    }

    if (
      request.medicalCenterId.toString() !==
      req.user.vendorCenterId.toString()
    ) {
      return res
        .status(403)
        .json({ statusCode: 403, message: "Not authorized" });
    }

    if (request.status !== "approved") {
      return res.status(400).json({
        statusCode: 400,
        message: "Only approved requests can be marked as completed",
      });
    }

    request.status = "completed";
    await request.save();

    //* Increment center's donation count
    await MedicalCenter.findByIdAndUpdate(req.user.vendorCenterId, {
      $inc: { donationCount: 1 },
    });

    //* Update user's disposed medicine stats
    await User.findByIdAndUpdate(request.userId, {
      $inc: { "stats.medicinesDisposedCount": request.medicines.length },
    });

    res.status(200).json({
      statusCode: 200,
      message: "Request marked as completed",
      data: { request },
    });
  } catch (error) {
    console.error("Complete request error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Update center images (max 3) — uploads new, deletes old from Cloudinary
const updateCenterImages = async (req, res) => {
  try {
    const centerId = req.user.vendorCenterId;
    if (!centerId) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "No center found for this vendor" });
    }

    const center = await MedicalCenter.findById(centerId);
    if (!center) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    //* Parse which existing images the vendor wants to keep
    let keepPublicIds = [];
    if (req.body.keepPublicIds) {
      try {
        keepPublicIds = JSON.parse(req.body.keepPublicIds);
      } catch (_) {
        keepPublicIds = Array.isArray(req.body.keepPublicIds)
          ? req.body.keepPublicIds
          : [req.body.keepPublicIds];
      }
    }

    //* Separate kept images from removed ones
    const keptImages = center.images.filter((img) =>
      keepPublicIds.includes(img.publicId)
    );
    const removedImages = center.images.filter(
      (img) => !keepPublicIds.includes(img.publicId)
    );

    const incomingCount = (req.files || []).length;
    const totalAfter = keptImages.length + incomingCount;

    if (totalAfter > 3) {
      return res.status(400).json({
        statusCode: 400,
        message: `Maximum 3 images allowed. You are keeping ${keptImages.length} and adding ${incomingCount}.`,
      });
    }

    //* Delete only the removed images from Cloudinary
    if (removedImages.length > 0) {
      await Promise.all(
        removedImages.map((img) => deleteImageService(img.publicId))
      );
    }

    //* Upload new images
    const uploadedImages = [];
    for (const file of req.files || []) {
      const result = await uploadImageService(
        file,
        `medical_centers/${centerId}/photos`
      );
      uploadedImages.push({ url: result.secure_url, publicId: result.public_id });
    }

    center.images = [...keptImages, ...uploadedImages];
    await center.save();

    res.status(200).json({
      statusCode: 200,
      message: "Center images updated successfully",
      data: { images: center.images },
    });
  } catch (error) {
    console.error("Update center images error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Upload verification documents (e.g., license, registration) — sets status to 'pending'
const uploadVerificationDocs = async (req, res) => {
  try {
    const centerId = req.user.vendorCenterId;
    if (!centerId) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "No center found for this vendor" });
    }

    const center = await MedicalCenter.findById(centerId);
    if (!center) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    if (center.verificationStatus === "approved") {
      return res.status(400).json({
        statusCode: 400,
        message: "Center is already verified",
      });
    }

    if (!req.files || req.files.length === 0) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "No documents provided" });
    }

    //* Delete any previously uploaded verification docs
    if (center.verificationDocuments && center.verificationDocuments.length > 0) {
      await Promise.all(
        center.verificationDocuments.map((doc) =>
          deleteImageService(doc.publicId)
        )
      );
    }

    //* Upload new docs to medical_centers/verification/{centerId}/
    const uploadedDocs = [];
    for (const file of req.files) {
      const result = await uploadImageService(
        file,
        `medical_centers/verification/${centerId}`
      );
      uploadedDocs.push({
        url: result.secure_url,
        publicId: result.public_id,
        uploadedAt: new Date(),
      });
    }

    center.verificationDocuments = uploadedDocs;
    center.verificationStatus = "pending";
    center.verificationRejectionReason = null;
    await center.save();

    res.status(200).json({
      statusCode: 200,
      message: "Verification documents submitted. Review is in progress.",
      data: { verificationStatus: center.verificationStatus },
    });
  } catch (error) {
    console.error("Upload verification docs error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  registerCenter,
  getMyCenter,
  updateMyCenter,
  updateInventory,
  updateCenterImages,
  uploadVerificationDocs,
  getRequests,
  updateRequestStatus,
  completeRequest,
};
