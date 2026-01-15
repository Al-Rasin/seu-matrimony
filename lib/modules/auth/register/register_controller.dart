import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/firebase_service.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final profileFor = Rxn<String>();
  final selectedFile = Rxn<File>();
  final isLoading = false.obs;

  String get selectedFileName {
    if (selectedFile.value == null) return '';
    return selectedFile.value!.path.split('/').last;
  }

  Future<void> pickIdDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (profileFor.value == null) {
      Get.snackbar(
        'Error',
        'Please select who this profile is for',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedFile.value == null) {
      Get.snackbar(
        'Error',
        'Please upload your SEU ID document',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Upload ID document to Firebase Storage
      String? idDocumentUrl;
      if (selectedFile.value != null) {
        idDocumentUrl = await _firebaseService.uploadIdDocument(
          file: selectedFile.value!,
          userId: emailController.text.trim().replaceAll('@', '_'),
        );
      }

      await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: '+880${phoneController.text.trim()}',
        profileFor: profileFor.value!,
        idDocumentUrl: idDocumentUrl,
      );

      Get.offAllNamed(AppRoutes.registration);
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
