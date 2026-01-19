import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../app/themes/app_text_styles.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('Basic Details', () => controller.editBasicDetails()),
            _buildSection(
                'Personal Details', () => controller.editPersonalDetails()),
            _buildSection('Professional Details',
                () => controller.editProfessionalDetails()),
            _buildSection(
                'Family Details', () => controller.editFamilyDetails()),
            _buildSection('About Yourself', () => controller.editAbout()),
            _buildSection(
                'Partner Preferences', () => controller.editPreferences()),
            _buildSection('Photos', () => controller.editPhotos()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: AppTextStyles.labelLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
