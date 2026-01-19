import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
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
                  Obx(() {
                    final photoUrl = controller.profilePhotoUrl.value;
                    ImageProvider? imageProvider;
                    
                    if (photoUrl.isNotEmpty) {
                      if (photoUrl.startsWith('data:image')) {
                        try {
                          final base64String = photoUrl.split(',').last;
                          imageProvider = MemoryImage(base64Decode(base64String));
                        } catch (e) {
                          // Fallback if invalid base64
                        }
                      } else {
                        imageProvider = NetworkImage(photoUrl);
                      }
                    }

                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                          : null,
                    );
                  }),
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
            const SizedBox(height: 8),
            Obx(() {
              final details = [
                if (controller.userAge.value.isNotEmpty) '${controller.userAge.value} yrs',
                if (controller.userGender.value.isNotEmpty) controller.userGender.value,
                if (controller.userDepartment.value.isNotEmpty) controller.userDepartment.value,
              ];
              if (details.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  details.join(' • '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
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
