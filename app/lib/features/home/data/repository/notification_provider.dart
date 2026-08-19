import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/home/data/network/notification_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/notification_model.dart';
import 'package:pillbin/network/utils/http_client.dart';

class NotificationProvider extends ChangeNotifier {
  //* List of Notifications
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  //* Server count, not the loaded rows — with paging the list only ever
  //* holds a page, so counting it would cap the badge
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _page = 1;
  bool _hasMore = true;
  bool get hasMoreNotifications => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  static const int _pageSize = 20;

  void deleteNotificationFromList(String notificationId) {
    final removed = _notifications.where((n) => n.id == notificationId);
    if (removed.isNotEmpty && !removed.first.isRead && _unreadCount > 0) {
      _unreadCount -= 1;
    }
    _notifications.removeWhere((n) => n.id == notificationId);
    if (_totalCount > 0) _totalCount -= 1;
    notifyListeners();
  }

  void refresh() {
    Logger().d(_notifications.length);
    notifyListeners();
  }

  //* getters and setters
  bool _isLoading = false;
  bool get isLoafing => _isLoading;

  //* services
  NotificationService _notificationService = NotificationService();

  //* Functions

  //* fetch notifications
  Future<String> fetchNotifications(
      {required BuildContext context, bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      if (!forceRefresh &&
          (!isOnline || await _cacheManager.hasValidNotificationsCache())) {
        final cachedData = await _cacheManager.getCachedNotifications();

        if (cachedData != null) {
          List<NotificationModel> notificationsData = cachedData
              .map((element) => NotificationModel.fromJson(element))
              .toList();

          _notifications = notificationsData;
          _unreadCount = notificationsData.where((n) => !n.isRead).length;
          _totalCount = notificationsData.length;
          _page = 1;
          _hasMore = false;
          _isLoading = false;
          notifyListeners();

          if (!isOnline && context.mounted) {
            CustomSnackBar.show(
              context: context,
              icon: Icons.cloud_off,
              title: "Offline - Showing cached data",
            );
          }

          return 'success';
        }
      }

      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _notificationService.getNotifications(
                page: 1, limit: _pageSize);

        if (response.statusCode == 200) {
          Map<String, dynamic> notiData = response.data!;

          //* Only page one is cached — it is all the offline view needs
          await _cacheManager.cacheNotifications(notiData['notifications']);

          List<NotificationModel> notificationsData =
              (notiData['notifications'] as List<dynamic>)
                  .map((element) => NotificationModel.fromJson(element))
                  .toList();

          _notifications = notificationsData;
          _unreadCount = (notiData['unreadCount'] as num?)?.toInt() ?? 0;
          _totalCount = (notiData['totalCount'] as num?)?.toInt() ??
              notificationsData.length;

          final pagination = notiData['pagination'] as Map? ?? const {};
          final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
          _page = 1;
          _hasMore = 1 < totalPages;

          _isLoading = false;
          notifyListeners();

          return 'success';
        } else {
          _isLoading = false;
          notifyListeners();
          return 'error';
        }
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.cloud_off,
            title: "No internet connection",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Logger().e(e.toString());
      return 'error';
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || _isLoading || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _notificationService.getNotifications(
          page: _page + 1, limit: _pageSize);

      if (response.statusCode == 200) {
        final data = response.data!;
        final incoming = (data['notifications'] as List<dynamic>? ?? [])
            .map((element) => NotificationModel.fromJson(element))
            .toList();

        final pagination = data['pagination'] as Map? ?? const {};
        final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

        _notifications = [..._notifications, ...incoming];
        _page += 1;
        _hasMore = _page < totalPages;
      }
    } catch (e) {
      Logger().e(e.toString());
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  //* mark read
  Future<String> markRead({String? notificationId}) async {
    final previous = List<NotificationModel>.from(_notifications);
    final previousUnread = _unreadCount;

    final int index = _notifications.indexWhere((n) => n.id == notificationId);
    if (notificationId != null && index == -1) return 'error';
    final String? groupKey =
        index == -1 ? null : _notifications[index].groupKey;

    _notifications = _notifications.map((n) {
      if (notificationId == null) return n.copyWith(isRead: true);
      if (groupKey != null && n.groupKey == groupKey) {
        return n.copyWith(isRead: true);
      }
      if (n.id == notificationId) return n.copyWith(isRead: true);
      return n;
    }).toList();

    //* Marking all clears the badge; a single tap only shifts it by the rows
    //* that actually changed here
    if (notificationId == null) {
      _unreadCount = 0;
    } else {
      final stillUnread = _notifications.where((n) => !n.isRead).length;
      final wasUnread = previous.where((n) => !n.isRead).length;
      _unreadCount = (_unreadCount - (wasUnread - stillUnread))
          .clamp(0, _unreadCount);
    }
    notifyListeners();

    try {
      ApiResponse<Map<String, dynamic>> response =
          await _notificationService.markRead(id: notificationId);

      if (response.statusCode == 200) {
        await _cacheManager
            .cacheNotifications(_notifications.map((n) => n.toJson()).toList());
        return 'success';
      }

      _notifications = previous;
      _unreadCount = previousUnread;
      notifyListeners();
      return 'error';
    } catch (e) {
      _notifications = previous;
      _unreadCount = previousUnread;
      notifyListeners();
      Logger().e(e.toString());
      return 'error';
    }
  }

  //* delete notifications
  Future<String> deleteNotification(
      {required BuildContext context, required String notificationId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (notificationId.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title: "Notification ID is required");
      }

      ApiResponse<Map<String, dynamic>> response = await _notificationService
          .deleteNotification(notificationId: notificationId);

      if (response.statusCode == 200) {
        deleteNotificationFromList(notificationId);

        _isLoading = false;
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to delete notification at the moment. Please try again later.");
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to delete notification at the moment. Please try again later.");
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.notifications,
          title:
              "Unable to delete notification at the moment. Please try again later.");

      print(e.toString());
      return 'error';
    }
  }

  //* clear all notifications
  Future<String> deleteAllNotification({
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _notificationService.deleteAllNotifications();

      if (response.statusCode == 200) {
        _notifications = [];

        _isLoading = false;
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to clear notification at the moment. Please try again later.");
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to clear notification at the moment. Please try again later.");
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.notifications,
          title:
              "Unable to clear notification at the moment. Please try again later.");

      print(e.toString());
      return 'error';
    }
  }

  //* <--------------Reset--------------->

  Future<void> reset() async {
    _notifications.clear();
    _isLoading = false;
    notifyListeners();
  }
}
