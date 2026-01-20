import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle user presence (online/offline status)
class PresenceService extends GetxService with WidgetsBindingObserver {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Listen to auth state changes to update presence
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _setOnlineStatus(true);
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_authService.isLoggedIn) return;

    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true);
    } else {
      _setOnlineStatus(false);
    }
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldIsOnline: isOnline,
          FirebaseConstants.fieldLastSeen: FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      debugPrint('Error updating presence: $e');
    }
  }
}
