const express = require("express");
const { authenticateToken } = require("../middleware/auth");
const {
  addNotification,
  getNotifications,
  deleteNotification,
  clearNotifications,
} = require("../controllers/notificationController.js");
const router = express.Router();

//* Add Notification
router.post("/", authenticateToken, addNotification);

//* Get Notification
router.get("/", authenticateToken, getNotifications);

//* Delete Notification
router.delete("/:notificationId", authenticateToken, deleteNotification);

//* Clear All Notifications
router.delete("/", authenticateToken, clearNotifications);

module.exports = router;
