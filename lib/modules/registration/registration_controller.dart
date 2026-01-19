import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/constants/firebase_constants.dart';

class RegistrationController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final currentStep = 0.obs;
  final isLoading = false.obs;

  // Step 1: Basic Details
  final ageController = TextEditingController();
  final dobController = TextEditingController();
  final department = Rxn<String>();
  final gender = Rxn<String>();

  // Step 2: Personal Details
  final maritalStatus = Rxn<String>();
  final emailController = TextEditingController();
  final hasChildren = false.obs;
  final noOfChildren = 0.obs;
  final childrenLivingWith = false.obs;
  final heightController = TextEditingController();
  final religion = Rxn<String>();
  final studentIdController = TextEditingController();
  final isCurrentlyStudying = false.obs;
  final familyType = Rxn<String>();

  // Step 3: Professional Details
  final highestEducation = Rxn<String>();
  final employment = Rxn<String>();
  final occupationController = TextEditingController();
  final annualIncome = Rxn<String>();
  final workLocationController = TextEditingController();
  final currentCityController = TextEditingController();

  // Step 4: About Yourself
  final bioController = TextEditingController();

  void nextStep() {
    if (currentStep.value < 4) {
      if (_validateCurrentStep()) {
        _saveCurrentStepData();
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (ageController.text.isEmpty || gender.value == null) {
          Get.snackbar('Error', 'Please fill all required fields',
              snackPosition: SnackPosition.BOTTOM);
          return false;
        }
        return true;
      case 1:
        if (maritalStatus.value == null || religion.value == null) {
          Get.snackbar('Error', 'Please fill all required fields',
              snackPosition: SnackPosition.BOTTOM);
          return false;
        }
        return true;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return true;
    }
  }

  Future<void> _saveCurrentStepData() async {
    try {
      isLoading.value = true;

      switch (currentStep.value) {
        case 0:
          await _userRepository.updateBasicDetails({
            FirebaseConstants.fieldAge: int.tryParse(ageController.text) ?? 0,
            FirebaseConstants.fieldDateOfBirth: dobController.text,
            FirebaseConstants.fieldDepartment: department.value,
            FirebaseConstants.fieldGender: gender.value,
          });
          break;
        case 1:
          await _userRepository.updatePersonalDetails({
            FirebaseConstants.fieldMaritalStatus: maritalStatus.value,
            'hasChildren': hasChildren.value, // Keep as is for now if not in constants or handle mapping
            FirebaseConstants.fieldChildren: noOfChildren.value,
            'childrenLivingWith': childrenLivingWith.value,
            FirebaseConstants.fieldHeight: double.tryParse(heightController.text) ?? 0,
            FirebaseConstants.fieldReligion: religion.value,
            FirebaseConstants.fieldStudentId: studentIdController.text,
            FirebaseConstants.fieldCurrentlyStudying: isCurrentlyStudying.value,
            'familyType': familyType.value,
          });
          break;
        case 2:
          await _userRepository.updateProfessionalDetails({
            FirebaseConstants.fieldHighestEducation: highestEducation.value,
            FirebaseConstants.fieldEmploymentStatus: employment.value,
            FirebaseConstants.fieldOccupation: occupationController.text,
            'annualIncome': annualIncome.value, // No constant?
            'workLocation': workLocationController.text, // No constant?
            FirebaseConstants.fieldCurrentCity: currentCityController.text,
          });
          break;
        case 3:
          await _userRepository.updateBasicDetails({
            FirebaseConstants.fieldAbout: bioController.text,
          });
          break;
      }
    } catch (e) {
      // Handle error silently or show snackbar
      print('Error saving step data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    ageController.dispose();
    dobController.dispose();
    emailController.dispose();
    heightController.dispose();
    studentIdController.dispose();
    occupationController.dispose();
    workLocationController.dispose();
    currentCityController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
