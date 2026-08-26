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

/// Image data model to match Node.js schema
class MedicineImage {
  final String? url;
  final String? publicId;

  MedicineImage({
    this.url,
    this.publicId,
  });

  factory MedicineImage.fromJson(Map<String, dynamic> json) {
    return MedicineImage(
      url: json["url"],
      publicId: json["publicId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "publicId": publicId,
    };
  }
}

/// Product links model
class ProductLinks {
  final String? tata1mg;
  final String? pharmeasy;
  final String? netmeds;

  ProductLinks({
    this.tata1mg,
    this.pharmeasy,
    this.netmeds,
  });

  factory ProductLinks.fromJson(Map<String, dynamic> json) {
    return ProductLinks(
      tata1mg: json["tata1mg"],
      pharmeasy: json["pharmeasy"],
      netmeds: json["netmeds"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tata1mg": tata1mg,
      "pharmeasy": pharmeasy,
      "netmeds": netmeds,
    };
  }
}

class Medicine {
  final String id;
  final String userId;
  final String name;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  MedicineStatus status;
  final DateTime addedDate;
  final String? notes;
  final String? dosage;
  final String? manufacturer;
  final String? type;
  final String? batchNumber;
  final MedicineImage? image; // Added image field
  final ProductLinks? productLinks; // Added product links
  final bool isDeleted; // Added isDeleted field
  final bool isRecurring;
  final int? refillIntervalDays;
  final String? familyMemberId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.purchaseDate,
    required this.expiryDate,
    this.status = MedicineStatus.active,
    DateTime? addedDate,
    this.notes,
    this.dosage,
    this.manufacturer,
    this.type,
    this.batchNumber,
    this.image, // Added
    this.productLinks, // Added
    this.isDeleted = false, // Added
    this.isRecurring = false,
    this.refillIntervalDays,
    this.familyMemberId,
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
      purchaseDate: DateTime.parse(json["purchaseDate"]),
      expiryDate: DateTime.parse(json["expiryDate"]),
      status: json["status"] != null
          ? MedicineStatusExtension.fromString(json["status"])
          : MedicineStatus.active,
      addedDate:
          json["addedDate"] != null ? DateTime.parse(json["addedDate"]) : null,
      notes: json["notes"],
      dosage: json["dosage"],
      manufacturer: json["manufacturer"],
      type: json["type"],
      batchNumber: json["batchNumber"],
      image:
          json["image"] != null ? MedicineImage.fromJson(json["image"]) : null,
      productLinks: json["productLinks"] != null
          ? ProductLinks.fromJson(json["productLinks"])
          : null,
      isDeleted: json["isDeleted"] ?? false,
      isRecurring: json["isRecurring"] ?? false,
      refillIntervalDays: json["refillIntervalDays"],
      familyMemberId: json["familyMemberId"] is Map
          ? json["familyMemberId"]["_id"]
          : json["familyMemberId"],
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
      "purchaseDate": purchaseDate.toIso8601String(),
      "expiryDate": expiryDate.toIso8601String(),
      "status": status.value,
      "addedDate": addedDate.toIso8601String(),
      "notes": notes,
      "dosage": dosage,
      "manufacturer": manufacturer,
      "type": type,
      "batchNumber": batchNumber,
      "image": image?.toJson(),
      "productLinks": productLinks?.toJson(),
      "isDeleted": isDeleted,
      "isRecurring": isRecurring,
      "refillIntervalDays": refillIntervalDays,
      "familyMemberId": familyMemberId,
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
    MedicineImage? image,
    ProductLinks? productLinks,
    bool? isDeleted,
    bool? isRecurring,
    int? refillIntervalDays,
    String? familyMemberId,
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
      image: image ?? this.image,
      productLinks: productLinks ?? this.productLinks,
      isDeleted: isDeleted ?? this.isDeleted,
      isRecurring: isRecurring ?? this.isRecurring,
      refillIntervalDays: refillIntervalDays ?? this.refillIntervalDays,
      familyMemberId: familyMemberId ?? this.familyMemberId,
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
    return 'Medicine{id: $id, name: $name, status: $status, expiryDate: $expiryDate, hasImage: ${image?.url != null}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
