import 'package:get/get.dart';
import '../../../core/services/call_service.dart';

class CallController extends GetxController {
  final CallService _callService = Get.find<CallService>();
  
  final channelName = "".obs;
  final isVideo = true.obs;
  final participantName = "Unknown".obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      channelName.value = args['channelName'] ?? "";
      isVideo.value = args['isVideo'] ?? true;
      participantName.value = args['participantName'] ?? "Unknown";
      
      if (channelName.value.isNotEmpty) {
        _callService.joinCall(channelName.value, isVideo: isVideo.value);
      }
    }
  }

  void endCall() {
    _callService.leaveCall();
    Get.back();
  }

  void toggleMute() {
    _callService.toggleMute();
  }

  void toggleCamera() {
    _callService.toggleCamera();
  }

  void switchCamera() {
    _callService.switchCamera();
  }

  @override
  void onClose() {
    _callService.leaveCall();
    super.onClose();
  }
}
