import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_detail_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/message_model.dart';
import '../../../core/utils/date_utils.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: controller.conversation.value?.participantPhoto != null
                      ? NetworkImage(controller.conversation.value!.participantPhoto!)
                      : null,
                  child: controller.conversation.value?.participantPhoto == null
                      ? Text((controller.conversation.value?.participantName ?? 'U')[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.conversation.value?.participantName ?? 'Loading...',
                        style: AppTextStyles.labelLarge,
                      ),
                      Obx(() => controller.isOtherTyping.value
                          ? Text(
                              'typing...',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontStyle: FontStyle.italic),
                            )
                          : (controller.conversation.value?.isOnline == true)
                              ? Text(
                                  'Online',
                                  style: AppTextStyles.caption.copyWith(color: Colors.green),
                                )
                              : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: controller.initiateVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: controller.initiateVoiceCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  reverse: false, // Messages are usually shown bottom-to-top in list, but chronological order
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final isMe = message.senderId == controller.currentUserId;
                    
                    // Show date header if it's the first message of the day
                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prevMessage = controller.messages[index - 1];
                      if (message.createdAt.day != prevMessage.createdAt.day) {
                        showDateHeader = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(message.createdAt),
                        _buildMessageBubble(message, isMe),
                      ],
                    );
                  },
                )),
          ),
          _buildInputArea(controller),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppDateUtils.formatDate(date),
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            constraints: BoxConstraints(maxWidth: Get.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppDateUtils.formatTime(message.createdAt),
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: controller.onTextChanged,
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => CircleAvatar(
            backgroundColor: AppColors.primary,
            child: controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: controller.sendMessage,
                  ),
          )),
        ],
      ),
    );
  }
}
