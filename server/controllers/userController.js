const User = require("../models/User");
const MedicalCenter = require("../models/MedicalCenter");

//* test route to check if jwt is valid
const test = async (req, res) => {
  try {
    console.log(req.body);
    res.status(200).json({
      success: true,
      statusCode: 200,
      message: "JWT Valid !!!",
    });
  } catch (error) {
    console.error("Complete profile error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Complete user profile after signup
const completeProfile = async (req, res) => {
  try {
    const { fullName, phone, currentMedicines, medicalConditions, location } =
      req.body;

    if (!fullName || !phone) {
      return res
        .status(400)
        .json({ message: "Full name and phone are required", statusCode: 400 });
    }

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", statusCode: 404 });
    }

    if (user.profileCompleted) {
      return res
        .status(400)
        .json({
          message: "Profile Details already completed !!",
          statusCode: 400,
        });
    }

    //* Update profile
    user.fullName = fullName;
    user.phoneNumber = phone;
    user.currentMedicines = currentMedicines || [];
    user.medicalConditions = medicalConditions || [];
    user.location = location || null;
    user.profileCompleted = true;

    await user.save();

    res.status(200).json({
      statusCode: 200,
      message: "Profile completed successfully",
      data: {
        user: {
          id: user._id,
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          profileCompleted: user.profileCompleted,
        },
      },
    });
  } catch (error) {
    console.error("Complete profile error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Edit user profile
const editProfile = async (req, res) => {
  try {
    const updateData = req.body;

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", statusCode: 404 });
    }

    //* Update allowed fields
    const allowedFields = [
      "fullName",
      "phoneNumber",
      "currentMedicines",
      "medicalConditions",
      "location",
    ];

    allowedFields.forEach((field) => {
      if (updateData[field] !== undefined) {
        user[field] = updateData[field];
      }
    });

    await user.save();

    res.status(200).json({
      statusCode: 200,
      message: "Profile updated successfully",
      data: {
        user: {
          id: user._id,
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          currentMedicines: user.currentMedicines,
          medicalConditions: user.medicalConditions,
          location: user.location,
        },
      },
    });
  } catch (error) {
    console.error("Edit profile error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Get user profile details
const getProfile = async (req, res) => {
  try {
    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId).populate("savedMedicalCenters");

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", statusCode: 404 });
    }

    res.status(200).json({
      statusCode: 200,
      data: {
        user: {
          id: user._id,
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          currentMedicines: user.currentMedicines,
          medicalConditions: user.medicalConditions,
          location: user.location,
          medicineCount: user.medicineCount,
          stats: user.stats,
          badges: user.badges,
          savedMedicalCenters: user.savedMedicalCenters,
          profileCompleted: user.profileCompleted,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Add medical center to saved list
const saveMedicalCenter = async (req, res) => {
  try {
    const { medicalCenterId } = req.body;

    if (!medicalCenterId) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "Medical Center ID is required" });
    }

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);
    const medicalCenter = await MedicalCenter.findById(medicalCenterId);

    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    if (!medicalCenter) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medical center not found" });
    }

    if (user.savedMedicalCenters.length >= 50) {
      return res.status(400).json({
        statusCode: 400,
        message: "You have reached the limit of saved medical centers.",
      });
    }

    //* Check if already saved
    if (user.savedMedicalCenters.includes(medicalCenterId)) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "Medical center already saved" });
    }

    user.savedMedicalCenters.push(medicalCenterId);
    await user.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medical center saved successfully",
      data: {
        savedMedicalCenters: user.savedMedicalCenters,
      },
    });
  } catch (error) {
    console.error("Save medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Remove medical center from saved list
const removeSavedMedicalCenter = async (req, res) => {
  try {
    const { medicalCenterId } = req.body;

    if (!medicalCenterId) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "Medical Center ID is required" });
    }

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    user.savedMedicalCenters = user.savedMedicalCenters.filter(
      (id) => id.toString() !== medicalCenterId
    );

    await user.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medical center removed from saved list",
      data: {
        removedMedicalCenter: medicalCenterId,
      },
    });
  } catch (error) {
    console.error("Remove saved medical center error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get user's saved medical centers with pagination
const getSavedMedicalCenters = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    //* Get paginated saved medical centers
    const skip = (page - 1) * limit;
    const totalSaved = user.savedMedicalCenters.length;

    const paginatedIds = user.savedMedicalCenters.slice(
      skip,
      skip + parseInt(limit)
    );

    const savedMedicalCenters = await MedicalCenter.find({
      _id: { $in: paginatedIds },
      isActive: true, // only fetch active centers
    });

    res.status(200).json({
      statusCode: 200,
      data: {
        savedMedicalCenters,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalSaved / limit),
          totalSaved,
          limit: parseInt(limit),
        },
      },
    });
  } catch (error) {
    console.error("Get saved medical centers error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  test,
  completeProfile,
  editProfile,
  getProfile,
  saveMedicalCenter,
  removeSavedMedicalCenter,
  getSavedMedicalCenters,
};
