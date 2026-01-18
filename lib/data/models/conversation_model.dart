import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a chat conversation
class ConversationModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  // Participant details (populated separately)
  final String? participantId;
  final String? participantName;
  final String? participantPhoto;
  final bool isOnline;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
    this.participantId,
    this.participantName,
    this.participantPhoto,
    this.isOnline = false,
  });

  /// Create from Firestore document
  factory ConversationModel.fromFirestore(Map<String, dynamic> data) {
    return ConversationModel(
      id: data['id'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageAt: _parseDateTime(data['lastMessageAt']),
      unreadCount: data['unreadCount'] ?? 0,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      participantId: data['participantId'],
      participantName: data['participantName'],
      participantPhoto: data['participantPhoto'],
      isOnline: data['isOnline'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to JSON (for local storage/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'participantId': participantId,
      'participantName': participantName,
      'participantPhoto': participantPhoto,
      'isOnline': isOnline,
    };
  }

  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      participantId: json['participantId'],
      participantName: json['participantName'],
      participantPhoto: json['participantPhoto'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  /// Create a copy with updated fields
  ConversationModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? createdAt,
    String? participantId,
    String? participantName,
    String? participantPhoto,
    bool? isOnline,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantPhoto: participantPhoto ?? this.participantPhoto,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Get the other participant's ID (not the current user)
  String? getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
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
    return 'ConversationModel(id: $id, participants: $participants, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
