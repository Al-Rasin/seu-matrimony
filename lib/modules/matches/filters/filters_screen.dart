import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'filters_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FiltersController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: controller.resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age Range
            _buildSectionTitle('Age Range'),
            Obx(() => Column(
                  children: [
                    RangeSlider(
                      values: RangeValues(
                        controller.minAge.value.toDouble(),
                        controller.maxAge.value.toDouble(),
                      ),
                      min: 18,
                      max: 60,
                      divisions: 42,
                      labels: RangeLabels(
                        '${controller.minAge.value}',
                        '${controller.maxAge.value}',
                      ),
                      activeColor: AppColors.primary,
                      onChanged: (values) {
                        controller.minAge.value = values.start.toInt();
                        controller.maxAge.value = values.end.toInt();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Min: ${controller.minAge.value} years',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          'Max: ${controller.maxAge.value} years',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 24),

            // Height Range
            _buildSectionTitle('Height Range'),
            Obx(() => Column(
                  children: [
                    RangeSlider(
                      values: RangeValues(
                        controller.minHeight.value,
                        controller.maxHeight.value,
                      ),
                      min: 120,
                      max: 220,
                      divisions: 100,
                      labels: RangeLabels(
                        '${controller.minHeight.value.toInt()} cm',
                        '${controller.maxHeight.value.toInt()} cm',
                      ),
                      activeColor: AppColors.primary,
                      onChanged: (values) {
                        controller.minHeight.value = values.start;
                        controller.maxHeight.value = values.end;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Min: ${controller.minHeight.value.toInt()} cm',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          'Max: ${controller.maxHeight.value.toInt()} cm',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 24),

            // Religion
            _buildSectionTitle('Religion'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedReligion.value,
                  items: controller.religions,
                  hint: 'Select Religion',
                  onChanged: (value) => controller.selectedReligion.value = value ?? '',
                )),
            const SizedBox(height: 16),

            // Marital Status
            _buildSectionTitle('Marital Status'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedMaritalStatus.value,
                  items: controller.maritalStatuses,
                  hint: 'Select Marital Status',
                  onChanged: (value) => controller.selectedMaritalStatus.value = value ?? '',
                )),
            const SizedBox(height: 16),

            // Family Type
            _buildSectionTitle('Family Type'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedFamilyType.value,
                  items: controller.familyTypes,
                  hint: 'Select Family Type',
                  onChanged: (value) => controller.selectedFamilyType.value = value ?? '',
                )),
            const SizedBox(height: 16),

            // Education
            _buildSectionTitle('Education'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedEducation.value,
                  items: controller.educationLevels,
                  hint: 'Select Education Level',
                  onChanged: (value) => controller.selectedEducation.value = value ?? '',
                )),
            const SizedBox(height: 16),

            // Department
            _buildSectionTitle('Department'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedDepartment.value,
                  items: controller.departments,
                  hint: 'Select Department',
                  onChanged: (value) => controller.selectedDepartment.value = value ?? '',
                )),
            const SizedBox(height: 16),

            // City
            _buildSectionTitle('Location'),
            const SizedBox(height: 8),
            Obx(() => _buildDropdownField(
                  value: controller.selectedCity.value,
                  items: controller.cities,
                  hint: 'Select City',
                  onChanged: (value) => controller.selectedCity.value = value ?? '',
                )),
            const SizedBox(height: 24),

            // Quick Filters
            _buildSectionTitle('Quick Filters'),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Verified Profiles Only',
                      subtitle: 'Show only verified members',
                      value: controller.verifiedOnly.value,
                      onChanged: (value) => controller.verifiedOnly.value = value,
                    ),
                    _buildSwitchTile(
                      title: 'With Photo Only',
                      subtitle: 'Show profiles with photos',
                      value: controller.withPhotoOnly.value,
                      onChanged: (value) => controller.withPhotoOnly.value = value,
                    ),
                    _buildSwitchTile(
                      title: 'Online Now',
                      subtitle: 'Show currently online members',
                      value: controller.onlineOnly.value,
                      onChanged: (value) => controller.onlineOnly.value = value,
                    ),
                  ],
                )),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.resetFilters();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Apply Filters',
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.where((item) => item.isNotEmpty).map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
