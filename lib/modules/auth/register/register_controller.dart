import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/constants/firebase_constants.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final profileFor = Rxn<String>();
  final selectedFile = Rxn<File>();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final acceptedTerms = false.obs;

  final profileForOptions = [
    'Self',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
  ];

  String get selectedFileName {
    if (selectedFile.value == null) return '';
    return selectedFile.value!.path.split('/').last;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Bangladesh phone number validation (10 digits without country code)
    if (!RegExp(r'^1[3-9]\d{8}$').hasMatch(value)) {
      return 'Enter a valid BD mobile number (e.g., 1712345678)';
    }
    return null;
  }

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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> pickIdDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Check file size (max 5MB before compression)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Please select a file smaller than 5MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return;
        }

        selectedFile.value = file;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void removeSelectedFile() {
    selectedFile.value = null;
  }

  /// Convert file to base64 string with compression for images
  Future<String?> _convertFileToBase64(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();

      // For images, compress before converting to base64
      if (['jpg', 'jpeg', 'png'].contains(extension)) {
        final compressed = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          quality: FirebaseConstants.imageQuality,
          minWidth: FirebaseConstants.maxImageDimension,
          minHeight: FirebaseConstants.maxImageDimension,
        );

        if (compressed != null) {
          // Check if compressed size is within limit
          if (compressed.length > FirebaseConstants.maxImageSize) {
            // Try with lower quality
            final moreCompressed = await FlutterImageCompress.compressWithFile(
              file.absolute.path,
              quality: 50,
              minWidth: 800,
              minHeight: 800,
            );
            if (moreCompressed != null && moreCompressed.length <= FirebaseConstants.maxImageSize) {
              return 'data:image/$extension;base64,${base64Encode(moreCompressed)}';
            }
            throw Exception('Image is too large. Please select a smaller image.');
          }
          return 'data:image/$extension;base64,${base64Encode(compressed)}';
        }
      }

      // For PDFs or if compression fails, read directly
      final bytes = await file.readAsBytes();
      if (bytes.length > FirebaseConstants.maxImageSize) {
        throw Exception('File is too large. Maximum size is 500KB.');
      }

      final mimeType = extension == 'pdf' ? 'application/pdf' : 'image/$extension';
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (profileFor.value == null) {
      Get.snackbar(
        'Required',
        'Please select who this profile is for',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    if (selectedFile.value == null) {
      Get.snackbar(
        'Required',
        'Please upload your SEU ID document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    if (!acceptedTerms.value) {
      Get.snackbar(
        'Required',
        'Please accept the Terms & Privacy Policy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Convert ID document to base64
      String? idDocumentBase64;
      if (selectedFile.value != null) {
        idDocumentBase64 = await _convertFileToBase64(selectedFile.value!);
      }

      await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: '+880${phoneController.text.trim()}',
        profileFor: profileFor.value!,
        idDocumentBase64: idDocumentBase64,
      );

      Get.snackbar(
        'Success',
        'Account created successfully! Please complete your profile.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );

      // Navigate to registration flow to complete profile
      Get.offAllNamed(AppRoutes.registration);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
