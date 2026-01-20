import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import 'blocked_users_controller.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlockedUsersController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.blockedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'No blocked users',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.blockedUsers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final user = controller.blockedUsers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePhoto != null
                    ? NetworkImage(user.profilePhoto!)
                    : null,
                child: user.profilePhoto == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user.fullName, style: AppTextStyles.bodyLarge),
              subtitle: Text(user.occupation ?? 'User', style: AppTextStyles.caption),
              trailing: TextButton(
                onPressed: () => _showUnblockDialog(context, controller, user.id, user.fullName),
                child: const Text('Unblock'),
              ),
            );
          },
        );
      }),
    );
  }

  void _showUnblockDialog(BuildContext context, BlockedUsersController controller, String userId, String userName) {
    Get.defaultDialog(
      title: 'Unblock User',
      middleText: 'Are you sure you want to unblock $userName?',
      textConfirm: 'Unblock',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        controller.unblockUser(userId);
        Get.back();
      },
    );
  }
}
