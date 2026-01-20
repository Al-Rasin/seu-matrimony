import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/firebase_constants.dart';
import 'controllers/notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            final hasUnread = controller.notifications.any(
              (n) => n[FirebaseConstants.fieldIsRead] == false,
            );
            return hasUnread
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationTile(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification[FirebaseConstants.fieldIsRead] ?? false;
    final title = notification[FirebaseConstants.fieldTitle] ?? 'Notification';
    final body = notification[FirebaseConstants.fieldBody] ?? '';
    final createdAt = notification[FirebaseConstants.fieldCreatedAt];
    
    DateTime? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    } else if (createdAt is String) {
      date = DateTime.tryParse(createdAt);
    }

    return Dismissible(
      key: Key(notification['id'] ?? UniqueKey().toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        if (notification['id'] != null) {
          controller.deleteNotification(notification['id']);
        }
      },
      child: Container(
        color: isRead ? null : AppColors.primary.withValues(alpha: 0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.notifications, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: isRead ? AppTextStyles.bodyLarge : AppTextStyles.labelLarge,
          ),
          subtitle: Text(
            body,
            style: AppTextStyles.bodySmall,
          ),
          trailing: Text(
            AppDateUtils.getRelativeTime(date),
            style: AppTextStyles.caption,
          ),
          onTap: () {
            if (!isRead && notification['id'] != null) {
              controller.markAsRead(notification['id']);
            }
            // Handle navigation if needed based on 'type' or 'data'
          },
        ),
      ),
    );
  }
}
