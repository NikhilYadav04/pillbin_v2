const { NotificationHelper } = require("../middleware/notificationHelper.js");
const Notification = require("../models/Notification.js");

//* Add Notification
const addNotification = async (req, res) => {
  try {
    const { title, description, status } = req.body;
    const userId = req.user.id;

    //* Validate required fields
    if (!title || !description) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message: "Title and description are required",
      });
    }

    //* Validate status
    const validStatuses = ["important", "normal", "urgent", "alert"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        statusCode: 400,
        success: false,
        message:
          "Invalid status. Must be one of: important, normal, urgent, alert",
      });
    }

    //* Create notification
    const notification = await NotificationHelper.createNotification(
      userId,
      title,
      description,
      status
    );

    res.status(201).json({
      statusCode: 201,
      success: true,
      message: "Notification created successfully",
      data: {
        notification,
      },
    });
  } catch (error) {
    console.error("Error adding notification:", error);
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to create notification",
      error: error.message,
    });
  }
};

//* Get Notifications
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    let notifications;

    notifications = await Notification.find({ userId }).sort({
      createdAt: -1,
    });

    //const unreadCount = await NotificationHelper.getUnreadCount(userId);

    res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Notifications fetched successfully",
      data: {
        notifications,
        totalCount: notifications.length,
        // unreadCount,
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

module.exports = { addNotification, getNotifications, deleteNotification ,clearNotifications};
