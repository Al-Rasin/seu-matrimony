import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class EditPartnerPreferencesScreen extends GetView<EditProfileController> {
  const EditPartnerPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age Range', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: [
                    RangeSlider(
                      values: controller.partnerAgeRange.value,
                      min: 18,
                      max: 70,
                      divisions: 52,
                      activeColor: AppColors.primary,
                      labels: RangeLabels(
                        controller.partnerAgeRange.value.start.round().toString(),
                        controller.partnerAgeRange.value.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        controller.partnerAgeRange.value = values;
                      },
                    ),
                    Text(
                      '${controller.partnerAgeRange.value.start.round()} - ${controller.partnerAgeRange.value.end.round()} Years',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Text('Height Range (cm)', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Min Height',
                    hint: 'Min cm',
                    controller: controller.partnerMinHeightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Max Height',
                    hint: 'Max cm',
                    controller: controller.partnerMaxHeightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => SimpleDropdown(
                  label: 'Preferred Marital Status',
                  hint: 'Select marital status',
                  value: controller.partnerMaritalStatus.value,
                  items: const [
                    'Doesn\'t Matter',
                    'Never Married',
                    'Divorced',
                    'Widowed',
                    'Separated'
                  ],
                  onChanged: (value) =>
                      controller.partnerMaritalStatus.value = value,
                )),
            const SizedBox(height: 16),
            Obx(() => SimpleDropdown(
                  label: 'Preferred Religion',
                  hint: 'Select religion',
                  value: controller.partnerReligion.value,
                  items: const [
                    'Doesn\'t Matter',
                    'Muslim',
                    'Hindu',
                    'Christian',
                    'Buddhist',
                    'Other'
                  ],
                  onChanged: (value) =>
                      controller.partnerReligion.value = value,
                )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.savePreferences(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
