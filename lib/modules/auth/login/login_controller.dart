import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/notification_service.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
// ...
      // Request notification permissions
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().requestPermissions();
      }

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
