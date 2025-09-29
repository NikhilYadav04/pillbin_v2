const Notification = require("../models/Notification.js");

//* Helper utility class to manage notifications with 50-notification limit
class NotificationHelper {
  static async createNotification(
    userId,
    title,
    description,
    status = "normal"
  ) {
    try {
      //* First, ensure user doesn't exceed 50 notifications
      await this.enforceNotificationLimit(userId);

      //* Create new notification
      const notification = new Notification({
        userId,
        title,
        description,
        status,
      });

      await notification.save();
      return notification;
    } catch (error) {
      throw new Error(`Failed to create notification: ${error.message}`);
    }
  }

  static async enforceNotificationLimit(userId, limit = 50) {
    try {
      const notificationCount = await Notification.countDocuments({ userId });

      if (notificationCount >= limit) {
        //* Calculate how many notifications to remove
        const excess = notificationCount - limit + 1;

        //* Find the oldest notifications to remove
        const oldestNotifications = await Notification.find({ userId })
          .sort({ createdAt: 1 })
          .limit(excess)
          .select("_id");

        const idsToRemove = oldestNotifications.map((n) => n._id);

        //* Remove oldest notifications
        await Notification.deleteMany({ _id: { $in: idsToRemove } });

        console.log(
          `Removed ${excess} oldest notifications for user ${userId}`
        );
      }
    } catch (error) {
      throw new Error(`Failed to enforce notification limit: ${error.message}`);
    }
  }

  static async getUserNotifications(userId, page = 1, limit = 50) {
    try {
      const skip = (page - 1) * limit;

      const notifications = await Notification.find({ userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);

      const total = await Notification.countDocuments({ userId });

      return {
        notifications,
        totalCount: total,
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        hasMore: skip + notifications.length < total,
      };
    } catch (error) {
      throw new Error(`Failed to get user notifications: ${error.message}`);
    }
  }

  static async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findOneAndUpdate(
        { _id: notificationId, userId },
        { isRead: true, updatedAt: new Date() },
        { new: true }
      );

      if (!notification) {
        throw new Error("Notification not found or unauthorized");
      }

      return notification;
    } catch (error) {
      throw new Error(`Failed to mark notification as read: ${error.message}`);
    }
  }

  static async markAllAsRead(userId) {
    try {
      const result = await Notification.updateMany(
        { userId, isRead: false },
        { isRead: true, updatedAt: new Date() }
      );

      return result.modifiedCount;
    } catch (error) {
      throw new Error(
        `Failed to mark all notifications as read: ${error.message}`
      );
    }
  }

  static async deleteNotification(notificationId, userId) {
    try {
      const notification = await Notification.findOneAndDelete({
        _id: notificationId,
        userId,
      });

      if (!notification) {
        throw new Error("Notification not found or unauthorized");
      }

      return notification;
    } catch (error) {
      throw new Error(`Failed to delete notification: ${error.message}`);
    }
  }

  static async deleteAllNotifications(userId) {
    try {
      const result = await Notification.deleteMany({ userId });

      return {
        deletedCount: result.deletedCount,
        message: `Successfully deleted ${result.deletedCount} notifications`,
      };
    } catch (error) {
      throw new Error(`Failed to delete all notifications: ${error.message}`);
    }
  }
}

module.exports = { NotificationHelper };
