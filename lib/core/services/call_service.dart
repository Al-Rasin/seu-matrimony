import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle video/voice calls (Mock Implementation)
class CallService extends GetxService with WidgetsBindingObserver {
  // Mocking the engine access (returns null or throws if accessed, but we won't access it in UI anymore)
  get engine => null;

  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final isJoined = false.obs;
  final remoteUid = Rxn<int>();
  final isMuted = false.obs;
  final isCameraOff = false.obs;

  Timer? _mockConnectionTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    _firestoreService.queryStream(
      collection: FirebaseConstants.callsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldReceiverId,
          operator: QueryOperator.isEqualTo,
          value: userId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldCallStatus,
          operator: QueryOperator.isEqualTo,
          value: "ongoing",
        ),
      ],
    ).listen((calls) {
      if (calls.isNotEmpty) {
        final call = calls.first;
        // Simple check to avoid spamming dialogs if already in call
        if (!isJoined.value) {
          _showIncomingCallDialog(call);
        }
      }
    });
  }

  void _showIncomingCallDialog(Map<String, dynamic> call) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      AlertDialog(
        title: const Text("Incoming Call"),
        content: Text("Incoming ${call[FirebaseConstants.fieldCallType]} call..."),
        actions: [
          TextButton(
            onPressed: () {
              // Reject call logic here (update Firestore)
              Get.back();
            },
            child: const Text("Reject", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/call', arguments: {
                'channelName': call['id'],
                'isVideo': call[FirebaseConstants.fieldCallType] == "video",
                'participantName': "Caller",
              });
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  Future<void> joinCall(String channelName, {bool isVideo = true}) async {
    debugPrint("Mock Call Service: Joining channel $channelName...");
    isJoined.value = true;
    isCameraOff.value = !isVideo;

    // Simulate network delay for remote user joining
    _mockConnectionTimer = Timer(const Duration(seconds: 2), () {
      debugPrint("Mock Call Service: Remote user joined");
      remoteUid.value = 12345; // Mock remote UID
    });
  }

  Future<void> leaveCall() async {
    debugPrint("Mock Call Service: Leaving channel");
    _mockConnectionTimer?.cancel();
    isJoined.value = false;
    remoteUid.value = null;
    isMuted.value = false;
    isCameraOff.value = false;
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    debugPrint("Mock Call Service: Mute ${isMuted.value}");
  }

  Future<void> toggleCamera() async {
    isCameraOff.value = !isCameraOff.value;
    debugPrint("Mock Call Service: Camera Off ${isCameraOff.value}");
  }

  Future<void> switchCamera() async {
    debugPrint("Mock Call Service: Switching Camera (Simulated)");
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockConnectionTimer?.cancel();
    super.onClose();
  }
}
