import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'registration_controller.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import 'steps/basic_details_step.dart';
import 'steps/personal_details_step.dart';
import 'steps/professional_details_step.dart';
import 'steps/about_yourself_step.dart';
import 'steps/success_step.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        leading: Obx(() => controller.currentStep.value > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.previousStep,
              )
            : const SizedBox.shrink()),
      ),
      body: Column(
        children: [
          // Progress indicator
          Obx(() => _buildProgressIndicator(controller)),
          // Step content
          Expanded(
            child: Obx(() => _buildStepContent(controller)),
          ),
          // Bottom button
          Obx(() => controller.currentStep.value < 4
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: CustomButton(
                    text: 'Continue',
                    onPressed: controller.nextStep,
                    isLoading: controller.isLoading.value,
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(RegistrationController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < controller.currentStep.value;
          final isCurrent = index == controller.currentStep.value;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color:
                                  isCurrent ? Colors.white : AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(RegistrationController controller) {
    switch (controller.currentStep.value) {
      case 0:
        return BasicDetailsStep(controller: controller);
      case 1:
        return PersonalDetailsStep(controller: controller);
      case 2:
        return ProfessionalDetailsStep(controller: controller);
      case 3:
        return AboutYourselfStep(controller: controller);
      case 4:
        return const SuccessStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
