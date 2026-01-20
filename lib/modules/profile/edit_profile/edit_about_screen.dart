import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../shared/widgets/custom_text_field.dart';

class EditAboutScreen extends GetView<EditProfileController> {
  const EditAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit About Yourself'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'About You',
              hint: 'Write something about yourself...',
              controller: controller.bioController,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveAbout(),
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
