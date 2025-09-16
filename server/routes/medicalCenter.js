const express = require("express");
const medicalCenterController = require("../controllers/medicalCenterController");
const { authenticateToken, optionalAuth } = require("../middleware/auth");
const router = express.Router();

//* Public Medical Center Routes (No JWT Required)
router.get("/all", medicalCenterController.getAllMedicalCenters);

router.get("/nearby", medicalCenterController.getNearbyMedicalCenters);

router.get("/search", medicalCenterController.searchMedicalCenters);

router.get("/:id", medicalCenterController.getMedicalCenterById);

//* Protected/Admin Routes (JWT Required)
router.post(
  "/add",
  authenticateToken,
  medicalCenterController.addMedicalCenter
);
router.put(
  "/update/:id",
  authenticateToken,
  medicalCenterController.updateMedicalCenter
);
router.delete(
  "/delete/:id",
  authenticateToken,
  medicalCenterController.deleteMedicalCenter
);

module.exports = router;
