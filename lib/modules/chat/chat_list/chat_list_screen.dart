import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_list_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

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
          .where((c) => c['unreadCount'] > 0)
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
//widget 
  Widget _buildCallsList(ChatListController controller) {
    return const Center(child: Text('Call history coming soon'));
  }

  Widget _buildConversationTile(
      Map<String, dynamic> conversation, ChatListController controller) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Text(
          (conversation['name'] ?? 'U')[0].toUpperCase(),
          style: const TextStyle(color: AppColors.primary),
        ),
      ),
      title: Text(
        conversation['name'] ?? 'Unknown',
        style: AppTextStyles.labelLarge,
      ),
      subtitle: Text(
        conversation['lastMessage'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation['time'] ?? '',
            style: AppTextStyles.caption,
          ),
          if ((conversation['unreadCount'] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${conversation['unreadCount']}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () => controller.openChat(conversation['id']),
    );
  }
}
