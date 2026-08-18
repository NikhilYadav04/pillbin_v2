import 'dart:convert';

class ChatMessage {
  final String id;
  final MessageRole role;
  final String message;
  final DateTime timestamp;
  final bool isTable;
  final List<List<String>>? tableRows;
  final List<String>? tableColumns;
  final double? confidence;

  ChatMessage(
      {required this.id,
      required this.role,
      required this.message,
      required this.timestamp,
      this.isTable = false,
      this.tableRows,
      this.tableColumns,
      this.confidence});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    dynamic raw = json['message'];

    String msg = '';
    bool isTable = false;
    List<List<String>>? tableRows;
    List<String>? tableColumns;
    double? confidence;

    if (raw is Map<String, dynamic>) {
      // History path: nested object
      msg = raw['message'] ?? '';
      isTable = raw['isTable'] ?? false;
      tableColumns = raw['tableColumns'] != null
          ? List<String>.from(raw['tableColumns'])
          : null;
      tableRows = raw['tableRows'] != null
          ? (raw['tableRows'] as List)
              .map((row) => List<String>.from(row))
              .toList()
          : null;
      confidence = (raw['confidence'] as num?)?.toDouble();
    } else if (raw is String) {
      msg = raw;
      try {
        final decoded = jsonDecode(msg);
        if (decoded is Map) {
          msg = decoded['message'] ?? msg;
          isTable = decoded['isTable'] ?? false;
          tableColumns = decoded['tableColumns'] != null
              ? List<String>.from(decoded['tableColumns'])
              : null;
          tableRows = decoded['tableRows'] != null
              ? (decoded['tableRows'] as List)
                  .map((row) => List<String>.from(row))
                  .toList()
              : null;
          confidence = (decoded['confidence'] as num?)?.toDouble();
        }
      } catch (_) {}
    }

    // ✅ Also parse top-level isTable/tableRows/tableColumns
    // (for direct queryAgent responses where they sit alongside message)
    if (!isTable && json['isTable'] == true) {
      isTable = json['isTable'] ?? false;
      tableColumns = json['tableColumns'] != null
          ? List<String>.from(json['tableColumns'])
          : null;
      tableRows = json['tableRows'] != null
          ? (json['tableRows'] as List)
              .map((row) => List<String>.from(row))
              .toList()
          : null;
    }

    confidence ??= (json['confidence'] as num?)?.toDouble();

    return ChatMessage(
      id: json['id'] ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.agent,
      message: msg,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isTable: isTable,
      tableRows: tableRows,
      tableColumns: tableColumns,
      confidence: confidence,
    );
  }

  ChatMessage copyWith({String? id}) => ChatMessage(
        id: id ?? this.id,
        role: role,
        message: message,
        timestamp: timestamp,
        isTable: isTable,
        tableRows: tableRows,
        tableColumns: tableColumns,
        confidence: confidence,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };
}

enum MessageRole { user, agent }
