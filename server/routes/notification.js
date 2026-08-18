const express = require("express");
const { authenticateToken } = require("../middleware/auth");
const {
  getNotifications,
  markRead,
  getUnreadCount,
  registerToken,
  deactivateToken,
  deleteNotification,
  clearNotifications,
} = require("../controllers/notificationController.js");
const router = express.Router();

//* Device Tokens
router.post("/tokens/register", authenticateToken, registerToken);
router.post("/tokens/deactivate", authenticateToken, deactivateToken);

//* Get Notification
router.get("/", authenticateToken, getNotifications);

//* Unread Count
router.get("/unread-count", authenticateToken, getUnreadCount);

//* Mark Read
router.post("/read", authenticateToken, markRead);

//* Delete Notification
router.delete("/:notificationId", authenticateToken, deleteNotification);

//* Clear All Notifications
router.delete("/", authenticateToken, clearNotifications);

module.exports = router;
