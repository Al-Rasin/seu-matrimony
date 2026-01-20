import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/firebase_constants.dart';
import 'privacy_settings_controller.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrivacySettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Profile Visibility'),
            _buildSwitchTile(
              title: 'Show Profile to Others',
              subtitle: 'Allow your profile to appear in search results and recommendations.',
              value: controller.isProfileVisible.value,
              onChanged: controller.toggleProfileVisibility,
            ),
            const Divider(),

            _buildSectionHeader('Photo Privacy'),
            _buildRadioTile(
              title: 'Visible to All Members',
              value: FirebaseConstants.privacyAll,
              groupValue: controller.profilePhotoVisibility.value,
              onChanged: controller.updateProfilePhotoVisibility,
            ),
            _buildRadioTile(
              title: 'Visible to Connected Matches Only',
              value: FirebaseConstants.privacyConnected,
              groupValue: controller.profilePhotoVisibility.value,
              onChanged: controller.updateProfilePhotoVisibility,
            ),
            _buildRadioTile(
              title: 'Request to View',
              value: FirebaseConstants.privacyRequest,
              groupValue: controller.profilePhotoVisibility.value,
              onChanged: controller.updateProfilePhotoVisibility,
            ),
            const Divider(),

            _buildSectionHeader('Contact Details'),
            _buildRadioTile(
              title: 'Visible to Connected Matches',
              value: FirebaseConstants.privacyConnected,
              groupValue: controller.contactInfoVisibility.value,
              onChanged: controller.updateContactInfoVisibility,
            ),
            _buildRadioTile(
              title: 'Hide from Everyone',
              value: FirebaseConstants.privacyNone,
              groupValue: controller.contactInfoVisibility.value,
              onChanged: controller.updateContactInfoVisibility,
            ),
            const Divider(),

            _buildSectionHeader('Activity Status'),
            _buildSwitchTile(
              title: 'Show Online Status',
              subtitle: 'Allow others to see when you are online.',
              value: controller.showOnlineStatus.value,
              onChanged: controller.toggleShowOnlineStatus,
            ),
            _buildSwitchTile(
              title: 'Read Receipts',
              subtitle: 'Let others know when you have read their messages.',
              value: controller.readReceipts.value,
              onChanged: controller.toggleReadReceipts,
            ),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Changes are saved automatically.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
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
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: AppTextStyles.bodyMedium),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
