const Notification = require("../models/Notification.js");

class NotificationHelper {
  static async markAsRead(notificationId, userId) {
    const notification = await Notification.findOne({
      _id: notificationId,
      userId,
    });

    if (!notification) {
      throw new Error("Notification not found or unauthorized");
    }

    const filter = notification.groupKey
      ? { userId, groupKey: notification.groupKey, isRead: false }
      : { _id: notification._id, isRead: false };

    const result = await Notification.updateMany(filter, {
      isRead: true,
      updatedAt: new Date(),
    });

    return result.modifiedCount;
  }

  static async markAllAsRead(userId) {
    const result = await Notification.updateMany(
      { userId, isRead: false },
      { isRead: true, updatedAt: new Date() }
    );

    return result.modifiedCount;
  }

  static async getUnreadCount(userId) {
    return Notification.countDocuments({ userId, isRead: false });
  }

  static async deleteNotification(notificationId, userId) {
    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      userId,
    });

    if (!notification) {
      throw new Error("Notification not found or unauthorized");
    }

    return notification;
  }

  static async deleteAllNotifications(userId) {
    const result = await Notification.deleteMany({ userId });

    return {
      deletedCount: result.deletedCount,
      message: `Successfully deleted ${result.deletedCount} notifications`,
    };
  }
}

module.exports = { NotificationHelper };
