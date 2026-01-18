import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'call_controller.dart';
import '../../../core/services/call_service.dart';

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
          // Remote Video Placeholder
          Center(
            child: Obx(() {
              if (callService.remoteUid.value != null) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 80, color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          controller.participantName.value,
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Remote Video Feed (Mock)",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
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

          // Local Video Placeholder (Small window)
          Positioned(
            right: 16,
            top: 60,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Obx(() => !callService.isCameraOff.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.videocam, color: Colors.white54),
                            SizedBox(height: 4),
                            Text("You", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      )
                    : Container(color: Colors.black, child: const Center(child: Icon(Icons.videocam_off, color: Colors.white54)))),
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
