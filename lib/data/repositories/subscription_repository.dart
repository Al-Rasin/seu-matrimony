import 'package:get/get.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/subscription_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionRepository {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  String? get currentUserId => _authService.currentUserId;

  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final results = await _firestoreService.getAll(
      collection: FirebaseConstants.subscriptionPlansCollection,
    );

    return results
        .where((data) => data[FirebaseConstants.fieldIsActive] == true)
        .map((data) => SubscriptionPlanModel.fromFirestore(data, data['id']))
        .toList();
  }

  Future<SubscriptionModel?> getUserSubscription() async {
    if (currentUserId == null) return null;

    final results = await _firestoreService.getWhere(
      collection: FirebaseConstants.subscriptionsCollection,
      field: FirebaseConstants.fieldUserId,
      isEqualTo: currentUserId!,
    );

    if (results.isEmpty) return null;

    // Return the latest active subscription
    final subs = results.map((data) => SubscriptionModel.fromFirestore(data, data['id'])).toList();
    subs.sort((a, b) => b.endDate.compareTo(a.endDate));

    return subs.first;
  }

  Future<void> purchaseSubscription(SubscriptionPlanModel plan, Map<String, dynamic> paymentDetails) async {
    if (currentUserId == null) throw Exception("User not logged in");

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: plan.durationDays));

    await _firestoreService.create(
      collection: FirebaseConstants.subscriptionsCollection,
      data: {
        FirebaseConstants.fieldUserId: currentUserId,
        FirebaseConstants.fieldPlanId: plan.id,
        FirebaseConstants.fieldStatus: FirebaseConstants.subscriptionStatusActive,
        FirebaseConstants.fieldStartDate: Timestamp.fromDate(startDate),
        FirebaseConstants.fieldEndDate: Timestamp.fromDate(endDate),
        FirebaseConstants.fieldPaymentDetails: paymentDetails,
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      },
    );
  }

  Future<bool> hasFeatureAccess(String featureName) async {
    final sub = await getUserSubscription();
    if (sub == null || !sub.isActive) return false;

    // Fetch the plan details to check features
    final planData = await _firestoreService.getById(
      collection: FirebaseConstants.subscriptionPlansCollection,
      documentId: sub.planId,
    );

    if (planData == null) return false;

    final plan = SubscriptionPlanModel.fromFirestore(planData, sub.planId);
    return plan.features.contains(featureName);
  }
}
