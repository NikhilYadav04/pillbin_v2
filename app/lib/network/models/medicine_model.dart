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
  final DateTime purchaseDate; // Added to match schema
  final DateTime expiryDate;
  MedicineStatus status;
  final DateTime addedDate;
  final String? notes;
  final String? dosage;
  final String? manufacturer;
  final String? type; // Added to match schema
  final String? batchNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.purchaseDate, // Now required to match schema
    required this.expiryDate,
    this.status = MedicineStatus.active,
    DateTime? addedDate,
    this.notes,
    this.dosage,
    this.manufacturer,
    this.type, // Added
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
      purchaseDate: DateTime.parse(json["purchaseDate"]), // Added
      expiryDate: DateTime.parse(json["expiryDate"]),
      status: json["status"] != null
          ? MedicineStatusExtension.fromString(json["status"])
          : MedicineStatus.active,
      addedDate:
          json["addedDate"] != null ? DateTime.parse(json["addedDate"]) : null,
      notes: json["notes"],
      dosage: json["dosage"],
      manufacturer: json["manufacturer"],
      type: json["type"], // Added
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
      "purchaseDate": purchaseDate.toIso8601String(), // Added
      "expiryDate": expiryDate.toIso8601String(),
      "status": status.value,
      "addedDate": addedDate.toIso8601String(),
      "notes": notes,
      "dosage": dosage,
      "manufacturer": manufacturer,
      "type": type, // Added
      "batchNumber": batchNumber,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this medicine with updated fields
  Medicine copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    MedicineStatus? status,
    DateTime? addedDate,
    String? notes,
    String? dosage,
    String? manufacturer,
    String? type,
    String? batchNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
      dosage: dosage ?? this.dosage,
      manufacturer: manufacturer ?? this.manufacturer,
      type: type ?? this.type,
      batchNumber: batchNumber ?? this.batchNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

  @override
  String toString() {
    return 'Medicine{id: $id, name: $name, status: $status, expiryDate: $expiryDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
