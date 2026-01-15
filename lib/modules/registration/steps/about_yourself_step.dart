import 'package:flutter/material.dart';
import '../registration_controller.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/themes/app_colors.dart';

class AboutYourselfStep extends StatelessWidget {
  final RegistrationController controller;

  const AboutYourselfStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Yourself', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Please tell us something about yourself',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Text('About Yourself', style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.bioController,
            maxLines: 6,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Write a brief description about yourself...',
              hintStyle: AppTextStyles.inputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tip: Write about your hobbies, interests, values, and what you are looking for in a partner.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
