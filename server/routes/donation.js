const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/auth");
const donationController = require("../controllers/donationController");
const { upload } = require("../middleware/multer");

//* Public: the QR printed on a receipt points here, so it must resolve for
//* anyone the PDF is forwarded to
router.get("/verify/:id", donationController.verifyReceipt);

//* All donation routes require authentication
router.use(authenticateToken);

router.post("/", upload.array("medicinePhotos", 2), donationController.submitRequest);
router.get("/my-requests", donationController.getMyRequests);
router.get("/center/:centerId/reviews", donationController.getCenterReviews);
router.get("/:id/handoff-token", donationController.getHandoffToken);
router.get("/:id", donationController.getRequestById);
router.delete("/:id", donationController.cancelRequest);
router.post("/:id/review", donationController.submitReview);
router.delete("/review/:reviewId", donationController.deleteReview);

module.exports = router;
