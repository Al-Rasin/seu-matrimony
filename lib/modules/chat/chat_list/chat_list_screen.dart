import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_list_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/conversation_model.dart';
import '../../../core/utils/date_utils.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: AppColors.accent.withValues(alpha: 0.3),
            child: TabBar(
              controller: controller.tabController,
              tabs: const [
                Tab(text: 'All Messages'),
                Tab(text: 'Unread Messages'),
                Tab(text: 'Calls'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildMessagesList(controller),
                _buildUnreadList(controller),
                _buildCallsList(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatListController controller) {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : controller.conversations.isEmpty
            ? const Center(child: Text('No conversations yet'))
            : ListView.builder(
                itemCount: controller.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = controller.conversations[index];
                  return _buildConversationTile(conversation, controller);
                },
              ));
  }

  Widget _buildUnreadList(ChatListController controller) {
    return Obx(() {
      final unread = controller.conversations
          .where((c) => c.unreadCount > 0)
          .toList();
      return unread.isEmpty
          ? const Center(child: Text('No unread messages'))
          : ListView.builder(
              itemCount: unread.length,
              itemBuilder: (context, index) {
                return _buildConversationTile(unread[index], controller);
              },
            );
    });
  }

  Widget _buildCallsList(ChatListController controller) {
    return const Center(child: Text('Call history coming soon'));
  }

  Widget _buildConversationTile(
      ConversationModel conversation, ChatListController controller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        backgroundImage: conversation.participantPhoto != null
            ? NetworkImage(conversation.participantPhoto!)
            : null,
        child: conversation.participantPhoto == null
            ? Text(
                (conversation.participantName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.participantName ?? 'Unknown',
              style: AppTextStyles.labelLarge,
            ),
          ),
          if (conversation.isOnline)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppDateUtils.getChatTimestamp(conversation.lastMessageAt),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => controller.openChat(conversation.id),
    );
  }
}
