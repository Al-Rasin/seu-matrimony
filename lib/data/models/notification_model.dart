import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';

/// Model representing a user notification
class NotificationModel {

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  
  final String id;
  final String userId;
  final String type; // interest, message, match, system
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  

  /// Create NotificationModel from Firestore document data
  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Helper to convert Firestore Timestamp to DateTime
    DateTime timestampToDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return NotificationModel(
      id: id,
      userId: data[FirebaseConstants.fieldUserId]?.toString() ?? '',
      type: data[FirebaseConstants.fieldType]?.toString() ?? 'system',
      title: data[FirebaseConstants.fieldTitle]?.toString() ?? '',
      body: data[FirebaseConstants.fieldBody]?.toString() ?? '',
      data: data[FirebaseConstants.fieldData] as Map<String, dynamic>?,
      isRead: data[FirebaseConstants.fieldIsRead] == true,
      createdAt: timestampToDateTime(data[FirebaseConstants.fieldCreatedAt]),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.fieldUserId: userId,
      FirebaseConstants.fieldType: type,
      FirebaseConstants.fieldTitle: title,
      FirebaseConstants.fieldBody: body,
      FirebaseConstants.fieldData: data,
      FirebaseConstants.fieldIsRead: isRead,
      FirebaseConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy of NotificationModel with some fields updated
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}
