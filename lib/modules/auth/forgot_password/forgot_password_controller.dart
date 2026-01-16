import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';

enum ResetStep { enterEmail, verifyOtp, setNewPassword, success }

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final currentStep = ResetStep.enterEmail.obs;
  final isPhoneNumber = false.obs;
  final canResendOtp = true.obs;
  final resendCountdown = 0.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }
    // Check if it's a phone number or email
    if (GetUtils.isPhoneNumber(value)) {
      isPhoneNumber.value = true;
      return null;
    }
    if (GetUtils.isEmail(value)) {
      isPhoneNumber.value = false;
      return null;
    }
    return 'Please enter a valid email or phone number';
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(emailController.text.trim());

      if (isPhoneNumber.value) {
        // For phone number, proceed to OTP verification
        currentStep.value = ResetStep.verifyOtp;
        _startResendCountdown();
        Get.snackbar(
          'OTP Sent',
          'A verification code has been sent to ${emailController.text}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        // For email, show success message
        currentStep.value = ResetStep.success;
        Get.snackbar(
          'Email Sent',
          'Password reset link has been sent to ${emailController.text}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulate OTP verification (mock)
      await Future.delayed(const Duration(seconds: 1));

      // For mock, accept any 6-digit OTP
      currentStep.value = ResetStep.setNewPassword;

      Get.snackbar(
        'Verified',
        'OTP verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;

      // Simulate resending OTP
      await Future.delayed(const Duration(seconds: 1));

      _startResendCountdown();

      Get.snackbar(
        'OTP Resent',
        'A new verification code has been sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendCountdown() {
    canResendOtp.value = false;
    resendCountdown.value = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendCountdown.value--;
      if (resendCountdown.value <= 0) {
        canResendOtp.value = true;
        return false;
      }
      return true;
    });
  }

  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulate password reset
      await Future.delayed(const Duration(seconds: 1));

      currentStep.value = ResetStep.success;

      Get.snackbar(
        'Success',
        'Your password has been reset successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    if (currentStep.value == ResetStep.enterEmail) {
      Get.back();
    } else if (currentStep.value == ResetStep.success) {
      Get.offAllNamed('/login');
    } else {
      // Go back to previous step
      currentStep.value = ResetStep.values[currentStep.value.index - 1];
    }
  }

  void goToLogin() {
    Get.offAllNamed('/login');
  }

  void reset() {
    currentStep.value = ResetStep.enterEmail;
    emailController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    isPhoneNumber.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
