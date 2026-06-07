class BlogImage {
  final String url;
  final String publicId;

  BlogImage({
    required this.url,
    required this.publicId,
  });

  factory BlogImage.fromJson(Map<String, dynamic> json) {
    return BlogImage(
      url: json['url'] as String,
      publicId: json['publicId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

class BlogModel {
  final String id;
  final Map<String, dynamic> author;
  final String content;
  final String role;
  final String? experience;
  final String? phone;
  final String? email;
  final String? name;
  final List<BlogImage> images;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogModel({
    required this.id,
    required this.author,
    required this.content,
    required this.role,
    this.experience,
    this.phone,
    this.email,
    this.name,
    required this.images,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['_id'] as String,
      author: json['author'] as Map<String, dynamic>,
      content: json['content'] as String,
      role: json['role'] as String,
      experience: json['experience'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => BlogImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLiked: json['liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author,
      'content': content,
      'role': role,
      'experience': experience,
      'phone': phone,
      'email': email,
      'name': name,
      'images': images.map((e) => e.toJson()).toList(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'liked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BlogModel copyWith({
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return BlogModel(
      id: id,
      author: author,
      content: content,
      role: role,
      experience: experience,
      phone: phone,
      email: email,
      name: name,
      images: images,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
