import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class NotificationService extends ApiService {
  //* get notifications
  Future<ApiResponse<Map<String, dynamic>>> getNotifications(
      {int page = 1, int limit = 20}) async {
    return get(ApiEndpoints.notificationsPaged(page: page, limit: limit),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* mark read — pass null id to mark everything
  Future<ApiResponse<Map<String, dynamic>>> markRead({String? id}) async {
    return post(ApiEndpoints.markNotificationRead,
        data: id != null ? {'id': id} : {'all': true},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* unread count
  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    return get(ApiEndpoints.notificationUnreadCount,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* device tokens
  Future<ApiResponse<Map<String, dynamic>>> registerDeviceToken({
    required String fcmToken,
    required String deviceId,
    required String deviceType,
    String? deviceModel,
    String? appVersion,
  }) async {
    return post(ApiEndpoints.registerDeviceToken,
        data: {
          'fcmToken': fcmToken,
          'deviceId': deviceId,
          'deviceType': deviceType,
          if (deviceModel != null) 'deviceModel': deviceModel,
          if (appVersion != null) 'appVersion': appVersion,
        },
        fromJson: (data) => data as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> deactivateDeviceToken(
      {required String fcmToken}) async {
    return post(ApiEndpoints.deactivateDeviceToken,
        data: {'fcmToken': fcmToken},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* delete a notification
  Future<ApiResponse<Map<String, dynamic>>> deleteNotification(
      {required String notificationId}) async {
    return delete(ApiEndpoints.deleteNotification(notificationId),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* clear all notifications
  Future<ApiResponse<Map<String, dynamic>>> deleteAllNotifications() async {
    return delete(ApiEndpoints.deleteAllNotification,
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
