const mongoose = require("mongoose");
const MedicalCenter = require("../models/MedicalCenter");
const User = require("../models/User");
const DonationRequest = require("../models/DonationRequest");
const Medicine = require("../models/Medicine");
const CenterReview = require("../models/CenterReview");
const { notify } = require("../services/notifyService");
const { verifyHandoffToken } = require("../utils/jwt");
const { runInTransaction } = require("../utils/transaction");
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

    const { status, page = 1 } = req.query;
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 50);

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
    request.statusHistory.push({
      status,
      by: req.user.id,
      note: vendorNote,
    });
    await request.save();

    //* Notify the user
    const center = await MedicalCenter.findById(req.user.vendorCenterId).select(
      "name"
    );
    const notificationMessage =
      status === "approved"
        ? `Your donation request to ${center.name} has been approved. ${vendorNote || ""}`
        : `Your donation request to ${center.name} was not accepted. ${vendorNote || ""}`;

    notify({
      recipientIds: [request.userId],
      type: status === "approved" ? "donation_approved" : "donation_rejected",
      title:
        status === "approved"
          ? "Donation Request Approved"
          : "Donation Request Rejected",
      description: notificationMessage.trim(),
      status: "important",
      entityType: "donation_request",
      entityId: request._id,
    });

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
//* Shared by the manual button and the QR scan so the two can never drift.
//* The four writes move together or not at all — a half-applied completion
//* leaves the donor's medicines in their inventory with no way to notice.
const finalizeCompletion = async (request, vendorUserId, vendorCenterId) => {
  const { disposedCount, centerName } = await runInTransaction(
    async (session) => {
      request.status = "completed";
      request.statusHistory.push({ status: "completed", by: vendorUserId });
      await request.save({ session });

      //* Remove the donated medicines from the donor's inventory
      const donatedIds = request.medicines
        .map((m) => m.medicineId)
        .filter(Boolean);

      if (donatedIds.length > 0) {
        await Medicine.updateMany(
          {
            _id: { $in: donatedIds },
            userId: request.userId,
            isDeleted: false,
          },
          { $set: { isDeleted: true } },
          { session }
        );
      }

      //* Increment center's donation count
      const center = await MedicalCenter.findByIdAndUpdate(
        vendorCenterId,
        { $inc: { donationCount: 1 } },
        { new: true, session }
      ).select("name");

      //* Count actual units where quantity is numeric, else one per entry
      const units = request.medicines.reduce((sum, m) => {
        const parsed = parseInt(m.quantity, 10);
        return sum + (Number.isNaN(parsed) || parsed < 1 ? 1 : parsed);
      }, 0);

      await User.findByIdAndUpdate(
        request.userId,
        { $inc: { "stats.medicinesDisposedCount": units } },
        { session }
      );

      return { disposedCount: units, centerName: center ? center.name : null };
    }
  );

  //* Outside the transaction on purpose — withTransaction retries its callback,
  //* and a retry here would push the same notification twice
  notify({
    recipientIds: [request.userId],
    type: "donation_completed",
    title: "Donation Completed",
    description: `Your donation to ${
      centerName || "the medical center"
    } is complete. ${disposedCount} ${
      disposedCount === 1 ? "medicine has" : "medicines have"
    } been removed from your inventory.`,
    status: "normal",
    entityType: "donation_request",
    entityId: request._id,
  });

  return { request, disposedCount };
};

//* Guard shared by both completion paths
const loadCompletableRequest = async (id, vendorCenterId) => {
  const request = await DonationRequest.findById(id);
  if (!request) return { error: [404, "Request not found"] };
  if (request.medicalCenterId.toString() !== vendorCenterId.toString()) {
    return { error: [403, "This request belongs to another center"] };
  }
  if (request.status !== "approved") {
    return { error: [400, "Only approved requests can be marked as completed"] };
  }
  return { request };
};

const completeRequest = async (req, res) => {
  try {
    const { request, error } = await loadCompletableRequest(
      req.params.id,
      req.user.vendorCenterId
    );
    if (error) {
      return res.status(error[0]).json({ statusCode: error[0], message: error[1] });
    }

    await finalizeCompletion(request, req.user.id, req.user.vendorCenterId);

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

//* Vendor scans the donor's QR — verifies the short-lived token, then runs the
//* exact same completion path as the button
const scanHandoff = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "token is required" });
    }

    const payload = verifyHandoffToken(token);
    if (!payload) {
      return res.status(401).json({
        statusCode: 401,
        message: "This QR code is invalid or has expired",
      });
    }

    const { request, error } = await loadCompletableRequest(
      payload.rid,
      req.user.vendorCenterId
    );
    if (error) {
      //* Already scanned is the common case, so name it rather than 400
      const message =
        error[0] === 400 ? "This donation was already completed" : error[1];
      return res.status(error[0]).json({ statusCode: error[0], message });
    }

    if (request.userId.toString() !== payload.uid) {
      return res
        .status(401)
        .json({ statusCode: 401, message: "This QR code is invalid" });
    }

    const { disposedCount } = await finalizeCompletion(
      request,
      req.user.id,
      req.user.vendorCenterId
    );

    res.status(200).json({
      statusCode: 200,
      message: "Donation completed",
      data: { request, disposedCount },
    });
  } catch (error) {
    console.error("Scan handoff error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Aggregated stats for the vendor dashboard
const getAnalytics = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const centerId = new mongoose.Types.ObjectId(req.user.vendorCenterId);
    const months = Math.min(parseInt(req.query.months) || 6, 60);

    //* Wider ranges switch to coarser buckets so the chart never exceeds
    //* ~12 bars no matter how far back the vendor looks
    const granularity =
      months <= 12 ? "month" : months <= 36 ? "quarter" : "year";
    const stepMonths =
      granularity === "month" ? 1 : granularity === "quarter" ? 3 : 12;

    const since = new Date();
    since.setDate(1);
    since.setHours(0, 0, 0, 0);
    since.setMonth(since.getMonth() - (months - 1));

    //* Snap to the bucket boundary, else the first bar is a partial
    //* period and reads as a dip that never happened
    if (granularity === "quarter") {
      since.setMonth(Math.floor(since.getMonth() / 3) * 3);
    } else if (granularity === "year") {
      since.setMonth(0);
    }

    const timelineGroupId =
      granularity === "month"
        ? {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" },
          }
        : granularity === "quarter"
          ? {
              year: { $year: "$createdAt" },
              quarter: {
                $ceil: { $divide: [{ $month: "$createdAt" }, 3] },
              },
            }
          : { year: { $year: "$createdAt" } };

    const [statusCounts, timeline, topMedicines, approvalTime, center, ratingCounts] =
      await Promise.all([
        DonationRequest.aggregate([
          { $match: { medicalCenterId: centerId, createdAt: { $gte: since } } },
          { $group: { _id: "$status", count: { $sum: 1 } } },
        ]),

        DonationRequest.aggregate([
          { $match: { medicalCenterId: centerId, createdAt: { $gte: since } } },
          {
            $group: {
              _id: timelineGroupId,
              total: { $sum: 1 },
              completed: {
                $sum: { $cond: [{ $eq: ["$status", "completed"] }, 1, 0] },
              },
            },
          },
        ]),

        DonationRequest.aggregate([
          { $match: { medicalCenterId: centerId, createdAt: { $gte: since } } },
          { $unwind: "$medicines" },
          {
            $group: {
              _id: { $toLower: "$medicines.name" },
              count: { $sum: 1 },
            },
          },
          { $sort: { count: -1 } },
          { $limit: 5 },
        ]),

        //* Approval latency, straight off the statusHistory trail
        DonationRequest.aggregate([
          {
            $match: {
              medicalCenterId: centerId,
              status: { $in: ["approved", "completed"] },
              createdAt: { $gte: since },
            },
          },
          {
            $addFields: {
              submitted: {
                $arrayElemAt: [
                  {
                    $filter: {
                      input: "$statusHistory",
                      cond: { $eq: ["$$this.status", "pending"] },
                    },
                  },
                  0,
                ],
              },
              approved: {
                $arrayElemAt: [
                  {
                    $filter: {
                      input: "$statusHistory",
                      cond: { $eq: ["$$this.status", "approved"] },
                    },
                  },
                  0,
                ],
              },
            },
          },
          { $match: { submitted: { $ne: null }, approved: { $ne: null } } },
          {
            $group: {
              _id: null,
              avgMs: {
                $avg: { $subtract: ["$approved.at", "$submitted.at"] },
              },
            },
          },
        ]),

        MedicalCenter.findById(centerId).select("rating totalReviews donationCount"),

        CenterReview.aggregate([
          { $match: { medicalCenterId: centerId } },
          { $group: { _id: "$rating", count: { $sum: 1 } } },
        ]),
      ]);

    const counts = statusCounts.reduce((acc, s) => {
      acc[s._id] = s.count;
      return acc;
    }, {});

    const total = Object.values(counts).reduce((a, b) => a + b, 0);
    const completed = counts.completed || 0;
    const decided = completed + (counts.rejected || 0);

    //* Fill gaps so the chart has a bar for every period, not just active ones
    const series = [];
    const cursor = new Date(since);
    const now = new Date();

    while (cursor <= now) {
      const year = cursor.getFullYear();
      const month = cursor.getMonth() + 1;

      let label;
      let match;

      if (granularity === "month") {
        label = `${year}-${String(month).padStart(2, "0")}`;
        match = timeline.find(
          (t) => t._id.year === year && t._id.month === month
        );
      } else if (granularity === "quarter") {
        const quarter = Math.floor((month - 1) / 3) + 1;
        label = `${year}-Q${quarter}`;
        match = timeline.find(
          (t) => t._id.year === year && t._id.quarter === quarter
        );
      } else {
        label = `${year}`;
        match = timeline.find((t) => t._id.year === year);
      }

      series.push({
        label,
        total: match ? match.total : 0,
        completed: match ? match.completed : 0,
      });
      cursor.setMonth(cursor.getMonth() + stepMonths);
    }

    res.status(200).json({
      statusCode: 200,
      data: {
        summary: {
          total,
          pending: counts.pending || 0,
          approved: counts.approved || 0,
          completed,
          rejected: counts.rejected || 0,
          cancelled: counts.cancelled || 0,
          fulfilmentRate:
            decided > 0 ? Math.round((completed / decided) * 100) : 0,
          avgApprovalMinutes:
            approvalTime.length > 0 && approvalTime[0].avgMs
              ? Math.max(1, Math.round(approvalTime[0].avgMs / 60000))
              : null,
          rating: center ? center.rating : 0,
          totalReviews: center ? center.totalReviews : 0,
          ratingBreakdown: [1, 2, 3, 4, 5].reduce((acc, star) => {
            const match = ratingCounts.find((r) => r._id === star);
            acc[star] = match ? match.count : 0;
            return acc;
          }, {}),
        },
        granularity,
        timeline: series,
        topMedicines: topMedicines.map((m) => ({
          name: m._id,
          count: m.count,
        })),
      },
    });
  } catch (error) {
    console.error("Get analytics error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Full ranked list of donated medicines, paginated
const getDonatedMedicines = async (req, res) => {
  try {
    if (!req.user.vendorCenterId) {
      return res.status(404).json({
        statusCode: 404,
        message: "No medical center linked to your account",
      });
    }

    const centerId = new mongoose.Types.ObjectId(req.user.vendorCenterId);
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(parseInt(req.query.limit) || 20, 50);
    const skip = (page - 1) * limit;

    const [rows, totals] = await Promise.all([
      DonationRequest.aggregate([
        { $match: { medicalCenterId: centerId } },
        { $unwind: "$medicines" },
        {
          $group: {
            _id: { $toLower: "$medicines.name" },
            count: { $sum: 1 },
          },
        },
        { $sort: { count: -1, _id: 1 } },
        { $skip: skip },
        { $limit: limit },
      ]),
      DonationRequest.aggregate([
        { $match: { medicalCenterId: centerId } },
        { $unwind: "$medicines" },
        { $group: { _id: { $toLower: "$medicines.name" } } },
        { $count: "total" },
      ]),
    ]);

    const total = totals.length > 0 ? totals[0].total : 0;

    res.status(200).json({
      statusCode: 200,
      data: {
        medicines: rows.map((r) => ({ name: r._id, count: r.count })),
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          total,
          limit,
        },
      },
    });
  } catch (error) {
    console.error("Get donated medicines error:", error);
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
  scanHandoff,
  getAnalytics,
  getDonatedMedicines,
};
