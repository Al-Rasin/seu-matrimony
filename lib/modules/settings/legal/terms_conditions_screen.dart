import 'package:flutter/material.dart';
import '../../../app/themes/app_text_styles.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Terms of Service', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('Last updated: January 20, 2026', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using SEU Matrimony, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.',
            ),
            _buildSection(
              '2. Eligibility',
              'You must be a student or alumni of Southeast University and at least 18 years old to use this service. Verification with a valid SEU ID is required.',
            ),
            _buildSection(
              '3. User Conduct',
              'Users are expected to maintain respect and decorum. Any form of harassment, fake profiles, or misuse of the platform will result in immediate termination of the account.',
            ),
            _buildSection(
              '4. Privacy',
              'Your privacy is important to us. Please refer to our Privacy Policy for information on how we collect and use your data.',
            ),
            _buildSection(
              '5. Account Termination',
              'We reserve the right to terminate or suspend any account that violates these terms or for any other reason at our sole discretion.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
