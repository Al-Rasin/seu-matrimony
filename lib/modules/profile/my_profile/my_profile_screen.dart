import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_profile_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child:
                        const Icon(Icons.person, size: 60, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                        onPressed: controller.editPhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.userName.value,
                  style: AppTextStyles.h3,
                )),
            Obx(() => Text(
                  controller.userEmail.value,
                  style: AppTextStyles.bodySmall,
                )),
            const SizedBox(height: 24),
            // Profile options
            _buildOption(
              'Edit Profile',
              Icons.person_outline,
              () => Get.toNamed('/edit-profile'),
            ),
            _buildOption(
              'Subscription',
              Icons.star_outline,
              () => Get.toNamed('/subscription'),
            ),
            _buildOption(
              'Privacy Settings',
              Icons.lock_outline,
              () => Get.toNamed('/privacy-settings'),
            ),
            _buildOption(
              'Blocked Users',
              Icons.block,
              () => Get.toNamed('/blocked-users'),
            ),
            _buildOption(
              'Help & Support',
              Icons.help_outline,
              () {},
            ),
            _buildOption(
              'Terms & Conditions',
              Icons.description_outlined,
              () {},
            ),
            const Divider(),
            _buildOption(
              'Logout',
              Icons.logout,
              controller.logout,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.iconPrimary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
