const Medicine = require("../models/Medicine");
const User = require("../models/User");
const {
  uploadImageService,
  deleteImageService,
} = require("../services/clopudinaryService.js");
const { generateMedicineLinks } = require("../utils/medicineLinkGenerator.js");

//* Helper function to update user stats
const updateUserStats = async (userId) => {
  const activeMedicines = await Medicine.countDocuments({
    userId,
    status: "active",
  });
  const expiringSoon = await Medicine.countDocuments({
    userId,
    status: "expiring_soon",
  });
  const totalTracked = await Medicine.countDocuments({ userId });

  await User.findByIdAndUpdate(userId, {
    "stats.totalMedicinesTracked": totalTracked,
    "stats.expiringSoonCount": expiringSoon,
  });
};

//* Add medicine to inventory
const addMedicine = async (req, res) => {
  try {
    const {
      name,
      purchaseDate,
      expiryDate,
      notes,
      type,
      dosage,
      manufacturer,
      batchNumber,
    } = req.body;

    if (!name || !expiryDate) {
      return res.status(400).json({
        statusCode: 400,
        message: "Medicine name and expiry date are required",
      });
    }

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    if (user.medicineCount > 100) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "You have reached the limit of 100 medicines !!",
      });
    }

    //* clean name and generate links
    const { cleanedName, buyLinks } = generateMedicineLinks(name);
    let imageData = {
      url: null,
      publicId: null,
    };

    if (req.file) {
      const result = await uploadImageService(req.file, `medicines/${userId}`);

      imageData.url = result.secure_url;
      imageData.publicId = result.public_id;
    }

    const medicine = new Medicine({
      userId,
      name: cleanedName,
      addedDate: new Date(),
      type,
      purchaseDate,
      expiryDate: expiryDate,
      notes,
      dosage,
      manufacturer,
      batchNumber,
      image: imageData,
      productLinks: buyLinks,
    });

    //* Update status based on expiry date
    const status = medicine.updateStatus();
    await medicine.save();

    //* Update user stats
    // await updateUserStats(userId);

    if (status == "expiring_soon") {
      user.stats.expiringSoonCount += 1;
    }

    //* Update user stats
    user.medicineCount += 1;
    user.stats.totalMedicinesTracked += 1;

    //* update user badges
    await user.updateBadges();

    await user.save();

    res.status(201).json({
      statusCode: 201,
      message: "Medicine added successfully",
      data: {
        medicine,
      },
    });
  } catch (error) {
    console.error("Add medicine error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get user's medicine inventory with counts and pagination
const getInventory = async (req, res) => {
  try {
    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    //* Fetch all medicines of the user
    const medicines = await Medicine.find({
      userId,
      isDeleted: false,
    }).sort({ expiryDate: 1 });

    //* Update status in memory (and save if changed)
    for (let medicine of medicines) {
      const oldStatus = medicine.status;
      medicine.updateStatus();
      if (oldStatus !== medicine.status) {
        await medicine.save();
      }
    }

    //* Classify medicines
    const activeMedicines = [];
    const expiringSoonMedicines = [];
    const expiredMedicines = [];

    medicines.forEach((med) => {
      if (med.status === "active") activeMedicines.push(med);
      else if (med.status === "expiring_soon") expiringSoonMedicines.push(med);
      else if (med.status === "expired") expiredMedicines.push(med);
    });

    //* Counts
    const counts = {
      active: activeMedicines.length,
      expiring_soon: expiringSoonMedicines.length,
      expired: expiredMedicines.length,
      total: medicines.length,
    };

    user.stats.expiringSoonCount = expiringSoonMedicines.length;
    await user.save();

    res.status(200).json({
      statusCode: 200,
      data: {
        inventory: {
          activeMedicines,
          expiringSoonMedicines,
          expiredMedicines,
          counts,
        },
      },
    });
  } catch (error) {
    console.error("Get inventory error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Get user's medicine inventory with counts and pagination which is deleted
const getDeletedMedicines = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    // Fetch all soft-deleted medicines of the user
    const deletedMedicines = await Medicine.find({
      userId,
      isDeleted: true,
    }).sort({ expiryDate: 1 });

    res.status(200).json({
      statusCode: 200,
      data: {
        medicines: deletedMedicines,
        totalDeleted: deletedMedicines.length,
      },
    });
  } catch (error) {
    console.error("Get deleted medicines error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete a specific medicine (soft delete )
const deleteMedicine = async (req, res) => {
  try {
    const { medicineId } = req.params;

    //* Get userId from JWT token for verification
    const userId = req.user.id;

    const medicine = await Medicine.findById(medicineId);
    if (!medicine) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medicine not found" });
    }

    console.log(userId);
    console.log(medicine.userId.toString());

    //* Verify medicine belongs to authenticated user
    if (medicine.userId.toString() != userId) {
      return res.status(403).json({
        statusCode: 403,
        message: "Not authorized to delete this medicine",
      });
    }

    const status = medicine.status;

    const checkDeletedMedicines = await Medicine.find({
      userId: userId,
      isDeleted: true,
    });

    //* Delete the medicine
    if (checkDeletedMedicines.length > 100) {
      if (medicine.image?.publicId) {
        try {
          await deleteImageService(medicine.image.publicId);
        } catch (cloudinaryError) {
          console.error("Cloudinary deletion error:", cloudinaryError);
        }
      }
      await Medicine.findByIdAndDelete(medicineId);
    } else {
      medicine.isDeleted = true;
      await medicine.save();
    }

    //* Update user stats - increment disposed count
    const user = await User.findById(userId);

    //* Update other stats
    if (medicine.status == "expiring_soon") {
      user.stats.expiringSoonCount -= 1;
    }

    //await updateUserStats(userId);
    // user.medicineCount -= 1;
    // user.stats.totalMedicinesTracked -= 1;
    await user.save();

    res.status(200).json({
      statusCode: 200,
      message: "Medicine deleted successfully",
      data: {
        medicine: {
          status: status,
        },
        disposedCount: user.stats.medicinesDisposedCount,
      },
    });
  } catch (error) {
    console.error("Delete medicine error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete all expired medicines for a user ( soft delete all)
const deleteAllExpiredMedicines = async (req, res) => {
  try {
    //* Get userId from JWT token
    const userId = req.user.id;

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "User not found" });
    }

    //* Count expired medicines before deletion
    const expiredCount = await Medicine.countDocuments({
      userId,
      status: "expired",
    });

    if (expiredCount === 0) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "No expired medicines found" });
    }

    const checkDeletedMedicines = await Medicine.find({
      userId: userId,
      isDeleted: true,
    });

    if (checkDeletedMedicines.length > 100) {
      //* Hard delete all expired medicines that are NOT already soft-deleted
      const filter = { userId, status: "expired", isDeleted: false };

      const expiring = await Medicine.find(filter).select("image");
      const publicIds = expiring.map((m) => m.image?.publicId).filter(Boolean);

      for (const publicId of publicIds) {
        try {
          await deleteImageService(publicId);
        } catch (cloudinaryError) {
          console.error("Cloudinary deletion error:", cloudinaryError);
        }
      }

      await Medicine.deleteMany(filter);
    } else {
      //* Soft delete all expired medicines that are NOT already soft-deleted
      await Medicine.updateMany(
        { userId, status: "expired", isDeleted: false },
        { $set: { isDeleted: true } }
      );
    }

    // //* Update user stats
    // //await updateUserStats(userId);
    // if ((user.medicineCount -= expiredCount < 0)) {
    //   user.medicineCount = 0;
    // } else {
    //   user.medicineCount -= expiredCount;
    // }

    //await user.save();

    res.status(200).json({
      statusCode: 200,
      message: `${expiredCount} expired medicines successfully deleted`,
      data: {
        disposedCount: expiredCount,
        totalDisposedCount: user.stats.medicinesDisposedCount,
      },
    });
  } catch (error) {
    console.error("Delete all expired medicines error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete a specific medicine (hard delete )
const deleteMedicineHard = async (req, res) => {
  try {
    const { medicineId } = req.params;

    //* Get userId from JWT token for verification
    const userId = req.user.id;

    const medicine = await Medicine.findById(medicineId);
    if (!medicine) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medicine not found" });
    }

    console.log(userId);
    console.log(medicine.userId.toString());

    //* Verify medicine belongs to authenticated user
    if (medicine.userId.toString() != userId) {
      return res.status(403).json({
        statusCode: 403,
        message: "Not authorized to delete this medicine",
      });
    }

    const status = medicine.status;

    //* delete image if exists
    if (medicine.image?.publicId) {
      await deleteImageService(medicine.image.publicId);
    }

    //* delete from DB
    await Medicine.findByIdAndDelete(medicineId);

    res.status(200).json({
      statusCode: 200,
      message: "Medicine deleted successfully",
      data: {
        medicine: {
          status: status,
        },
        disposedCount: user.stats.medicinesDisposedCount,
      },
    });
  } catch (error) {
    console.error("Delete medicine error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Delete all expired medicines for a user ( hard delete all)
const hardDeleteAllDeletedMedicines = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        statusCode: 404,
        message: "User not found",
      });
    }

    const filter = { userId, isDeleted: true };

    const medicines = await Medicine.find(filter);

    if (medicines.length === 0) {
      return res.status(400).json({
        statusCode: 400,
        message: "No expired medicines found",
      });
    }

    const publicIds = medicines.map((m) => m.image?.publicId).filter(Boolean);

    if (publicIds.length > 0) {
      try {
        for (const publicId of publicIds) {
          await deleteImageService(publicId);
        }
      } catch (cloudinaryError) {
        console.error("Cloudinary deletion error:", cloudinaryError);
      }
    }

    await Medicine.deleteMany(filter);

    res.status(200).json({
      statusCode: 200,
      message: `${medicines.length} expired medicines permanently deleted`,
      data: {
        disposedCount: medicines.length,
        totalDisposedCount: user.stats?.medicinesDisposedCount || 0,
      },
    });
  } catch (error) {
    console.error("Hard delete expired medicines error:", error);
    res.status(500).json({
      statusCode: 500,
      message: "Server error",
    });
  }
};

//* Update medicine details
const updateMedicine = async (req, res) => {
  try {
    const { medicineId } = req.params;
    const updateData = req.body;

    //* Get userId from JWT token for verification
    const userId = req.user.id;

    const medicine = await Medicine.findById(medicineId);
    if (!medicine) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Medicine not found" });
    }

    console.log(userId);
    console.log(medicine.userId.toString());

    //* Verify medicine belongs to authenticated user
    if (medicine.userId.toString() != userId) {
      return res.status(403).json({
        statusCode: 403,
        message: "Not authorized to update this medicine",
      });
    }

    //* Update allowed fields
    const allowedFields = [
      "name",
      "purchaseDate",
      "notes",
      "dosage",
      "manufacturer",
      "batchNumber",
      "expiryDate",
      "type",
    ];
    allowedFields.forEach((field) => {
      if (updateData[field] !== undefined) {
        medicine[field] = updateData[field];
      }
    });

    //* Update status if expiry date changed
    if (updateData.expiryDate) {
      medicine.updateStatus();
    }

    await medicine.save();

    //* Update user stats
    //await updateUserStats(medicine.userId);

    res.status(200).json({
      statusCode: 200,
      message: "Medicine updated successfully",
      data: {
        medicine,
      },
    });
  } catch (error) {
    console.error("Update medicine error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  addMedicine,
  getInventory,
  getDeletedMedicines,
  deleteMedicine,
  deleteAllExpiredMedicines,
  deleteMedicineHard,
  hardDeleteAllDeletedMedicines,
  updateMedicine,
};
