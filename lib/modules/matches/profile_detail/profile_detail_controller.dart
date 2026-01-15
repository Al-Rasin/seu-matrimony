import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/chat_repository.dart';

class ProfileDetailController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final InterestRepository _interestRepository = Get.find<InterestRepository>();
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  final profile = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  String? userId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    userId = args?['userId'];
    if (userId != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      final data = await _userRepository.getUserById(userId!);
      profile.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendInterest(bool interested) async {
    if (!interested || userId == null) return;

    try {
      await _interestRepository.sendInterest(userId!);
      Get.snackbar('Success', 'Interest sent successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send interest');
    }
  }

  Future<void> blockUser() async {
    if (userId == null) return;

    try {
      await _chatRepository.blockUser(userId!);
      Get.snackbar('Success', 'User blocked');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user');
    }
  }

  Future<void> reportUser() async {
    // Show report dialog
    Get.dialog(
      // Report dialog would be implemented here
      const SizedBox(),
    );
  }
}
