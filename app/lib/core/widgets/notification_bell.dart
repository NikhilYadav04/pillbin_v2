import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;

  final bool compact;

  const NotificationBell({
    Key? key,
    this.iconColor = Colors.white,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isTablet = sw > 600;
    final double iconSize = isTablet ? sw * 0.032 : sw * 0.065;

    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final int unread = provider.unreadCount;

        return IconButton(
          tooltip: 'Notifications',
          padding: compact ? EdgeInsets.all(sw * 0.015) : null,
          constraints: compact ? const BoxConstraints() : null,
          onPressed: () => Navigator.pushNamed(context, '/notification-screen'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                unread > 0
                    ? Icons.notifications
                    : Icons.notifications_none_rounded,
                color: iconColor,
                size: iconSize,
              ),
              if (unread > 0)
                Positioned(
                  right: -sw * 0.012,
                  top: -sw * 0.008,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.012,
                      vertical: sw * 0.004,
                    ),
                    constraints: BoxConstraints(minWidth: sw * 0.042),
                    decoration: BoxDecoration(
                      color: PillBinColors.error,
                      borderRadius: BorderRadius.circular(sw * 0.05),
                      border: Border.all(color: iconColor, width: 1.2),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      textAlign: TextAlign.center,
                      style: PillBinBold.style(
                        fontSize: isTablet ? sw * 0.014 : sw * 0.026,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
