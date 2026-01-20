import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class EditProfessionalDetailsScreen extends GetView<EditProfileController> {
  const EditProfessionalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Professional Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SimpleDropdown(
                  label: 'Highest Education',
                  hint: 'Select highest education',
                  value: controller.highestEducation.value,
                  items: const [
                    'Doctorate',
                    'Masters',
                    'Bachelors',
                    'Diploma',
                    'HSC',
                    'SSC',
                    'Other'
                  ],
                  onChanged: (value) =>
                      controller.highestEducation.value = value,
                )),
            const SizedBox(height: 16),
            Obx(() => SimpleDropdown(
                  label: 'Employment Status',
                  hint: 'Select employment status',
                  value: controller.employment.value,
                  items: const [
                    'Private Sector',
                    'Government',
                    'Business',
                    'Student',
                    'Not Working',
                    'Other'
                  ],
                  onChanged: (value) => controller.employment.value = value,
                )),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Occupation',
              hint: 'Enter your occupation (e.g., Software Engineer)',
              controller: controller.occupationController,
            ),
            const SizedBox(height: 16),
             Obx(() => SimpleDropdown(
                  label: 'Annual Income',
                  hint: 'Select annual income',
                  value: controller.annualIncome.value,
                  items: const [
                    'Not Specified',
                    'Less than 1 Lakh',
                    '1 Lakh - 3 Lakh',
                    '3 Lakh - 5 Lakh',
                    '5 Lakh - 10 Lakh',
                    '10 Lakh - 20 Lakh',
                    'Above 20 Lakh'
                  ],
                  onChanged: (value) => controller.annualIncome.value = value,
                )),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Work Location',
              hint: 'Enter work location (e.g., Dhaka)',
              controller: controller.workLocationController,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveProfessionalDetails(),
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
