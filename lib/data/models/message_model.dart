import 'package:cloud_firestore/cloud_firestore.dart';

/// Message types
enum MessageType {
  text,
  image,
  system,
}


/// Model representing a chat message
class MessageModel {
  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.senderName,
    this.senderPhoto,
  });

  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  // Optional sender details (populated separately)
  final String? senderName;
  final String? senderPhoto;


  /// Create from Firestore document
  factory MessageModel.fromFirestore(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] ?? '',
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      type: _parseMessageType(data['type']),
      isRead: data['isRead'] ?? false,
      readAt: _parseDateTime(data['readAt']),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      senderName: data['senderName'],
      senderPhoto: data['senderPhoto'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to JSON (for local storage/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'senderName': senderName,
      'senderPhoto': senderPhoto,
    };
  }

  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      type: _parseMessageType(json['type']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      senderName: json['senderName'],
      senderPhoto: json['senderPhoto'],
    );
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    MessageType? type,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    String? senderName,
    String? senderPhoto,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
    );
  }

  /// Check if message is from current user
  bool isFromUser(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Parse message type from string
  static MessageType _parseMessageType(dynamic value) {
    if (value == null) return MessageType.text;
    if (value is MessageType) return value;
    switch (value.toString().toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Helper to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, content: $content, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
