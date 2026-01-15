import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'filters_controller.dart';
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
            Text('Age Range', style: AppTextStyles.labelLarge),
            Obx(() => RangeSlider(
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
                  onChanged: (values) {
                    controller.minAge.value = values.start.toInt();
                    controller.maxAge.value = values.end.toInt();
                  },
                )),
            const SizedBox(height: 16),
            Text('Height Range (cm)', style: AppTextStyles.labelLarge),
            Obx(() => RangeSlider(
                  values: RangeValues(
                    controller.minHeight.value,
                    controller.maxHeight.value,
                  ),
                  min: 120,
                  max: 220,
                  divisions: 100,
                  labels: RangeLabels(
                    '${controller.minHeight.value.toInt()}',
                    '${controller.maxHeight.value.toInt()}',
                  ),
                  onChanged: (values) {
                    controller.minHeight.value = values.start;
                    controller.maxHeight.value = values.end;
                  },
                )),
            const SizedBox(height: 24),
            Text('Match Preference', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            ...['All Matches', 'Newly Joined', 'Viewed You', 'Shortlisted You']
                .map((option) => Obx(() => CheckboxListTile(
                      title: Text(option),
                      value: controller.selectedPreferences.contains(option),
                      onChanged: (_) => controller.togglePreference(option),
                      contentPadding: EdgeInsets.zero,
                    ))),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: 'Apply Filters',
          onPressed: () {
            controller.applyFilters();
            Get.back();
          },
        ),
      ),
    );
  }
}
