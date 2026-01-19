import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/repositories/user_repository.dart';

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
            'age': int.tryParse(ageController.text) ?? 0,
            'dob': dobController.text,
            'department': department.value,
            'gender': gender.value,
          });
          break;
        case 1:
          await _userRepository.updatePersonalDetails({
            'maritalStatus': maritalStatus.value,
            'hasChildren': hasChildren.value,
            'noOfChildren': noOfChildren.value,
            'childrenLivingWith': childrenLivingWith.value,
            'height': double.tryParse(heightController.text) ?? 0,
            'religion': religion.value,
            'studentId': studentIdController.text,
            'isCurrentlyStudying': isCurrentlyStudying.value,
          });
          break;
        case 2:
          await _userRepository.updateProfessionalDetails({
            'highestEducation': highestEducation.value,
            'employment': employment.value,
            'occupation': occupationController.text,
            'annualIncome': annualIncome.value,
            'workLocation': workLocationController.text,
            'currentCity': currentCityController.text,
          });
          break;
        case 3:
          await _userRepository.updateBasicDetails({
            'bio': bioController.text,
          });
          break;
      }
    } catch (e) {
      // Handle error silently or show snackbar
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
