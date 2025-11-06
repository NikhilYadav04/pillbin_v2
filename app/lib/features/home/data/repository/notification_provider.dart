import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/home/data/network/notification_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  //* List of Notifications
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  void addNotifications(NotificationModel list) {
    _notifications.add(list);
    notifyListeners();
  }

  void deleteNotificationFromList(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
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

  //* Add Notification
  Future<String> addNotification(
      {required BuildContext context,
      required String title,
      required String description,
      required String status}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _notificationService.addNotification(
              title: title, description: description, status: status);

      if (response.statusCode == 201) {
        Map<String, dynamic> notiData = response.data!;

        String id = notiData["notification"]["_id"];
        String userId = notiData["notification"]["userId"];

        Logger().d(id);
        Logger().d(userId);

        Logger().d(_notifications.length);

        NotificationModel notification = NotificationModel(
            id: id, userId: userId, title: title, description: description);

        _notifications.add(notification);
        notifyListeners();

        Logger().d(_notifications.length);

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to add notification at the moment. Please try again later.");
        print(response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.notifications,
            title:
                "Unable to add notification at the moment. Please try again later.");
        print(response.message);
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.notifications,
          title:
              "Unable to add notification at the moment. Please try again later.");

      print(e.toString());
      return 'error';
    }
  }

  //* fetch notifications
  Future<String> fetchNotifications({
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _notificationService.getNotifications();
      if (response.statusCode == 200) {
        Map<String, dynamic> notiData = response.data!;

        List<NotificationModel> notificationsData =
            (notiData['notifications'] as List<dynamic>)
                .map((element) => NotificationModel.fromJson(element))
                .toList();

        _notifications = notificationsData;

        _isLoading = false;
        notifyListeners();

        return 'success';
      } else {
        _isLoading = false;
        notifyListeners();

        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.notifications,
          title:
              "Unable to fetch notifications at the moment. Please try again later.");

      print(e.toString());
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
