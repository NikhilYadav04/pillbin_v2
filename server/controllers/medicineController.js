const Medicine = require("../models/Medicine");
const User = require("../models/User");

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
    const { name, expiryDate, notes, dosage, manufacturer, batchNumber } =
      req.body;

    if (!name || !expiryDate) {
      return res.status(400).json({
        message: "Medicine name and expiry date are required",
      });
    }

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const medicine = new Medicine({
      userId,
      name,
      expiryDate: new Date(expiryDate),
      notes,
      dosage,
      manufacturer,
      batchNumber,
    });

    //* Update status based on expiry date
    medicine.updateStatus();
    await medicine.save();

    //* Update user stats
    await updateUserStats(userId);

    res.status(201).json({
      message: "Medicine added successfully",
      medicine,
    });
  } catch (error) {
    console.error("Add medicine error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Get user's medicine inventory with counts and pagination
const getInventory = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    //* Get userId from JWT token
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    //* Update all medicine statuses first
    const medicines = await Medicine.find({ userId });
    for (let medicine of medicines) {
      const oldStatus = medicine.status;
      medicine.updateStatus();
      if (oldStatus !== medicine.status) {
        await medicine.save();
      }
    }

    //* Get updated medicines by status with pagination
    const skip = (page - 1) * limit;
    const activeMedicines = await Medicine.find({ userId, status: "active" })
      .sort({ expiryDate: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    const expiringSoonMedicines = await Medicine.find({
      userId,
      status: "expiring_soon",
    })
      .sort({ expiryDate: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    const expiredMedicines = await Medicine.find({ userId, status: "expired" })
      .sort({ expiryDate: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    //* Get counts
    const counts = {
      active: await Medicine.countDocuments({ userId, status: "active" }),
      expiring_soon: await Medicine.countDocuments({
        userId,
        status: "expiring_soon",
      }),
      expired: await Medicine.countDocuments({ userId, status: "expired" }),
      total: await Medicine.countDocuments({ userId }),
    };

    //* Update user stats
    await updateUserStats(userId);

    res.status(200).json({
      inventory: {
        activeMedicines,
        expiringSoonMedicines,
        expiredMedicines,
        counts,
      },
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(counts.total / limit),
        limit: parseInt(limit),
      },
    });
  } catch (error) {
    console.error("Get inventory error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Get user's active medicines with pagination
const getActiveMedicines = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    //* Get userId from JWT token
    const userId = req.user.id;
    const skip = (page - 1) * limit;
    const total = await Medicine.countDocuments({ userId, status: "active" });

    const activeMedicines = await Medicine.find({
      userId,
      status: "active",
    })
      .sort({ expiryDate: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    res.status(200).json({
      activeMedicines,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalMedicines: total,
        limit: parseInt(limit),
      },
    });
  } catch (error) {
    console.error("Get active medicines error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Get user's medicines expiring soon with pagination
const getExpiringSoonMedicines = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    //* Get userId from JWT token
    const userId = req.user.id;
    const skip = (page - 1) * limit;
    const total = await Medicine.countDocuments({
      userId,
      status: "expiring_soon",
    });

    const expiringSoonMedicines = await Medicine.find({
      userId,
      status: "expiring_soon",
    })
      .sort({ expiryDate: 1 })
      .limit(parseInt(limit))
      .skip(skip);

    res.status(200).json({
      expiringSoonMedicines,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalMedicines: total,
        limit: parseInt(limit),
      },
    });
  } catch (error) {
    console.error("Get expiring soon medicines error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Get user's expired medicines with pagination
const getExpiredMedicines = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    //* Get userId from JWT token
    const userId = req.user.id;
    const skip = (page - 1) * limit;
    const total = await Medicine.countDocuments({ userId, status: "expired" });

    const expiredMedicines = await Medicine.find({
      userId,
      status: "expired",
    })
      .sort({ expiryDate: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    res.status(200).json({
      expiredMedicines,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalMedicines: total,
        limit: parseInt(limit),
      },
    });
  } catch (error) {
    console.error("Get expired medicines error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Delete a specific medicine (mark as disposed)
const deleteMedicine = async (req, res) => {
  try {
    const { medicineId } = req.params;

    //* Get userId from JWT token for verification
    const userId = req.user.id;

    const medicine = await Medicine.findById(medicineId);
    if (!medicine) {
      return res.status(404).json({ message: "Medicine not found" });
    }

    //* Verify medicine belongs to authenticated user
    if (medicine.userId.toString() !== userId) {
      return res
        .status(403)
        .json({ message: "Not authorized to delete this medicine" });
    }

    //* Delete the medicine
    await Medicine.findByIdAndDelete(medicineId);

    //* Update user stats - increment disposed count
    const user = await User.findById(userId);
    if (user) {
      user.stats.medicinesDisposedCount += 1;
      user.updateBadges(); //* Check and update badges
      await user.save();
    }

    //* Update other stats
    await updateUserStats(userId);

    res.status(200).json({
      message: "Medicine disposed successfully",
      disposedCount: user.stats.medicinesDisposedCount,
    });
  } catch (error) {
    console.error("Delete medicine error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Delete all expired medicines for a user
const deleteAllExpiredMedicines = async (req, res) => {
  try {
    //* Get userId from JWT token
    const userId = req.user.id;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    //* Count expired medicines before deletion
    const expiredCount = await Medicine.countDocuments({
      userId,
      status: "expired",
    });

    if (expiredCount === 0) {
      return res.status(400).json({ message: "No expired medicines found" });
    }

    //* Delete all expired medicines
    await Medicine.deleteMany({ userId, status: "expired" });

    //* Update user stats
    user.stats.medicinesDisposedCount += expiredCount;
    user.updateBadges(); //* Check and update badges
    await user.save();

    //* Update other stats
    await updateUserStats(userId);

    res.status(200).json({
      message: `${expiredCount} expired medicines disposed successfully`,
      disposedCount: expiredCount,
      totalDisposedCount: user.stats.medicinesDisposedCount,
    });
  } catch (error) {
    console.error("Delete all expired medicines error:", error);
    res.status(500).json({ message: "Server error" });
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
      return res.status(404).json({ message: "Medicine not found" });
    }

    //* Verify medicine belongs to authenticated user
    if (medicine.userId.toString() !== userId) {
      return res
        .status(403)
        .json({ message: "Not authorized to update this medicine" });
    }

    //* Update allowed fields
    const allowedFields = [
      "name",
      "expiryDate",
      "notes",
      "dosage",
      "manufacturer",
      "batchNumber",
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
    await updateUserStats(medicine.userId);

    res.status(200).json({
      message: "Medicine updated successfully",
      medicine,
    });
  } catch (error) {
    console.error("Update medicine error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Update all medicine statuses (can be called periodically)
const updateAllStatuses = async (req, res) => {
  try {
    await Medicine.updateAllStatuses();

    res.status(200).json({
      message: "All medicine statuses updated successfully",
    });
  } catch (error) {
    console.error("Update statuses error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Clean up expired medicines (remove after 2 days of expiry)
const cleanupExpiredMedicines = async (req, res) => {
  try {
    const deletedCount = await Medicine.cleanupExpiredMedicines();

    res.status(200).json({
      message: `${deletedCount} expired medicines cleaned up successfully`,
      deletedCount,
    });
  } catch (error) {
    console.error("Cleanup expired medicines error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  addMedicine,
  getInventory,
  getActiveMedicines,
  getExpiringSoonMedicines,
  getExpiredMedicines,
  deleteMedicine,
  deleteAllExpiredMedicines,
  updateMedicine,
  updateAllStatuses,
  cleanupExpiredMedicines,
};
