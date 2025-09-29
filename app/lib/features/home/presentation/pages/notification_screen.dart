import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class ViewAllNotificationsScreen extends StatefulWidget {
  const ViewAllNotificationsScreen({Key? key}) : super(key: key);

  @override
  _ViewAllNotificationsScreenState createState() =>
      _ViewAllNotificationsScreenState();
}

class _ViewAllNotificationsScreenState
    extends State<ViewAllNotificationsScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Paracetamol added',
      subtitle: '2 hours ago',
      statusColor: PillBinColors.success,
      type: NotificationType.medicineAdded,
    ),
    NotificationItem(
      id: '2',
      title: 'Crocin expires soon',
      subtitle: '1 day ago',
      statusColor: PillBinColors.warning,
      type: NotificationType.expiringSoon,
    ),
    NotificationItem(
      id: '3',
      title: 'Dolo disposed safely',
      subtitle: '3 days ago',
      statusColor: PillBinColors.primary,
      type: NotificationType.disposed,
    ),
    NotificationItem(
      id: '4',
      title: 'Aspirin stock low',
      subtitle: '5 days ago',
      statusColor: PillBinColors.error,
      type: NotificationType.lowStock,
    ),
    NotificationItem(
      id: '5',
      title: 'Vitamin D expired',
      subtitle: '1 week ago',
      statusColor: PillBinColors.error,
      type: NotificationType.expired,
    ),
  ];

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: PillBinColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Notifications'),
          content: Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All notifications cleared'),
                    backgroundColor: PillBinColors.success,
                  ),
                );
              },
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PillBinColors.textPrimary,
            size: isTablet ? sw * 0.03 : sw * 0.06,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Notifications',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.035 : sw * 0.05,
            color: PillBinColors.textPrimary,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAllNotifications,
              child: Text(
                'Clear All',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.035,
                  color: PillBinColors.error,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(sw, sh, isTablet)
          : _buildNotificationsList(sw, sh, isTablet),
    );
  }

  Widget _buildEmptyState(double sw, double sh, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: isTablet ? sw * 0.15 : sw * 0.2,
            color: PillBinColors.greyLight,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No Notifications',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.03 : sw * 0.045,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'You\'re all caught up!',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(double sw, double sh, bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.02,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return DismissibleNotificationItem(
          notification: notification,
          sw: sw,
          sh: sh,
          onDelete: () => _deleteNotification(notification.id),
        );
      },
    );
  }
}

class DismissibleNotificationItem extends StatelessWidget {
  final NotificationItem notification;
  final double sw;
  final double sh;
  final VoidCallback onDelete;

  const DismissibleNotificationItem({
    Key? key,
    required this.notification,
    required this.sw,
    required this.sh,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: sh * 0.015),
        decoration: BoxDecoration(
          color: PillBinColors.error,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: isTablet ? sw * 0.04 : sw * 0.06,
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: NotificationItemCard(
        notification: notification,
        sw: sw,
        sh: sh,
        onDelete: onDelete,
      ),
    );
  }
}

class NotificationItemCard extends StatelessWidget {
  final NotificationItem notification;
  final double sw;
  final double sh;
  final VoidCallback onDelete;

  const NotificationItemCard({
    Key? key,
    required this.notification,
    required this.sw,
    required this.sh,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: PillBinColors.greyLight.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Status indicator icon
          Container(
            width: isTablet ? sw * 0.05 : sw * 0.08,
            height: isTablet ? sw * 0.05 : sw * 0.08,
            decoration: BoxDecoration(
              color: notification.statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.statusColor,
              size: isTablet ? sw * 0.025 : sw * 0.04,
            ),
          ),
          SizedBox(width: sw * 0.03),

          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  notification.subtitle,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status dot and delete button
          Row(
            children: [
              Container(
                width: isTablet ? sw * 0.015 : sw * 0.02,
                height: isTablet ? sw * 0.015 : sw * 0.02,
                decoration: BoxDecoration(
                  color: notification.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: sw * 0.02),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: EdgeInsets.all(sw * 0.01),
                  child: Icon(
                    Icons.close,
                    color: PillBinColors.textSecondary,
                    size: isTablet ? sw * 0.025 : sw * 0.04,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.medicineAdded:
        return Icons.add_circle;
      case NotificationType.expiringSoon:
        return Icons.warning;
      case NotificationType.disposed:
        return Icons.check_circle;
      case NotificationType.lowStock:
        return Icons.inventory;
      case NotificationType.expired:
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }
}

// Data models
class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final Color statusColor;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    required this.type,
  });
}

enum NotificationType {
  medicineAdded,
  expiringSoon,
  disposed,
  lowStock,
  expired,
}
