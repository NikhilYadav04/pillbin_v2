import 'dart:convert';

enum MedicineType {
  tablets,
  capsules,
  syrups,
  injections,
  ointments,
  inhalers,
  drops,
  all,
}

extension MedicineTypeExtension on MedicineType {
  String get value {
    switch (this) {
      case MedicineType.tablets:
        return "tablets";
      case MedicineType.capsules:
        return "capsules";
      case MedicineType.syrups:
        return "syrups";
      case MedicineType.injections:
        return "injections";
      case MedicineType.ointments:
        return "ointments";
      case MedicineType.inhalers:
        return "inhalers";
      case MedicineType.drops:
        return "drops";
      case MedicineType.all:
        return "all";
    }
  }

  static MedicineType fromString(String type) {
    switch (type) {
      case "tablets":
        return MedicineType.tablets;
      case "capsules":
        return MedicineType.capsules;
      case "syrups":
        return MedicineType.syrups;
      case "injections":
        return MedicineType.injections;
      case "ointments":
        return MedicineType.ointments;
      case "inhalers":
        return MedicineType.inhalers;
      case "drops":
        return MedicineType.drops;
      case "all":
        return MedicineType.all;
      default:
        return MedicineType.all;
    }
  }
}

enum FacilityType { hospital, clinic, pharmacy, healthCenter }

extension FacilityTypeExtension on FacilityType {
  String get value {
    switch (this) {
      case FacilityType.hospital:
        return "hospital";
      case FacilityType.clinic:
        return "clinic";
      case FacilityType.pharmacy:
        return "pharmacy";
      case FacilityType.healthCenter:
        return "health_center";
    }
  }

  static FacilityType fromString(String type) {
    switch (type) {
      case "hospital":
        return FacilityType.hospital;
      case "clinic":
        return FacilityType.clinic;
      case "pharmacy":
        return FacilityType.pharmacy;
      case "health_center":
        return FacilityType.healthCenter;
      default:
        return FacilityType.pharmacy;
    }
  }
}

class OperatingHours {
  final String open;
  final String close;

  OperatingHours({required this.open, required this.close});

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json["open"] ?? "",
      close: json["close"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "open": open,
      "close": close,
    };
  }
}

class MedicalCenter {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final List<double> coordinates;
  final double distance;
  final List<MedicineType> acceptedMedicineTypes;
  final Map<String, OperatingHours>? operatingHours;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final FacilityType facilityType;
  final String? website;
  final String? email;
  final List<String> specialServices;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.coordinates,
    this.distance = 0,
    this.acceptedMedicineTypes = const [MedicineType.all],
    this.operatingHours,
    this.isActive = true,
    this.rating = 0,
    this.totalReviews = 0,
    this.facilityType = FacilityType.pharmacy,
    this.website,
    this.email,
    this.specialServices = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory MedicalCenter.fromJson(Map<String, dynamic> json) {
    return MedicalCenter(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      coordinates: (json["location"]?["coordinates"] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      distance: (json["distance"] ?? 0).toDouble(),
      acceptedMedicineTypes: (json["acceptedMedicineTypes"] as List<dynamic>?)
              ?.map((e) => MedicineTypeExtension.fromString(e))
              .toList() ??
          [MedicineType.all],
      operatingHours: json["operatingHours"] != null
          ? (json["operatingHours"] as Map<String, dynamic>).map(
              (day, value) => MapEntry(
                day,
                OperatingHours.fromJson(value),
              ),
            )
          : null,
      isActive: json["isActive"] ?? true,
      rating: (json["rating"] ?? 0).toDouble(),
      totalReviews: json["totalReviews"] ?? 0,
      facilityType:
          FacilityTypeExtension.fromString(json["facilityType"] ?? ""),
      website: json["website"],
      email: json["email"],
      specialServices: (json["specialServices"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
      "name": name,
      "address": address,
      "phoneNumber": phoneNumber,
      "location": {
        "type": "Point",
        "coordinates": coordinates,
      },
      "distance": distance,
      "acceptedMedicineTypes":
          acceptedMedicineTypes.map((e) => e.value).toList(),
      "operatingHours":
          operatingHours?.map((day, value) => MapEntry(day, value.toJson())),
      "isActive": isActive,
      "rating": rating,
      "totalReviews": totalReviews,
      "facilityType": facilityType.value,
      "website": website,
      "email": email,
      "specialServices": specialServices,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  static String encode(List<MedicalCenter> centers) =>
      json.encode(centers.map((c) => c.toJson()).toList());

  static List<MedicalCenter> decode(String centers) =>
      (json.decode(centers) as List<dynamic>)
          .map((c) => MedicalCenter.fromJson(c))
          .toList();
}
