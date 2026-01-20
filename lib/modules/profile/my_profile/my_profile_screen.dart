import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'my_profile_controller.dart';
import '../edit_profile/edit_profile_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class MyProfileScreen extends GetView<MyProfileController> {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: GestureDetector(
                onTap: controller.editPhoto,
                child: Stack(
                  children: [
                    Obx(() {
                      final photoUrl = controller.profilePhotoUrl.value;

                      // Default placeholder
                      Widget imageWidget = const Icon(Icons.person,
                          size: 60, color: AppColors.primary);

                      if (photoUrl.isNotEmpty) {
                        if (photoUrl.startsWith('data:image')) {
                          try {
                            final base64String = photoUrl.split(',').last;
                            final bytes = base64Decode(base64String.trim());
                            imageWidget = Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primary),
                            );
                          } catch (e) {
                            // Keep default
                          }
                        } else if (photoUrl.startsWith('http')) {
                          imageWidget = Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          );
                        } else {
                          // Try as raw base64
                          try {
                            final bytes = base64Decode(photoUrl.trim());
                            imageWidget = Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primary),
                            );
                          } catch (e) {
                            // Keep default
                          }
                        }
                      }

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        child: ClipOval(
                          child: imageWidget,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.white),
                          onPressed: controller.editPhoto,
                        ),
                      ),
                    ),
                  ],
                ),
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
                if (controller.userAge.value.isNotEmpty)
                  '${controller.userAge.value} yrs',
                if (controller.userGender.value.isNotEmpty)
                  controller.userGender.value,
                if (controller.userDepartment.value.isNotEmpty)
                  controller.userDepartment.value,
              ];
              if (details.isEmpty) return const SizedBox.shrink();

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            // Profile sections
            _buildSectionHeader('Edit Profile'),
            _buildOption(
              'Basic Details',
              Icons.person_outline,
              () => Get.find<EditProfileController>().editBasicDetails(),
            ),
            _buildOption(
              'Personal Details',
              Icons.favorite_border,
              () => Get.find<EditProfileController>().editPersonalDetails(),
            ),
            _buildOption(
              'Professional Details',
              Icons.work_outline,
              () => Get.find<EditProfileController>().editProfessionalDetails(),
            ),
            _buildOption(
              'Family Details',
              Icons.family_restroom,
              () => Get.find<EditProfileController>().editFamilyDetails(),
            ),
            _buildOption(
              'About Myself',
              Icons.info_outline,
              () => Get.find<EditProfileController>().editAbout(),
            ),
            _buildOption(
              'Partner Preferences',
              Icons.manage_search,
              () => Get.find<EditProfileController>().editPreferences(),
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('Account'),
            _buildOption(
              'Subscription',
              Icons.star_outline,
              () => Get.toNamed(AppRoutes.subscription),
              color: Colors.amber[800],
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('System'),
            _buildOption(
              'Logout',
              Icons.logout,
              controller.logout,
              color: Colors.red,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
