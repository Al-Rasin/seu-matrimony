import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

/// Firebase Auth only supports email-based password reset.
/// The user receives an email with a link to reset their password
/// on Firebase's interface.
enum ResetStep { enterEmail, emailSent }

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final currentStep = ResetStep.enterEmail.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(emailController.text.trim());

      // Firebase sends the reset email - show success
      currentStep.value = ResetStep.emailSent;

      Get.snackbar(
        'Email Sent',
        'Password reset link has been sent to ${emailController.text}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendResetLink() async {
    // Reset to enter email step to allow resending
    currentStep.value = ResetStep.enterEmail;
  }

  void goBack() {
    if (currentStep.value == ResetStep.enterEmail) {
      Get.back();
    } else {
      currentStep.value = ResetStep.enterEmail;
    }
  }

  void goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  void reset() {
    currentStep.value = ResetStep.enterEmail;
    emailController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
