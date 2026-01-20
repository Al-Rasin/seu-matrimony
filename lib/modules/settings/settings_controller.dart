import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<void> changePassword() async {
    final email = _authRepository.currentUser?.email;
    if (email != null) {
      await _authRepository.sendPasswordResetEmail(email);
      Get.snackbar('Success', 'Password reset link sent to $email');
    } else {
      Get.snackbar('Error', 'Could not find user email');
    }
  }

  Future<void> deleteAccount() async {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        // Implement account deletion logic here
        // await _userRepository.deleteAccount();
        Get.back();
        Get.snackbar('Account Deleted', 'Your account has been successfully deleted.');
        logout();
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed('/login');
  }
}
