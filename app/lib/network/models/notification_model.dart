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
  final String type;
  final String? entityType;
  final String? entityId;
  final String? groupKey;
  bool isRead;
  final DateTime createdAt;
  DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = NotificationStatus.normal,
    this.type = "",
    this.entityType,
    this.entityId,
    this.groupKey,
    this.isRead = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      status: status,
      type: type,
      entityType: entityType,
      entityId: entityId,
      groupKey: groupKey,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime _parseLocal(dynamic value) {
    if (value == null) return DateTime.now();
    return (DateTime.tryParse(value.toString()) ?? DateTime.now()).toLocal();
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      status: json["status"] != null
          ? NotificationStatusExtension.fromString(json["status"])
          : NotificationStatus.normal,
      type: json["type"] ?? "",
      entityType: json["entityType"],
      entityId: json["entityId"]?.toString(),
      groupKey: json["groupKey"],
      isRead: json["isRead"] ?? false,
      createdAt: _parseLocal(json["createdAt"]),
      updatedAt: _parseLocal(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "status": status.value,
      "type": type,
      "entityType": entityType,
      "entityId": entityId,
      "groupKey": groupKey,
      "isRead": isRead,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
