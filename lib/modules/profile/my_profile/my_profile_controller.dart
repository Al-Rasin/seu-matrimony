import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:convert';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/firebase_constants.dart';

class MyProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final ImagePicker _picker = ImagePicker();

  final userName = ''.obs;
  final userEmail = ''.obs;
  final profilePhotoUrl = ''.obs;
  
  final userAge = ''.obs;
  final userGender = ''.obs;
  final userDepartment = ''.obs;
  
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = await _userRepository.getCurrentUser();
      userName.value = user['fullName'] ?? 'User';
      userEmail.value = user['email'] ?? '';
      profilePhotoUrl.value = user[FirebaseConstants.fieldProfilePhoto] ?? user['profilePhotoUrl'] ?? '';
      
      userAge.value = user['age']?.toString() ?? '';
      userGender.value = user['gender'] ?? '';
      userDepartment.value = user['department'] ?? '';
    } catch (e) {
      // Handle error
    }
  }

  void showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Profile Photo'),
              onTap: () {
                Get.back();
                viewPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Upload New Photo'),
              onTap: () {
                Get.back();
                uploadPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void viewPhoto() {
    if (profilePhotoUrl.value.isEmpty) {
      Get.snackbar('Info', 'No profile photo to view');
      return;
    }
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: _buildImage(profilePhotoUrl.value, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('data:image')) {
      try {
         final base64String = url.split(',').last;
         return Image.memory(
           base64Decode(base64String.trim()),
           fit: fit,
           errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
         );
      } catch (e) {
        return const Icon(Icons.error, color: Colors.white);
      }
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
         errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
      );
    } else {
       // Try raw base64
       try {
         return Image.memory(
           base64Decode(url.trim()),
           fit: fit,
           errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
         );
       } catch (e) {
          return const Icon(Icons.error, color: Colors.white);
       }
    }
  }

  Future<void> uploadPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: FirebaseConstants.maxImageDimension.toDouble(),
        maxHeight: FirebaseConstants.maxImageDimension.toDouble(),
        imageQuality: FirebaseConstants.imageQuality,
      );

      if (image != null) {
        isUploading.value = true;
        
        final File file = File(image.path);
        final String? base64Image = await _convertImageToBase64(file);
        
        if (base64Image != null) {
          await _userRepository.updateProfilePhoto(base64Image);
          // Refresh profile data locally
          profilePhotoUrl.value = base64Image;
          Get.snackbar('Success', 'Profile photo updated successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile photo: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  Future<String?> _convertImageToBase64(File file) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: FirebaseConstants.imageQuality,
        minWidth: FirebaseConstants.maxImageDimension,
        minHeight: FirebaseConstants.maxImageDimension,
      );

      if (compressed != null) {
        final extension = file.path.split('.').last.toLowerCase();
        return 'data:image/$extension;base64,${base64Encode(compressed)}';
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  void editPhoto() {
     // Deprecated in favor of showPhotoOptions, or redirect to it
     showPhotoOptions();
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              try {
                await _authRepository.logout();
                Get.offAllNamed(AppRoutes.login);
              } catch (e) {
                Get.snackbar('Error', 'Failed to logout');
              }
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
