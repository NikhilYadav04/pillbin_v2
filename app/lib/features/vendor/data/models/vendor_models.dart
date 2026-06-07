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

  const RequestMedicine({required this.name, required this.quantity});

  factory RequestMedicine.fromJson(Map<String, dynamic> json) =>
      RequestMedicine(
        name: json['name'] as String? ?? '',
        quantity: json['quantity']?.toString() ?? '',
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
    );
  }

  DonationRequest copyWith({
    String? status,
    String? vendorNote,
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
      );
}
