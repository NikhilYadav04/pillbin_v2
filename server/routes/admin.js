const express = require("express");
const router = express.Router();
const { authenticateToken, requireAdmin } = require("../middleware/auth");
const adminController = require("../controllers/adminController");

//* All admin routes require authentication + admin role
router.use(authenticateToken, requireAdmin);

//* Verification management
router.get("/verifications", adminController.getPendingVerifications);
router.put("/verifications/:centerId/approve", adminController.approveVerification);
router.put("/verifications/:centerId/reject", adminController.rejectVerification);

module.exports = router;
