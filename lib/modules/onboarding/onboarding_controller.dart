import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Create Your SEU Matrimony Profile',
      description:
          'Join the exclusive matrimonial platform for SEU students and alumni',
      icon: Icons.person_add_outlined,
    ),
    OnboardingPage(
      title: 'Verified SEU Members Only',
      description:
          'Every profile is verified through a valid SEU Student ID or Alumni ID before approval',
      icon: Icons.verified_user_outlined,
    ),
    OnboardingPage(
      title: 'Find Your Perfect Match',
      description:
          'Search, connect, and build meaningful relationships within the SEU community',
      icon: Icons.favorite_outline,
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
