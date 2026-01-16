import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: controller.goBack,
        ),
        title: Obx(() => Text(
              _getAppBarTitle(controller.currentStep.value),
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStep(controller.currentStep.value),
            )),
      ),
    );
  }

  String _getAppBarTitle(ResetStep step) {
    switch (step) {
      case ResetStep.enterEmail:
        return 'Forgot Password';
      case ResetStep.emailSent:
        return 'Check Your Email';
    }
  }

  Widget _buildCurrentStep(ResetStep step) {
    switch (step) {
      case ResetStep.enterEmail:
        return _buildEnterEmailStep();
      case ResetStep.emailSent:
        return _buildEmailSentStep();
    }
  }

  Widget _buildEnterEmailStep() {
    return SingleChildScrollView(
      key: const ValueKey('enterEmail'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Reset Your Password',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Email field
            CustomTextField(
              controller: controller.emailController,
              label: 'Email',
              hint: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.iconSecondary),
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 32),
            // Submit button
            Obx(() => CustomButton(
                  text: 'Send Reset Link',
                  onPressed: controller.sendResetLink,
                  isLoading: controller.isLoading.value,
                )),
            const SizedBox(height: 24),
            // Back to login
            TextButton(
              onPressed: controller.goBack,
              child: Text(
                'Back to Login',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSentStep() {
    return SingleChildScrollView(
      key: const ValueKey('emailSent'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 70,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            'Check Your Email',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            'We\'ve sent a password reset link to ${controller.emailController.text}. Please check your inbox and follow the instructions to reset your password.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // Back to Login button
          CustomButton(
            text: 'Back to Login',
            onPressed: controller.goToLogin,
          ),
          const SizedBox(height: 16),
          // Didn't receive email
          TextButton(
            onPressed: controller.resendResetLink,
            child: Text(
              'Didn\'t receive the email? Try again',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
