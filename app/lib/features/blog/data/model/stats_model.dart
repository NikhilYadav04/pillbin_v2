class LikeAuthor {
  final String id;
  final String name;
  final String email;

  LikeAuthor({
    required this.id,
    required this.name,
    required this.email,
  });

  factory LikeAuthor.fromJson(Map<String, dynamic> json) {
    return LikeAuthor(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
      };
}

class LikeModel {
  final String id;
  //final String blogId;
  //final LikeAuthor user;
  final DateTime createdAt;
  final String fullName;
  final String email;

  LikeModel({
    required this.id,
    //required this.blogId,

    required this.createdAt,
    required this.fullName,
    required this.email,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['_id'] as String,
      //blogId: json['blog'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        //'blog': blogId,
        'fullName': fullName,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
      };
}

class CommentAuthor {
  final String id;
  final String name;
  final String email;

  CommentAuthor({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
      };
}

class CommentModel {
  final String id;
  final String blogId;
  final CommentAuthor author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.blogId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] as String,
      blogId: json['blog'] as String,
      author: CommentAuthor.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'blog': blogId,
        'author': author.toJson(),
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  CommentModel copyWith({String? content}) {
    return CommentModel(
      id: id,
      blogId: blogId,
      author: author,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
