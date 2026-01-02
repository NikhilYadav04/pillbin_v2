class HealthRagModel {
  final String id;
  final String userId;
  final String pdfName;
  final String? pdfDescription;
  final List<QueryRagModel> queries;
  final DateTime uploadedAt;

  HealthRagModel({
    required this.id,
    required this.userId,
    required this.pdfName,
    this.pdfDescription,
    required this.queries,
    required this.uploadedAt,
  });

  factory HealthRagModel.fromJson(Map<String, dynamic> json) {
    return HealthRagModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      pdfName: json['pdfName'] ?? '',
      pdfDescription: json['pdfDescription'],
      queries: (json['queries'] as List<dynamic>?)
              ?.map((e) => QueryRagModel.fromJson(e))
              .toList() ??
          [],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'pdfName': pdfName,
      'pdfDescription': pdfDescription,
      'queries': queries.map((e) => e.toJson()).toList(),
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class QueryRagModel {
  final String content;
  final bool byUser;
  final DateTime createdAt;

  QueryRagModel({
    required this.content,
    required this.byUser,
    required this.createdAt,
  });

  factory QueryRagModel.fromJson(Map<String, dynamic> json) {
    return QueryRagModel(
      content: json['content'] ?? '',
      byUser: json['byUser'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'byUser': byUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
