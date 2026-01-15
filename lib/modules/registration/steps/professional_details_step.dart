import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../registration_controller.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class ProfessionalDetailsStep extends StatelessWidget {
  final RegistrationController controller;

  const ProfessionalDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Details', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Please provide your professional details',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Obx(() => SimpleDropdown(
                label: 'Highest Education',
                hint: 'Select education level',
                value: controller.highestEducation.value,
                items: const [
                  'High School',
                  'Diploma',
                  "Bachelor's",
                  "Master's",
                  'PhD',
                  'Other'
                ],
                onChanged: (value) => controller.highestEducation.value = value,
              )),
          const SizedBox(height: 16),
          Obx(() => SimpleDropdown(
                label: 'Employment',
                hint: 'Select employment status',
                value: controller.employment.value,
                items: const [
                  'Employed',
                  'Self Employed',
                  'Business',
                  'Not Working',
                  'Student'
                ],
                onChanged: (value) => controller.employment.value = value,
              )),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Occupation',
            hint: 'Enter your occupation',
            controller: controller.occupationController,
          ),
          const SizedBox(height: 16),
          Obx(() => SimpleDropdown(
                label: 'Annual Income',
                hint: 'Select income range',
                value: controller.annualIncome.value,
                items: const [
                  'Not Specified',
                  'Below 2 Lakh',
                  '2-5 Lakh',
                  '5-10 Lakh',
                  '10-20 Lakh',
                  '20-50 Lakh',
                  'Above 50 Lakh'
                ],
                onChanged: (value) => controller.annualIncome.value = value,
              )),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Work Location',
            hint: 'Enter work location',
            controller: controller.workLocationController,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Current City',
            hint: 'Enter current city',
            controller: controller.currentCityController,
          ),
        ],
      ),
    );
  }
}
