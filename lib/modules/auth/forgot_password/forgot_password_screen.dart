import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      case ResetStep.verifyOtp:
        return 'Verify OTP';
      case ResetStep.setNewPassword:
        return 'New Password';
      case ResetStep.success:
        return 'Success';
    }
  }

  Widget _buildCurrentStep(ResetStep step) {
    switch (step) {
      case ResetStep.enterEmail:
        return _buildEnterEmailStep();
      case ResetStep.verifyOtp:
        return _buildVerifyOtpStep();
      case ResetStep.setNewPassword:
        return _buildSetNewPasswordStep();
      case ResetStep.success:
        return _buildSuccessStep();
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
              'Enter your email address or phone number and we\'ll send you a link/OTP to reset your password.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Email/Phone field
            CustomTextField(
              controller: controller.emailController,
              label: 'Email or Phone',
              hint: 'Enter your email or phone number',
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

  Widget _buildVerifyOtpStep() {
    return SingleChildScrollView(
      key: const ValueKey('verifyOtp'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.otpFormKey,
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
                Icons.sms_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Verify Your Phone',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'We\'ve sent a 6-digit code to ${controller.emailController.text}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // OTP field
            CustomTextField(
              controller: controller.otpController,
              label: 'OTP Code',
              hint: 'Enter 6-digit code',
              prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.iconSecondary),
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: controller.validateOtp,
            ),
            const SizedBox(height: 16),
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Obx(() => controller.canResendOtp.value
                    ? GestureDetector(
                        onTap: controller.resendOtp,
                        child: Text(
                          'Resend',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        'Resend in ${controller.resendCountdown.value}s',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )),
              ],
            ),
            const SizedBox(height: 32),
            // Verify button
            Obx(() => CustomButton(
                  text: 'Verify',
                  onPressed: controller.verifyOtp,
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSetNewPasswordStep() {
    return SingleChildScrollView(
      key: const ValueKey('setNewPassword'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.passwordFormKey,
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
                Icons.lock_outline,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Create New Password',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'Your new password must be different from previously used passwords.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // New Password field
            CustomTextField(
              controller: controller.newPasswordController,
              label: 'New Password',
              hint: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
              obscureText: true,
              validator: controller.validatePassword,
            ),
            const SizedBox(height: 16),
            // Confirm Password field
            CustomTextField(
              controller: controller.confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm new password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
              obscureText: true,
              validator: controller.validateConfirmPassword,
            ),
            const SizedBox(height: 16),
            // Password requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password must contain:',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement('At least 8 characters'),
                  _buildRequirement('At least one uppercase letter'),
                  _buildRequirement('At least one lowercase letter'),
                  _buildRequirement('At least one number'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Reset button
            Obx(() => CustomButton(
                  text: 'Reset Password',
                  onPressed: controller.resetPassword,
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return SingleChildScrollView(
      key: const ValueKey('success'),
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
              Icons.check_circle,
              size: 70,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            controller.isPhoneNumber.value
                ? 'Password Reset Successful!'
                : 'Check Your Email',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            controller.isPhoneNumber.value
                ? 'Your password has been reset successfully. You can now log in with your new password.'
                : 'We\'ve sent a password reset link to ${controller.emailController.text}. Please check your inbox and follow the instructions.',
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
          // Didn't receive email (for email flow)
          if (!controller.isPhoneNumber.value) ...[
            TextButton(
              onPressed: () {
                controller.reset();
              },
              child: Text(
                'Didn\'t receive the email? Try again',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
