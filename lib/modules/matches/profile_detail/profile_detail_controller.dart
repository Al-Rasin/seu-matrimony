import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileDetailController extends GetxController {
  final MatchRepository _matchRepository = Get.find<MatchRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final Rxn<MatchModel> profile = Rxn<MatchModel>();
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isShortlisted = false.obs;
  final interestStatus = Rxn<InterestStatus>();

  String? matchId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    matchId = args?['matchId'] ?? args?['userId'];
    if (matchId != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    if (matchId == null) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      final data = await _matchRepository.getMatchProfile(matchId!);
      if (data == null) {
        hasError.value = true;
        errorMessage.value = 'Profile not found';
        return;
      }
      profile.value = data;
      isShortlisted.value = data.isShortlisted;
      interestStatus.value = data.interestStatus;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user is verified by admin (fetches fresh data from Firestore)
  Future<bool> _checkAdminVerification() async {
    final isVerified = await _authRepository.isAdminVerified();
    if (!isVerified) {
      Get.snackbar(
        'Account Not Verified',
        'Your account is pending verification by admin. You can complete your profile while waiting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
    return true;
  }

  Future<void> sendInterest() async {
    if (matchId == null) return;
    if (!await _checkAdminVerification()) return;

    try {
      final success = await _matchRepository.sendInterest(matchId!);
      if (success) {
        interestStatus.value = InterestStatus.sent;
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(interestStatus: InterestStatus.sent);
        }
        Get.snackbar(
          'Success',
          'Interest sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send interest',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelInterest() async {
    if (matchId == null) return;
    if (!await _checkAdminVerification()) return;

    try {
      final success = await _matchRepository.cancelInterest(matchId!);
      if (success) {
        interestStatus.value = InterestStatus.none;
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(interestStatus: InterestStatus.none);
        }
        Get.snackbar(
          'Success',
          'Interest cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Interest not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel interest: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> skipProfile() async {
    Get.back();
  }

  Future<void> toggleShortlist() async {
    if (matchId == null) return;
    if (!await _checkAdminVerification()) return;

    try {
      bool success;
      if (isShortlisted.value) {
        success = await _matchRepository.removeFromShortlist(matchId!);
      } else {
        success = await _matchRepository.addToShortlist(matchId!);
      }

      if (success) {
        isShortlisted.value = !isShortlisted.value;
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(isShortlisted: isShortlisted.value);
        }
        Get.snackbar(
          'Success',
          isShortlisted.value ? 'Added to shortlist' : 'Removed from shortlist',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update shortlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> acceptInterest() async {
    if (matchId == null) return;
    if (!await _checkAdminVerification()) return;

    final interestId = profile.value?.interestId;
    if (interestId == null || interestId.isEmpty) {
      Get.snackbar(
        'Error',
        'Interest not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final success = await _matchRepository.acceptInterest(interestId);
      if (success) {
        interestStatus.value = InterestStatus.accepted;
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(interestStatus: InterestStatus.accepted);
        }
        Get.snackbar(
          'Success',
          'Interest accepted! You are now connected.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept interest',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectInterest() async {
    if (matchId == null) return;
    if (!await _checkAdminVerification()) return;

    final interestId = profile.value?.interestId;
    if (interestId == null || interestId.isEmpty) {
      Get.snackbar(
        'Error',
        'Interest not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final success = await _matchRepository.rejectInterest(interestId);
      if (success) {
        interestStatus.value = InterestStatus.rejected;
        if (profile.value != null) {
          profile.value = profile.value!.copyWith(interestStatus: InterestStatus.rejected);
        }
        Get.snackbar(
          'Info',
          'Interest declined',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to decline interest',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> blockUser() async {
    if (matchId == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user? They will no longer be able to see your profile or contact you.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _matchRepository.blockUser(matchId!);
      if (success) {
        Get.snackbar(
          'Success',
          'User blocked',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> reportUser() async {
    if (matchId == null) return;

    final reason = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this user?'),
            const SizedBox(height: 16),
            ...['Fake profile', 'Inappropriate content', 'Harassment', 'Spam', 'Other'].map(
              (option) => ListTile(
                title: Text(option),
                onTap: () => Get.back(result: option),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );

    if (reason == null) return;

    try {
      final success = await _matchRepository.reportUser(userId: matchId!, reason: reason);
      if (success) {
        Get.snackbar(
          'Success',
          'Report submitted. We will review it shortly.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit report',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> startChat() async {
    if (profile.value == null) return;
    if (!await _checkAdminVerification()) return;

    Get.toNamed('/chat-detail', arguments: {
      'userId': matchId,
      'userName': profile.value!.fullName,
      'userPhoto': profile.value!.profilePhoto,
    });
  }
}
