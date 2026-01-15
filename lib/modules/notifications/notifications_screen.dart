import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildNotificationTile(index);
        },
      ),
    );
  }

  Widget _buildNotificationTile(int index) {
    final isRead = index % 2 == 0;
    return Container(
      color: isRead ? null : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: const Icon(Icons.favorite, color: AppColors.primary, size: 20),
        ),
        title: Text(
          'New interest received',
          style: AppTextStyles.labelLarge,
        ),
        subtitle: Text(
          'Someone sent you an interest',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Text(
          '2h ago',
          style: AppTextStyles.caption,
        ),
        onTap: () {},
      ),
    );
  }
}
