import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class NotificationService extends ApiService {
  //* add notification
  Future<ApiResponse<Map<String, dynamic>>> addNotification(
      {required String title,
      required String description,
      required String status}) async {
    return post(ApiEndpoints.Notification,
        data: {'title': title, 'description': description, 'status': status},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* get notifications
  Future<ApiResponse<Map<String, dynamic>>> getNotifications() async {
    return get(ApiEndpoints.Notification,
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
