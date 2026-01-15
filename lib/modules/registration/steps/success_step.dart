import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../registration_controller.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class SuccessStep extends StatelessWidget {
  const SuccessStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.thumb_up,
              size: 60,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Success',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your profile has been submitted successfully.\nOur team will verify your SEU ID and\napprove your account within 24-48 hours.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'Go to Home',
            onPressed: controller.goToHome,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Note: You can browse profiles, but some features will be limited until verification is complete.',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
