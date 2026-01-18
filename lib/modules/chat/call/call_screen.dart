import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'call_controller.dart';
import '../../../core/services/call_service.dart';
import '../../../app/themes/app_colors.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallController());
    final callService = Get.find<CallService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video
          Center(
            child: Obx(() {
              if (callService.remoteUid.value != null) {
                return AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: callService.engine,
                    canvas: VideoCanvas(uid: callService.remoteUid.value),
                    connection: RtcConnection(channelId: controller.channelName.value),
                  ),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      "Waiting for ${controller.participantName.value} to join...",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              }
            }),
          ),

          // Local Video (Small window)
          Positioned(
            right: 16,
            top: 60,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Obx(() => callService.isJoined.value && !callService.isCameraOff.value
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: callService.engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : Container(color: Colors.grey[900])),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.switch_camera,
                  onPressed: controller.switchCamera,
                ),
                Obx(() => _buildControlButton(
                      icon: callService.isCameraOff.value ? Icons.videocam_off : Icons.videocam,
                      onPressed: controller.toggleCamera,
                      color: callService.isCameraOff.value ? Colors.red : Colors.white24,
                    )),
                Obx(() => _buildControlButton(
                      icon: callService.isMuted.value ? Icons.mic_off : Icons.mic,
                      onPressed: controller.toggleMute,
                      color: callService.isMuted.value ? Colors.red : Colors.white24,
                    )),
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: controller.endCall,
                  color: Colors.red,
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
          
          // Participant Name
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              controller.participantName.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white24,
    Color iconColor = Colors.white,
  }) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(12.0),
      child: Icon(icon, color: iconColor, size: 28.0),
    );
  }
}
