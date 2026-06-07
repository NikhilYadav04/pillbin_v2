const express = require("express");
const userController = require("../controllers/userController");
const { authenticateToken } = require("../middleware/auth");
const router = express.Router();

//* Protected User Routes (JWT Required) - Using req.user.id from token

router.get("/test", authenticateToken, userController.test);

router.post(
  "/complete-profile",
  authenticateToken,
  userController.completeProfile
);
router.put("/edit-profile", authenticateToken, userController.editProfile);
router.get("/profile", authenticateToken, userController.getProfile);
router.post(
  "/save-medical-center",
  authenticateToken,
  userController.saveMedicalCenter
);
router.delete(
  "/remove-saved-medical-center",
  authenticateToken,
  userController.removeSavedMedicalCenter
);
router.get(
  "/saved-medical-centers",
  authenticateToken,
  userController.getSavedMedicalCenters
);

module.exports = router;
