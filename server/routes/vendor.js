const express = require("express");
const router = express.Router();
const { authenticateToken, requireVendor } = require("../middleware/auth");
const vendorController = require("../controllers/vendorController");
const { upload } = require("../middleware/multer");

//* All vendor routes require authentication + vendor role
router.use(authenticateToken, requireVendor);

//* Center management
router.post("/register-center", vendorController.registerCenter);
router.get("/my-center", vendorController.getMyCenter);
router.put("/my-center", vendorController.updateMyCenter);
router.put("/inventory", vendorController.updateInventory);
router.put("/my-center/images", upload.array("images", 3), vendorController.updateCenterImages);

//* Verification document upload
router.post("/verify-documents", upload.array("documents", 5), vendorController.uploadVerificationDocs);

//* Donation request management
router.get("/analytics", vendorController.getAnalytics);
router.get("/analytics/medicines", vendorController.getDonatedMedicines);
router.get("/requests", vendorController.getRequests);
router.put("/requests/:id", vendorController.updateRequestStatus);
router.put("/requests/:id/complete", vendorController.completeRequest);

module.exports = router;
