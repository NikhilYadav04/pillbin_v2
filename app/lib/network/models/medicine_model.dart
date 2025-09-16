import 'dart:convert';

/// Enum for medicine status
enum MedicineStatus { active, expiringSoon, expired }

/// Extension to convert enum <-> String
extension MedicineStatusExtension on MedicineStatus {
  String get value {
    switch (this) {
      case MedicineStatus.active:
        return "active";
      case MedicineStatus.expiringSoon:
        return "expiring_soon";
      case MedicineStatus.expired:
        return "expired";
    }
  }

  static MedicineStatus fromString(String status) {
    switch (status) {
      case "active":
        return MedicineStatus.active;
      case "expiring_soon":
        return MedicineStatus.expiringSoon;
      case "expired":
        return MedicineStatus.expired;
      default:
        return MedicineStatus.active; // fallback
    }
  }
}

class Medicine {
  final String id;
  final String userId;
  final String name;
  final DateTime expiryDate;
  MedicineStatus status;
  final DateTime addedDate;
  final String? notes;
  final String? dosage;
  final String? manufacturer;
  final String? batchNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.expiryDate,
    this.status = MedicineStatus.active,
    DateTime? addedDate,
    this.notes,
    this.dosage,
    this.manufacturer,
    this.batchNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : addedDate = addedDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Method to update medicine status based on expiry date
  void updateStatus() {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    if (daysUntilExpiry <= 0) {
      status = MedicineStatus.expired;
    } else if (daysUntilExpiry <= 5) {
      status = MedicineStatus.expiringSoon;
    } else {
      status = MedicineStatus.active;
    }
  }

  /// Factory from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      name: json["name"] ?? "",
      expiryDate: DateTime.parse(json["expiryDate"]),
      status: json["status"] != null
          ? MedicineStatusExtension.fromString(json["status"])
          : MedicineStatus.active,
      addedDate:
          json["addedDate"] != null ? DateTime.parse(json["addedDate"]) : null,
      notes: json["notes"],
      dosage: json["dosage"],
      manufacturer: json["manufacturer"],
      batchNumber: json["batchNumber"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : DateTime.now(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "name": name,
      "expiryDate": expiryDate.toIso8601String(),
      "status": status.value,
      "addedDate": addedDate.toIso8601String(),
      "notes": notes,
      "dosage": dosage,
      "manufacturer": manufacturer,
      "batchNumber": batchNumber,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  /// Encode list of medicines to JSON string
  static String encode(List<Medicine> medicines) => json.encode(
        medicines.map((med) => med.toJson()).toList(),
      );

  /// Decode JSON string to list of medicines
  static List<Medicine> decode(String medicines) =>
      (json.decode(medicines) as List<dynamic>)
          .map((med) => Medicine.fromJson(med))
          .toList();
}
