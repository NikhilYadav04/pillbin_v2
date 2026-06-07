import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/notificationShimmer.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/network/models/notification_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewAllNotificationsScreen extends StatefulWidget {
  const ViewAllNotificationsScreen({Key? key}) : super(key: key);

  @override
  _ViewAllNotificationsScreenState createState() =>
      _ViewAllNotificationsScreenState();
}

class _ViewAllNotificationsScreenState
    extends State<ViewAllNotificationsScreen> {
  void _deleteNotification(String id) {
    final provider = context.read<NotificationProvider>();
    provider.deleteNotification(context: context, notificationId: id);
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double sw = MediaQuery.of(context).size.width;
        final bool isTablet = sw > 600;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.refresh,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.03 : sw * 0.05,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Clear All Notifications?',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'This will remove all your notifications permanently. Are you sure?',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final provider = context.read<NotificationProvider>();
                provider.deleteAllNotification(context: context);
                Navigator.of(context).pop();
              },
              child: Text(
                'Reset',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  color: PillBinColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    NotificationProvider provider = context.read<NotificationProvider>();

    if (provider.notifications.isEmpty) {
      provider.fetchNotifications(context: context);
    }
  }

  void _refresh() {
    NotificationProvider provider = context.read<NotificationProvider>();
    provider.fetchNotifications(context: context,forceRefresh: true);
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
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isNotEmpty) {
                return TextButton(
                  onPressed: _clearAllNotifications,
                  child: Text(
                    'Clear All',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.035,
                      color: PillBinColors.error,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return provider.notifications.isEmpty
              ? _buildEmptyState(sw, sh, isTablet)
              : provider.isLoafing
                  ? NotificationShimmer()
                  : _buildNotificationsList(sw, sh, isTablet, provider);
        },
      ),
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

  Widget _buildNotificationsList(
      double sw, double sh, bool isTablet, NotificationProvider provider) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: PillBinColors.primary,
      onRefresh: () async {
        _refresh();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.05 : sw * 0.04,
          vertical: sh * 0.02,
        ),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return DismissibleNotificationItem(
            notification: notification,
            sw: sw,
            sh: sh,
            onDelete: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }
}

class DismissibleNotificationItem extends StatelessWidget {
  final NotificationModel notification;
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
  final NotificationModel notification;
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.important:
        return PillBinColors.primary;
      case NotificationStatus.urgent:
        return PillBinColors.error;
      case NotificationStatus.alert:
        return PillBinColors.warning;
      case NotificationStatus.normal:
      default:
        return PillBinColors.success;
    }
  }

  IconData _getNotificationIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.important:
        return Icons.info;
      case NotificationStatus.urgent:
        return Icons.error;
      case NotificationStatus.alert:
        return Icons.warning;
      case NotificationStatus.normal:
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;
    final statusColor = _getStatusColor(notification.status);

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
          //* Status indicator icon
          Container(
            width: isTablet ? sw * 0.05 : sw * 0.08,
            height: isTablet ? sw * 0.05 : sw * 0.08,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.status),
              color: statusColor,
              size: isTablet ? sw * 0.025 : sw * 0.04,
            ),
          ),
          SizedBox(width: sw * 0.03),

          //* Notification content
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
                  notification.description,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  _getTimeAgo(notification.createdAt),
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: PillBinColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          //* Status dot and delete button
          Row(
            children: [
              if (!notification.isRead)
                Container(
                  width: isTablet ? sw * 0.015 : sw * 0.02,
                  height: isTablet ? sw * 0.015 : sw * 0.02,
                  decoration: BoxDecoration(
                    color: statusColor,
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
}
