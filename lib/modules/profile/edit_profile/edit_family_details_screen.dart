import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class EditFamilyDetailsScreen extends GetView<EditProfileController> {
  const EditFamilyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Family Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SimpleDropdown(
                  label: 'Family Type',
                  hint: 'Select family type',
                  value: controller.familyType.value,
                  items: const ['Nuclear', 'Joint', 'Other'],
                  onChanged: (value) => controller.familyType.value = value,
                )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveFamilyDetails(),
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
