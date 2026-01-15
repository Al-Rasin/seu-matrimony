import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../registration_controller.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class BasicDetailsStep extends StatelessWidget {
  final RegistrationController controller;

  const BasicDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Details', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Please provide your basic details',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Age',
            hint: 'Enter your age',
            controller: controller.ageController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Date of Birth',
            hint: 'DD/MM/YYYY',
            controller: controller.dobController,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                firstDate: DateTime(1960),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
              );
              if (date != null) {
                controller.dobController.text =
                    '${date.day}/${date.month}/${date.year}';
              }
            },
          ),
          const SizedBox(height: 16),
          Obx(() => SimpleDropdown(
                label: 'Department',
                hint: 'Select department',
                value: controller.department.value,
                items: const [
                  'CSE',
                  'EEE',
                  'BBA',
                  'English',
                  'Law',
                  'Pharmacy',
                  'Architecture',
                  'Other'
                ],
                onChanged: (value) => controller.department.value = value,
              )),
          const SizedBox(height: 16),
          Text('Gender', style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  _buildGenderOption('Male', Icons.male, controller),
                  const SizedBox(width: 16),
                  _buildGenderOption('Female', Icons.female, controller),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
      String value, IconData icon, RegistrationController controller) {
    final isSelected = controller.gender.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.gender.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.green : Colors.grey, size: 28),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
