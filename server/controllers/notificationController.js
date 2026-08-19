const { NotificationHelper } = require("../middleware/notificationHelper.js");
const Notification = require("../models/Notification.js");
const DeviceToken = require("../models/DeviceToken.js");
const { deactivateTokens } = require("../services/pushService.js");

const registerToken = async (req, res) => {
  try {
    const { fcmToken, deviceId, deviceType, deviceModel, appVersion } =
      req.body || {};

    if (!fcmToken) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "fcmToken is required",
      });
    }

    if (deviceId) {
      try {
        await DeviceToken.updateMany(
          { deviceId, fcmToken: { $ne: fcmToken } },
          { $set: { isActive: false } }
        );
      } catch (error) {
        console.error("Failed retiring stale device tokens:", error.message);
      }
    }

    await DeviceToken.findOneAndUpdate(
      { fcmToken },
      {
        userId: req.user.id,
        fcmToken,
        deviceId: deviceId || null,
        deviceType: deviceType || "android",
        deviceModel: deviceModel || null,
        appVersion: appVersion || null,
        isActive: true,
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Device token registered",
    });
  } catch (error) {
    console.error("Error registering device token:", error);
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to register device token",
      error: error.message,
    });
  }
};

const deactivateToken = async (req, res) => {
  try {
    const { fcmToken } = req.body || {};

    if (!fcmToken) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "fcmToken is required",
      });
    }

    await deactivateTokens([fcmToken]);

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Device token deactivated",
    });
  } catch (error) {
    console.error("Error deactivating device token:", error);
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to deactivate device token",
      error: error.message,
    });
  }
};

//* Get Notifications
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 20, 1), 50);

    const [notifications, totalCount, unreadCount] = await Promise.all([
      Notification.find({ userId })
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit),
      Notification.countDocuments({ userId }),
      NotificationHelper.getUnreadCount(userId),
    ]);

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Notifications fetched successfully",
      data: {
        notifications,
        totalCount,
        unreadCount,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(totalCount / limit) || 1,
          total: totalCount,
          limit,
        },
      },
    });
  } catch (error) {
    console.error("Error fetching notifications:", error);
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to fetch notifications",
      error: error.message,
    });
  }
};

//* Mark Read — a single notification's group, or all of them
const markRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id, all } = req.body || {};

    if (!id && !all) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "Either 'id' or 'all' is required",
      });
    }

    const updated = all
      ? await NotificationHelper.markAllAsRead(userId)
      : await NotificationHelper.markAsRead(id, userId);

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Notifications marked as read",
      data: { updated },
    });
  } catch (error) {
    console.error("Error marking notifications read:", error);

    if (error.message.includes("not found or unauthorized")) {
      return res.status(404).json({
        statusCode: 404,
        success: false,
        message: "Notification not found or you are not authorized",
      });
    }

    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to mark notifications as read",
      error: error.message,
    });
  }
};

//* Unread Count
const getUnreadCount = async (req, res) => {
  try {
    const count = await NotificationHelper.getUnreadCount(req.user.id);

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Unread count fetched successfully",
      data: { count },
    });
  } catch (error) {
    console.error("Error fetching unread count:", error);
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to fetch unread count",
      error: error.message,
    });
  }
};

//* Delete Notification
const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.id;

    //* Validate notification ID
    if (!notificationId) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "Notification ID is required",
      });
    }

    //* Delete notification
    const deletedNotification = await NotificationHelper.deleteNotification(
      notificationId,
      userId
    );

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Notification deleted successfully",
      data: {
        deletedNotification,
      },
    });
  } catch (error) {
    console.error("Error deleting notification:", error);

    if (error.message.includes("not found or unauthorized")) {
      return res.status(404).json({
        statusCode: 404,
        success: false,
        message:
          "Notification not found or you are not authorized to delete it",
      });
    }

    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to delete notification",
      error: error.message,
    });
  }
};

//* Delete All Notifications
const clearNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    //* Delete all notifications for the user
    const deleteResult = await NotificationHelper.deleteAllNotifications(
      userId
    );

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "All notifications cleared successfully",
      data: {
        deletedCount: deleteResult.deletedCount,
        message: deleteResult.message,
      },
    });
  } catch (error) {
    console.error("Error clearing notifications:", error);

    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to clear notifications",
      error: error.message,
    });
  }
};

module.exports = {
  getNotifications,
  markRead,
  getUnreadCount,
  registerToken,
  deactivateToken,
  deleteNotification,
  clearNotifications,
};
