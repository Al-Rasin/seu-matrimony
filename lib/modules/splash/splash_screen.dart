import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../app/themes/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFECCECE),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Content overlay
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Image.asset(
                    'assets/images/splash_logo.png',
                    width: 150,
                    height: 225,
                  ),
                  const SizedBox(height: 16),
                  // App Name
                  Text(
                    'SEU',
                    style: AppTextStyles.h1.copyWith(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    'Matrimony',
                    style: AppTextStyles.h2.copyWith(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Loading indicator
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                          strokeWidth: 2,
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
