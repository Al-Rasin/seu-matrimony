import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../registration_controller.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class PersonalDetailsStep extends StatelessWidget {
  final RegistrationController controller;

  const PersonalDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Details', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Please provide your personal details',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Obx(() => SimpleDropdown(
                label: 'Marital Status',
                hint: 'Select marital status',
                value: controller.maritalStatus.value,
                items: const [
                  'Never Married',
                  'Divorced',
                  'Widowed',
                  'Separated'
                ],
                onChanged: (value) => controller.maritalStatus.value = value,
              )),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email ID',
            hint: 'Enter your email',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Text('Do you have children?', style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  _buildYesNoOption('Yes', true, controller.hasChildren),
                  const SizedBox(width: 16),
                  _buildYesNoOption('No', false, controller.hasChildren),
                ],
              )),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Height (cm)',
            hint: 'Enter height in cm',
            controller: controller.heightController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Obx(() => SimpleDropdown(
                label: 'Religion',
                hint: 'Select religion',
                value: controller.religion.value,
                items: const ['Muslim', 'Hindu', 'Christian', 'Buddhist', 'Other'],
                onChanged: (value) => controller.religion.value = value,
              )),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Student ID',
            hint: 'Enter your SEU student ID',
            controller: controller.studentIdController,
          ),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
                value: controller.isCurrentlyStudying.value,
                onChanged: (value) =>
                    controller.isCurrentlyStudying.value = value ?? false,
                title: const Text('Currently studying at SEU'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              )),
        ],
      ),
    );
  }

  Widget _buildYesNoOption(String label, bool value, RxBool observable) {
    final isSelected = observable.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => observable.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
