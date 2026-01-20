import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../app/routes/app_routes.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection('Account'),
          _buildTile(
            'Privacy Settings',
            Icons.lock_outline,
            () => Get.toNamed(AppRoutes.privacySettings),
            subtitle: 'Control who can see your profile and photos',
          ),
          _buildTile(
            'Notification Settings',
            Icons.notifications_outlined,
            () => Get.toNamed(AppRoutes.notificationSettings),
            subtitle: 'Manage your alerts and notifications',
          ),
          _buildTile(
            'Blocked Users',
            Icons.block,
            () => Get.toNamed(AppRoutes.blockedUsers),
            subtitle: 'See and manage people you have blocked',
          ),
          _buildTile(
            'Change Password',
            Icons.password_outlined,
            controller.changePassword,
            subtitle: 'Update your account password',
          ),
          
          _buildSection('Support'),
          _buildTile(
            'Help Center',
            Icons.help_outline,
            () => Get.toNamed(AppRoutes.helpAndSupport),
            subtitle: 'FAQs and support contact',
          ),
          _buildTile(
            'Safety Tips',
            Icons.security_outlined,
            () {},
            subtitle: 'Learn how to stay safe',
          ),
          
          _buildSection('Legal'),
          _buildTile(
            'Terms of Service',
            Icons.description_outlined,
            () => Get.toNamed(AppRoutes.termsAndConditions),
          ),
          _buildTile(
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          
          _buildSection('About'),
          _buildTile(
            'App Version',
            Icons.info_outline,
            () {},
            trailing: const Text('1.0.0', style: AppTextStyles.bodySmall),
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: controller.deleteAccount,
            child: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap,
      {String? subtitle, Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.caption) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
