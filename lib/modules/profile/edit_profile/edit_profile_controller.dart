import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/firebase_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;

  void editBasicDetails() {
    // Navigate to basic details edit screen (to be implemented)
    Get.snackbar('Info', 'Edit Basic Details coming soon');
  }

  void editPersonalDetails() {
    Get.snackbar('Info', 'Edit Personal Details coming soon');
  }

  void editProfessionalDetails() {
    Get.snackbar('Info', 'Edit Professional Details coming soon');
  }

  void editFamilyDetails() {
    Get.snackbar('Info', 'Edit Family Details coming soon');
  }

  void editPreferences() {
    Get.snackbar('Info', 'Edit Preferences coming soon');
  }

  Future<void> editPhotos() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: FirebaseConstants.maxImageDimension.toDouble(),
        maxHeight: FirebaseConstants.maxImageDimension.toDouble(),
        imageQuality: FirebaseConstants.imageQuality,
      );

      if (image != null) {
        isLoading.value = true;
        
        final File file = File(image.path);
        final String? base64Image = await _convertImageToBase64(file);
        
        if (base64Image != null) {
          await _userRepository.updateProfilePhoto(base64Image);
          Get.snackbar('Success', 'Profile photo updated successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile photo: ${e.toString()}');
    } finally {
      isLoading.value = false;
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
}
