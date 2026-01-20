import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return _buildPage(page, index);
                },
              ),
            ),
            _buildBottomSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Illustration
          SizedBox(
            width: 285,
            height: 267,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to placeholder icons if image not found
                return _buildPlaceholderIcon(index);
              },
            ),
          ),
          const Spacer(),
          // Title
          Text(
            page.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(int index) {
    final icons = [
      Icons.person_add_outlined,
      Icons.verified_user_outlined,
      Icons.favorite_outline,
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icons[index],
        size: 120,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomSection(OnboardingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          // Page indicators
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onboardingPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: controller.currentPage.value == index ? 30 : 13,
                    height: controller.currentPage.value == index ? 8 : 13,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(
                          controller.currentPage.value == index ? 10 : 7),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 40),
          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button
              TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Next button
              Obx(() => GestureDetector(
                    onTap: controller.next,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        controller.isLastPage
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}