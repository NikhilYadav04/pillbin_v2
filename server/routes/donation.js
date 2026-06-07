const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/auth");
const donationController = require("../controllers/donationController");
const { upload } = require("../middleware/multer");

//* All donation routes require authentication
router.use(authenticateToken);

router.post("/", upload.array("medicinePhotos", 2), donationController.submitRequest);
router.get("/my-requests", donationController.getMyRequests);
router.get("/:id", donationController.getRequestById);
router.delete("/:id", donationController.cancelRequest);

module.exports = router;
