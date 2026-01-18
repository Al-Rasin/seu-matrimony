import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';

/// Model representing a user's subscription to a plan
class SubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final String status; // active, expired, cancelled
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? paymentDetails;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.paymentDetails,
  });

  /// Create SubscriptionModel from Firestore document data
  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime timestampToDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return SubscriptionModel(
      id: id,
      userId: data[FirebaseConstants.fieldUserId]?.toString() ?? '',
      planId: data[FirebaseConstants.fieldPlanId]?.toString() ?? '',
      status: data[FirebaseConstants.fieldStatus]?.toString() ?? FirebaseConstants.subscriptionStatusCancelled,
      startDate: timestampToDateTime(data[FirebaseConstants.fieldStartDate]),
      endDate: timestampToDateTime(data[FirebaseConstants.fieldEndDate]),
      paymentDetails: data[FirebaseConstants.fieldPaymentDetails] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.fieldUserId: userId,
      FirebaseConstants.fieldPlanId: planId,
      FirebaseConstants.fieldStatus: status,
      FirebaseConstants.fieldStartDate: Timestamp.fromDate(startDate),
      FirebaseConstants.fieldEndDate: Timestamp.fromDate(endDate),
      FirebaseConstants.fieldPaymentDetails: paymentDetails,
    };
  }

  /// Check if the subscription is currently active
  bool get isActive {
    if (status != FirebaseConstants.subscriptionStatusActive) return false;
    return endDate.isAfter(DateTime.now());
  }

  /// Create a copy with updated fields
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? planId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? paymentDetails,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }
}

/// Model representing a subscription plan available in the app
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final List<String> features;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
    this.isActive = true,
  });

  /// Create SubscriptionPlanModel from Firestore document data
  factory SubscriptionPlanModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SubscriptionPlanModel(
      id: id,
      name: data[FirebaseConstants.fieldName]?.toString() ?? '',
      description: data[FirebaseConstants.fieldPlanDescription]?.toString() ?? '',
      price: (data[FirebaseConstants.fieldPrice] as num?)?.toDouble() ?? 0.0,
      durationDays: (data[FirebaseConstants.fieldDuration] as num?)?.toInt() ?? 0,
      features: List<String>.from(data[FirebaseConstants.fieldFeatures] ?? []),
      isActive: data[FirebaseConstants.fieldIsActive] == true,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.fieldName: name,
      FirebaseConstants.fieldPlanDescription: description,
      FirebaseConstants.fieldPrice: price,
      FirebaseConstants.fieldDuration: durationDays,
      FirebaseConstants.fieldFeatures: features,
      FirebaseConstants.fieldIsActive: isActive,
    };
  }
}
