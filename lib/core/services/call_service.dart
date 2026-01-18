import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle video/voice calls using Agora SDK
class CallService extends GetxService with WidgetsBindingObserver {
  late RtcEngine _engine;
  RtcEngine get engine => _engine;
  
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  // Placeholder Agora App ID - User needs to provide this
  static const String appId = "YOUR_AGORA_APP_ID";

  final isJoined = false.obs;
  final remoteUid = Rxn<int>();
  final isMuted = false.obs;
  final isCameraOff = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initAgora();
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
        _showIncomingCallDialog(call);
      }
    });
  }

  void _showIncomingCallDialog(Map<String, dynamic> call) {
    Get.dialog(
      AlertDialog(
        title: const Text("Incoming Call"),
        content: Text("Incoming ${call[FirebaseConstants.fieldCallType]} call..."),
        actions: [
          TextButton(
            onPressed: () {
              // Reject call
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
                'participantName': "Caller", // Should fetch caller name
              });
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  Future<void> _initAgora() async {
    try {
      // Create RTC engine
      _engine = createAgoraRtcEngine();
      
      // Initialize the engine
      await _engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          isJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          debugPrint("Remote user $uid joined");
          remoteUid.value = uid;
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          debugPrint("Remote user $uid left");
          remoteUid.value = null;
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("Local user left");
          isJoined.value = false;
          remoteUid.value = null;
        },
      ));

      // Enable video
      await _engine.enableVideo();
    } catch (e) {
      debugPrint("Error initializing Agora: $e");
    }
  }

  Future<void> joinCall(String channelName, {bool isVideo = true}) async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    try {
      // Set channel options
      ChannelMediaOptions options = ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: isVideo,
        publishMicrophoneTrack: true,
      );

      await _engine.joinChannel(
        token: "", // Use empty string for testing if App ID is in testing mode
        channelId: channelName,
        uid: 0,
        options: options,
      );
    } catch (e) {
      debugPrint("Error joining call: $e");
    }
  }

  Future<void> leaveCall() async {
    try {
      await _engine.leaveChannel();
    } catch (e) {
      debugPrint("Error leaving call: $e");
    }
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await _engine.muteLocalAudioStream(isMuted.value);
  }

  Future<void> toggleCamera() async {
    isCameraOff.value = !isCameraOff.value;
    await _engine.muteLocalVideoStream(isCameraOff.value);
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _engine.release();
    super.onClose();
  }
}