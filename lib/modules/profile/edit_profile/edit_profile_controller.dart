import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/firebase_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'edit_basic_details_screen.dart';
import 'edit_personal_details_screen.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;

  // Basic Details Controllers
  final ageController = TextEditingController();
  final dobController = TextEditingController();
  final department = Rxn<String>();
  final gender = Rxn<String>();

  // Personal Details Controllers
  final maritalStatus = Rxn<String>();
  final emailController = TextEditingController();
  final hasChildren = false.obs;
  final noOfChildrenController = TextEditingController();
  final heightController = TextEditingController();
  final religion = Rxn<String>();
  final studentIdController = TextEditingController();
  final isCurrentlyStudying = false.obs;


  @override
  void onClose() {
    ageController.dispose();
    dobController.dispose();
    emailController.dispose();
    noOfChildrenController.dispose();
    heightController.dispose();
    studentIdController.dispose();
    super.onClose();
  }

  Future<void> editBasicDetails() async {
    await _loadBasicDetails();
    Get.to(() => const EditBasicDetailsScreen());
  }

  Future<void> _loadBasicDetails() async {
    try {
      isLoading.value = true;
      final user = await _userRepository.getCurrentUser();
      
      ageController.text = user['age']?.toString() ?? '';
      
      // Handle DOB format
      if (user['dateOfBirth'] != null) {
        final date = DateTime.tryParse(user['dateOfBirth'].toString());
        if (date != null) {
          dobController.text = '${date.day}/${date.month}/${date.year}';
        } else {
           dobController.text = user['dateOfBirth']?.toString() ?? '';
        }
      } else if (user['dob'] != null) {
         dobController.text = user['dob']?.toString() ?? '';
      }

      department.value = user['department'];
      gender.value = user['gender'];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBasicDetails() async {
    try {
      isLoading.value = true;
      await _userRepository.updateBasicDetails({
        FirebaseConstants.fieldAge: int.tryParse(ageController.text) ?? 0,
        FirebaseConstants.fieldDateOfBirth: dobController.text, // You might want to format this to ISO string
        FirebaseConstants.fieldDepartment: department.value,
        FirebaseConstants.fieldGender: gender.value,
      });
      Get.back(); // Close the screen
      Get.snackbar('Success', 'Basic details updated successfully');
      
      // Refresh previous screen if needed (e.g., MyProfile)
      // Get.find<MyProfileController>().loadProfile(); // If feasible
    } catch (e) {
      Get.snackbar('Error', 'Failed to update basic details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPersonalDetails() async {
    await _loadPersonalDetails();
    Get.to(() => const EditPersonalDetailsScreen());
  }

  Future<void> _loadPersonalDetails() async {
    try {
      isLoading.value = true;
      final user = await _userRepository.getCurrentUser();
      
      maritalStatus.value = user['maritalStatus'];
      emailController.text = user['email'] ?? '';
      hasChildren.value = user['hasChildren'] == true;
      noOfChildrenController.text = user['children']?.toString() ?? '0';
      heightController.text = user['height']?.toString() ?? '';
      religion.value = user['religion'];
      studentIdController.text = user['studentId']?.toString() ?? '';
      isCurrentlyStudying.value = user['currentlyStudying'] == true || user['isCurrentlyStudying'] == true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load personal details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePersonalDetails() async {
    try {
      isLoading.value = true;
      await _userRepository.updatePersonalDetails({
        FirebaseConstants.fieldMaritalStatus: maritalStatus.value,
        'hasChildren': hasChildren.value,
        FirebaseConstants.fieldChildren: int.tryParse(noOfChildrenController.text) ?? 0,
        FirebaseConstants.fieldHeight: double.tryParse(heightController.text) ?? 0,
        FirebaseConstants.fieldReligion: religion.value,
        FirebaseConstants.fieldStudentId: studentIdController.text,
        FirebaseConstants.fieldCurrentlyStudying: isCurrentlyStudying.value,
      });
      Get.back();
      Get.snackbar('Success', 'Personal details updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update personal details');
    } finally {
      isLoading.value = false;
    }
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
