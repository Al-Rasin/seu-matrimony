import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Create Your SEU\nMatrimony Profile',
      description:
          'Join the exclusive matrimonial\nplatform for SEU students and alumni',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Verified SEU\nMembers Only',
      description:
          'Every profile is verified through a valid\nSEU Student ID or Alumni ID before approval',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Find Your\nPerfect Match',
      description:
          'Search, connect, and build meaningful\nrelationships within the SEU community',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  bool get isLastPage => currentPage.value == onboardingPages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (isLastPage) {
      _completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    _storageService.hasSeenOnboarding = true;
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
