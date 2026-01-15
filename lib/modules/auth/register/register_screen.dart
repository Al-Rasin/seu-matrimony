import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top banner
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8B4B4),
                    Color(0xFFD49292),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Register for Free',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // Registration form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEU ID Upload Section
                    Text(
                      'Upload scanned copy of your\nSEU ID card (JPG or PDF)',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Obx(() => GestureDetector(
                          onTap: controller.pickIdDocument,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.border,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  controller.selectedFile.value != null
                                      ? Icons.check_circle
                                      : Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: controller.selectedFile.value != null
                                      ? AppColors.success
                                      : AppColors.iconSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.selectedFile.value != null
                                      ? controller.selectedFileName
                                      : 'Drag & drop files here',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (controller.selectedFile.value == null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'or',
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Browse',
                                      style: AppTextStyles.buttonSmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    SimpleDropdown(
                      label: 'Select a profile for',
                      hint: 'Self/Son/Daughter/etc.',
                      items: const [
                        'Self',
                        'Son',
                        'Daughter',
                        'Brother',
                        'Sister',
                        'Relative',
                        'Friend'
                      ],
                      onChanged: (value) => controller.profileFor.value = value,
                      validator: (value) =>
                          value == null ? 'Please select an option' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: controller.fullNameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PhoneTextField(
                      label: 'Mobile Number',
                      controller: controller.phoneController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your mobile number';
                        }
                        if (value!.length < 10) {
                          return 'Please enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      label: 'Create Password',
                      hint: 'Create a password',
                      controller: controller.passwordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please create a password';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CustomButton(
                          text: 'Register Now',
                          onPressed: controller.register,
                          isLoading: controller.isLoading.value,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already a member? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Login',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ' here.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
