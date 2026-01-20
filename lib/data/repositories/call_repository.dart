import 'package:get/get.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallRepository {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  String? get currentUserId => _authService.currentUserId;

  Future<String> startCallRecord({
    required String receiverId,
    required String type,
  }) async {
    if (currentUserId == null) throw Exception("User not logged in");

    return await _firestoreService.create(
      collection: FirebaseConstants.callsCollection,
      data: {
        FirebaseConstants.fieldCallerId: currentUserId,
        FirebaseConstants.fieldReceiverId: receiverId,
        FirebaseConstants.fieldCallType: type,
        FirebaseConstants.fieldCallStatus: "ongoing",
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> updateCallStatus(String callId, String status, {int? duration}) async {
    final data = {
      FirebaseConstants.fieldCallStatus: status,
      FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    };
    
    if (duration != null) {
      data[FirebaseConstants.fieldCallDuration] = duration;
    }

    await _firestoreService.update(
      collection: FirebaseConstants.callsCollection,
      documentId: callId,
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> getCallHistory() async {
    if (currentUserId == null) return [];

    // Query calls where user is caller or receiver
    final sentCalls = await _firestoreService.getWhere(
      collection: FirebaseConstants.callsCollection,
      field: FirebaseConstants.fieldCallerId,
      isEqualTo: currentUserId!,
    );

    final receivedCalls = await _firestoreService.getWhere(
      collection: FirebaseConstants.callsCollection,
      field: FirebaseConstants.fieldReceiverId,
      isEqualTo: currentUserId!,
    );

    final allCalls = [...sentCalls, ...receivedCalls];
    allCalls.sort((a, b) => (b[FirebaseConstants.fieldCreatedAt] as Timestamp)
        .compareTo(a[FirebaseConstants.fieldCreatedAt] as Timestamp));

    return allCalls;
  }
}
