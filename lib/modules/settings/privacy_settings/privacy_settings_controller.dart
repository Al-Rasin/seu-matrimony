import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/firebase_constants.dart';

class PrivacySettingsController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final isLoading = true.obs;
  
  // Settings Observables
  final profilePhotoVisibility = FirebaseConstants.privacyAll.obs;
  final contactInfoVisibility = FirebaseConstants.privacyConnected.obs;
  final showOnlineStatus = true.obs;
  final readReceipts = true.obs;
  final isProfileVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final settings = await _userRepository.getPrivacySettings();
      
      if (settings.isNotEmpty) {
        profilePhotoVisibility.value = settings[FirebaseConstants.fieldPrivacyProfilePhoto] ?? FirebaseConstants.privacyAll;
        contactInfoVisibility.value = settings[FirebaseConstants.fieldPrivacyContactInfo] ?? FirebaseConstants.privacyConnected;
        showOnlineStatus.value = settings[FirebaseConstants.fieldPrivacyShowOnlineStatus] ?? true;
        readReceipts.value = settings[FirebaseConstants.fieldPrivacyReadReceipts] ?? true;
        isProfileVisible.value = settings[FirebaseConstants.fieldPrivacyIsProfileVisible] ?? true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load privacy settings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      final settings = {
        FirebaseConstants.fieldPrivacyProfilePhoto: profilePhotoVisibility.value,
        FirebaseConstants.fieldPrivacyContactInfo: contactInfoVisibility.value,
        FirebaseConstants.fieldPrivacyShowOnlineStatus: showOnlineStatus.value,
        FirebaseConstants.fieldPrivacyReadReceipts: readReceipts.value,
        FirebaseConstants.fieldPrivacyIsProfileVisible: isProfileVisible.value,
      };

      await _userRepository.updatePrivacySettings(settings);
      
      // Optional: Show success snackbar only if triggered manually, 
      // but usually settings save automatically on change or via a save button.
      // Here we will save on change, so no snackbar needed every time.
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings');
    }
  }

  // Update methods called from UI
  void updateProfilePhotoVisibility(String? value) {
    if (value != null) {
      profilePhotoVisibility.value = value;
      saveSettings();
    }
  }

  void updateContactInfoVisibility(String? value) {
    if (value != null) {
      contactInfoVisibility.value = value;
      saveSettings();
    }
  }

  void toggleShowOnlineStatus(bool value) {
    showOnlineStatus.value = value;
    saveSettings();
  }

  void toggleReadReceipts(bool value) {
    readReceipts.value = value;
    saveSettings();
  }

  void toggleProfileVisibility(bool value) {
    isProfileVisible.value = value;
    saveSettings();
  }
}
