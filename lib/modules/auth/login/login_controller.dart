import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/notification_service.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final user = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Check user role for redirect
      final role = await _authRepository.getUserRole();

      // Check email verification
      final isVerified = await _authRepository.isEmailVerified();
      if (!isVerified) {
        await _authRepository.logout();
        Get.snackbar(
          'Email Not Verified',
          'Please verify your email address to continue. Check your inbox.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // Request notification permissions
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().requestPermissions();
      }

      Get.snackbar(
        'Welcome!',
        'Hello, ${user.fullName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );

      // Redirect based on role
      if (role == 'admin' || role == 'super_admin') {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        // Check if profile is complete
        final isComplete = await _authRepository.isProfileComplete();
        if (isComplete) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          // Redirect to complete registration
          Get.offAllNamed(AppRoutes.registration);
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      // Clean up the error message
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}