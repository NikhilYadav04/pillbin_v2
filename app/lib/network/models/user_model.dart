class Badge {
  bool achieved;
  DateTime? unlockedAt;

  Badge({required this.achieved, this.unlockedAt});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      achieved: json['achieved'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achieved': achieved,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

class Badges {
  final Badge firstTimer;
  final Badge ecoHelper;
  final Badge greenChampion;

  Badges({
    required this.firstTimer,
    required this.ecoHelper,
    required this.greenChampion,
  });

  factory Badges.fromJson(Map<String, dynamic> json) {
    return Badges(
      firstTimer: Badge.fromJson(json['firstTimer'] ?? {}),
      ecoHelper: Badge.fromJson(json['ecoHelper'] ?? {}),
      greenChampion: Badge.fromJson(json['greenChampion'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstTimer': firstTimer.toJson(),
      'ecoHelper': ecoHelper.toJson(),
      'greenChampion': greenChampion.toJson(),
    };
  }
}

class Medicine {
  final String? name;
  final String? dosage;
  final String? frequency;

  Medicine({this.name, this.dosage, this.frequency});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }
}

class MedicalCondition {
  final String? condition;
  final String? severity;

  MedicalCondition({this.condition, this.severity});

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      condition: json['condition'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'severity': severity,
    };
  }
}

class Coordinates {
  final double? latitude;
  final double? longitude;

  Coordinates({this.latitude, this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Location {
  final String? name;
  final Coordinates? coordinates;

  Location({this.name, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coordinates': coordinates?.toJson(),
    };
  }
}

class Stats {
  int totalMedicinesTracked;
  int expiringSoonCount;
  final int medicinesDisposedCount;
  final int campaignsJoinedCount;

  Stats({
    required this.totalMedicinesTracked,
    required this.expiringSoonCount,
    required this.medicinesDisposedCount,
    required this.campaignsJoinedCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalMedicinesTracked: json['totalMedicinesTracked'] ?? 0,
      expiringSoonCount: json['expiringSoonCount'] ?? 0,
      medicinesDisposedCount: json['medicinesDisposedCount'] ?? 0,
      campaignsJoinedCount: json['campaignsJoinedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMedicinesTracked': totalMedicinesTracked,
      'expiringSoonCount': expiringSoonCount,
      'medicinesDisposedCount': medicinesDisposedCount,
      'campaignsJoinedCount': campaignsJoinedCount,
    };
  }
}

class UserModel {
  final String id;
  final String phoneNumber;
  final bool isVerified;
  final String? fullName;
  final String? email;
  final List<Medicine> currentMedicines;
  final List<MedicalCondition> medicalConditions;
  final Location? location;
  final int medicineCount;
  final Stats stats;
  final Badges badges;
  final List<String> savedMedicalCenters;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.isVerified,
    this.fullName,
    this.email,
    required this.currentMedicines,
    required this.medicalConditions,
    this.location,
    required this.medicineCount,
    required this.stats,
    required this.badges,
    required this.savedMedicalCenters,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'] ?? "",
      isVerified: json['isVerified'] ?? false,
      fullName: json['fullName'] ?? "",
      email: json['email'] ?? "",
      currentMedicines: (json['currentMedicines'] as List<dynamic>? ?? [])
          .map((e) => Medicine.fromJson(e))
          .toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>? ?? [])
          .map((e) => MedicalCondition.fromJson(e))
          .toList(),
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      medicineCount: json['medicineCount'] ?? 0,
      stats: Stats.fromJson(json['stats'] ?? {}),
      badges: Badges.fromJson(json['badges'] ?? {}),
      savedMedicalCenters: (json['savedMedicalCenters'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      profileCompleted: json['profileCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'fullName': fullName,
      'email': email,
      'currentMedicines': currentMedicines.map((e) => e.toJson()).toList(),
      'medicalConditions': medicalConditions.map((e) => e.toJson()).toList(),
      'location': location?.toJson(),
      'medicineCount': medicineCount,
      'stats': stats.toJson(),
      'badges': badges.toJson(),
      'savedMedicalCenters': savedMedicalCenters,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    List<Medicine>? currentMedicines,
    List<MedicalCondition>? medicalConditions,
    Location? location,
    bool? profileCompleted,
    DateTime? updatedAt,
    List<String>? savedMedicalCenters,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phone ?? this.phoneNumber,
      isVerified: isVerified,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currentMedicines: currentMedicines ?? this.currentMedicines,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      location: location ?? this.location,
      medicineCount: medicineCount,
      stats: stats,
      badges: badges,
      savedMedicalCenters: savedMedicalCenters ?? this.savedMedicalCenters,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  ///]* Remove a medical center from savedMedicalCenters
  UserModel removeMedicalCenter(String centerId) {
    final updatedCenters = List<String>.from(savedMedicalCenters)
      ..remove(centerId);
    return copyWith(savedMedicalCenters: updatedCenters);
  }
}
