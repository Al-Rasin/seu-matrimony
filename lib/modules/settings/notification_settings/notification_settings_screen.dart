import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import 'notification_settings_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationSettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Activity Notifications'),
            _buildSwitchTile(
              title: 'New Matches',
              subtitle: 'Get notified when you have a new match.',
              value: controller.notifyNewMatches.value,
              onChanged: (val) => controller.updateSetting('NewMatches', val),
            ),
            _buildSwitchTile(
              title: 'New Messages',
              subtitle: 'Get notified when you receive a new message.',
              value: controller.notifyNewMessages.value,
              onChanged: (val) => controller.updateSetting('NewMessages', val),
            ),
            _buildSwitchTile(
              title: 'Interests',
              subtitle: 'Get notified when someone expresses interest in your profile.',
              value: controller.notifyInterests.value,
              onChanged: (val) => controller.updateSetting('Interests', val),
            ),
            _buildSwitchTile(
              title: 'Profile Views',
              subtitle: 'Get notified when someone views your profile.',
              value: controller.notifyProfileViews.value,
              onChanged: (val) => controller.updateSetting('ProfileViews', val),
            ),
            const Divider(),
            _buildSectionHeader('App Notifications'),
            _buildSwitchTile(
              title: 'App Updates',
              subtitle: 'Get notified about new features and updates.',
              value: controller.notifyAppUpdates.value,
              onChanged: (val) => controller.updateSetting('AppUpdates', val),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
