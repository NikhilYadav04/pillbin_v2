class VendorCenterImage {
  final String url;
  final String publicId;

  const VendorCenterImage({required this.url, required this.publicId});

  factory VendorCenterImage.fromJson(Map<String, dynamic> json) =>
      VendorCenterImage(
        url: json['url'] as String? ?? '',
        publicId: json['public_id'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'url': url, 'public_id': publicId};
}

class VendorCenter {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String? email;
  final String? website;
  final String facilityType;
  final bool isActive;
  final bool isVendorManaged;
  final int donationCount;
  final List<VendorCenterImage> images;
  final String? verificationStatus;
  final String? verificationRejectionReason;
  final String? verifiedAt;

  const VendorCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.email,
    this.website,
    required this.facilityType,
    required this.isActive,
    required this.isVendorManaged,
    required this.donationCount,
    required this.images,
    this.verificationStatus,
    this.verificationRejectionReason,
    this.verifiedAt,
  });

  factory VendorCenter.fromJson(Map<String, dynamic> json) => VendorCenter(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        email: json['email'] as String?,
        website: json['website'] as String?,
        facilityType: json['facilityType'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? false,
        isVendorManaged: json['isVendorManaged'] as bool? ?? false,
        donationCount: json['donationCount'] as int? ?? 0,
        images: (json['images'] as List? ?? [])
            .map((img) => VendorCenterImage.fromJson(img as Map<String, dynamic>))
            .toList(),
        verificationStatus: json['verificationStatus'] as String?,
        verificationRejectionReason:
            json['verificationRejectionReason'] as String?,
        verifiedAt: json['verifiedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'address': address,
        'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
        if (website != null) 'website': website,
        'facilityType': facilityType,
        'isActive': isActive,
        'isVendorManaged': isVendorManaged,
        'donationCount': donationCount,
        'images': images.map((i) => i.toJson()).toList(),
        if (verificationStatus != null) 'verificationStatus': verificationStatus,
        if (verificationRejectionReason != null)
          'verificationRejectionReason': verificationRejectionReason,
      };

  VendorCenter copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    String? facilityType,
    bool? isActive,
    bool? isVendorManaged,
    int? donationCount,
    List<VendorCenterImage>? images,
    String? verificationStatus,
  }) =>
      VendorCenter(
        id: id,
        name: name ?? this.name,
        address: address ?? this.address,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        website: website ?? this.website,
        facilityType: facilityType ?? this.facilityType,
        isActive: isActive ?? this.isActive,
        isVendorManaged: isVendorManaged ?? this.isVendorManaged,
        donationCount: donationCount ?? this.donationCount,
        images: images ?? this.images,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        verificationRejectionReason: verificationRejectionReason,
        verifiedAt: verifiedAt,
      );
}

class InventoryItem {
  String category;
  String acceptanceStatus;
  List<String> specificNames;
  String notes;

  InventoryItem({
    required this.category,
    required this.acceptanceStatus,
    required this.specificNames,
    this.notes = '',
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        category: json['category'] as String? ?? '',
        acceptanceStatus: json['acceptanceStatus'] as String? ?? 'accepting',
        specificNames: List<String>.from(json['specificNames'] as List? ?? []),
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'acceptanceStatus': acceptanceStatus,
        'specificNames': specificNames,
        if (notes.isNotEmpty) 'notes': notes,
      };
}

class RequestMedicine {
  final String name;
  final String quantity;
  final String? category;
  final String? condition;

  const RequestMedicine({
    required this.name,
    required this.quantity,
    this.category,
    this.condition,
  });

  factory RequestMedicine.fromJson(Map<String, dynamic> json) =>
      RequestMedicine(
        name: json['name'] as String? ?? '',
        quantity: json['quantity']?.toString() ?? '',
        category: json['category'] as String?,
        condition: json['condition'] as String?,
      );
}

class RequestUser {
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  const RequestUser({this.fullName, this.email, this.phoneNumber});

  factory RequestUser.fromJson(Map<String, dynamic> json) => RequestUser(
        fullName: json['fullName'] as String?,
        email: json['email'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );

  String get displayName => fullName ?? email ?? 'User';
}

class MonthPoint {
  final String label;
  final int total;
  final int completed;

  const MonthPoint(
      {required this.label, required this.total, required this.completed});

  factory MonthPoint.fromJson(Map<String, dynamic> json) => MonthPoint(
        label: json['label'] as String? ?? '',
        total: json['total'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
      );

  /// "2026-08" -> "Aug", "2026-Q3" -> "Q3 '26", "2026" -> "2026"
  String get axisLabel {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final parts = label.split('-');
    if (parts.length != 2) return label;

    if (parts[1].startsWith('Q')) {
      final yy = parts[0].length == 4 ? parts[0].substring(2) : parts[0];
      return "${parts[1]} '$yy";
    }

    final m = int.tryParse(parts[1]);
    if (m == null || m < 1 || m > 12) return label;
    return names[m - 1];
  }
}

class TopMedicine {
  final String name;
  final int count;

  const TopMedicine({required this.name, required this.count});

  factory TopMedicine.fromJson(Map<String, dynamic> json) => TopMedicine(
        name: json['name'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );

  String get displayName {
    if (name.isEmpty) return 'Unnamed';
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class VendorAnalytics {
  final int total;
  final int pending;
  final int approved;
  final int completed;
  final int rejected;
  final int cancelled;
  final int fulfilmentRate;
  final int? avgApprovalMinutes;
  final double rating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;
  final List<MonthPoint> timeline;
  final List<TopMedicine> topMedicines;
  final String granularity;

  const VendorAnalytics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.completed,
    required this.rejected,
    required this.cancelled,
    required this.fulfilmentRate,
    this.avgApprovalMinutes,
    required this.rating,
    required this.totalReviews,
    this.ratingBreakdown = const {},
    required this.timeline,
    required this.topMedicines,
    this.granularity = 'month',
  });

  factory VendorAnalytics.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return VendorAnalytics(
      total: summary['total'] as int? ?? 0,
      pending: summary['pending'] as int? ?? 0,
      approved: summary['approved'] as int? ?? 0,
      completed: summary['completed'] as int? ?? 0,
      rejected: summary['rejected'] as int? ?? 0,
      cancelled: summary['cancelled'] as int? ?? 0,
      fulfilmentRate: summary['fulfilmentRate'] as int? ?? 0,
      avgApprovalMinutes: (summary['avgApprovalMinutes'] as num?)?.toInt(),
      rating: (summary['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: summary['totalReviews'] as int? ?? 0,
      ratingBreakdown: (summary['ratingBreakdown'] as Map?)?.map(
            (k, v) => MapEntry(
                int.tryParse(k.toString()) ?? 0, (v as num?)?.toInt() ?? 0),
          ) ??
          const {},
      timeline: (json['timeline'] as List? ?? [])
          .map((e) => MonthPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMedicines: (json['topMedicines'] as List? ?? [])
          .map((e) => TopMedicine.fromJson(e as Map<String, dynamic>))
          .toList(),
      granularity: json['granularity'] as String? ?? 'month',
    );
  }

  bool get hasData => total > 0;

  String get avgReplyLabel {
    final m = avgApprovalMinutes;
    if (m == null) return '—';
    if (m < 60) return '${m}m';
    if (m < 2880) return '${(m / 60).toStringAsFixed(1)}h';
    return '${(m / 1440).toStringAsFixed(1)}d';
  }

  String get periodUnit => granularity == 'year'
      ? 'year'
      : granularity == 'quarter'
          ? 'quarter'
          : 'month';

  String get periodNoun => granularity == 'year'
      ? 'years'
      : granularity == 'quarter'
          ? 'quarters'
          : 'months';

  MonthPoint? get busiestPeriod {
    if (timeline.isEmpty) return null;
    final peak = timeline.reduce((a, b) => b.total > a.total ? b : a);
    return peak.total == 0 ? null : peak;
  }
}

class DonationRequest {
  final String id;
  final String status;
  final List<RequestMedicine> medicines;
  final RequestUser? user;
  final String? contactPreference;
  final String? userNote;
  final String? vendorNote;
  final String? scheduledDate;
  final List<String> medicinePhotoUrls;
  final List<dynamic> statusHistory;
  final String? createdAt;

  const DonationRequest({
    required this.id,
    required this.status,
    required this.medicines,
    this.user,
    this.contactPreference,
    this.userNote,
    this.vendorNote,
    this.scheduledDate,
    this.medicinePhotoUrls = const [],
    this.statusHistory = const [],
    this.createdAt,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    final rawUser = json['userId'];
    RequestUser? user;
    if (rawUser is Map<String, dynamic>) {
      user = RequestUser.fromJson(rawUser);
    }

    return DonationRequest(
      id: json['_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      medicines: (json['medicines'] as List? ?? [])
          .map((m) => RequestMedicine.fromJson(m as Map<String, dynamic>))
          .toList(),
      user: user,
      contactPreference: json['contactPreference'] as String?,
      userNote: json['userNote'] as String?,
      vendorNote: json['vendorNote'] as String?,
      scheduledDate: json['scheduledDate'] as String?,
      medicinePhotoUrls: (json['medicinePhotos'] as List? ?? [])
          .map((p) => (p as Map<String, dynamic>)['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      statusHistory: json['statusHistory'] as List? ?? const [],
      createdAt: json['createdAt'] as String?,
    );
  }

  DonationRequest copyWith({
    String? status,
    String? vendorNote,
    List<dynamic>? statusHistory,
  }) =>
      DonationRequest(
        id: id,
        status: status ?? this.status,
        medicines: medicines,
        user: user,
        contactPreference: contactPreference,
        userNote: userNote,
        vendorNote: vendorNote ?? this.vendorNote,
        scheduledDate: scheduledDate,
        medicinePhotoUrls: medicinePhotoUrls,
        statusHistory: statusHistory ?? this.statusHistory,
        createdAt: createdAt,
      );
}
