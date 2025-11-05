enum NotificationStatus { important, normal, urgent, alert }

extension NotificationStatusExtension on NotificationStatus {
  String get value {
    switch (this) {
      case NotificationStatus.important:
        return "important";
      case NotificationStatus.normal:
        return "normal";
      case NotificationStatus.urgent:
        return "urgent";
      case NotificationStatus.alert:
        return "alert";
    }
  }

  static NotificationStatus fromString(String status) {
    switch (status) {
      case "important":
        return NotificationStatus.important;
      case "normal":
        return NotificationStatus.normal;
      case "urgent":
        return NotificationStatus.urgent;
      case "alert":
        return NotificationStatus.alert;
      default:
        return NotificationStatus.normal;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  NotificationStatus status;
  bool isRead;
  final DateTime createdAt;
  DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = NotificationStatus.normal,
    this.isRead = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] != null
          ? NotificationStatusExtension.fromString(json["status"])
          : NotificationStatus.normal,
      isRead: json["isRead"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "status": status.value,
      "isRead": isRead,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
