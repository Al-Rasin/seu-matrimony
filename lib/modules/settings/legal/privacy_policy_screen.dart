import 'package:flutter/material.dart';
import '../../../app/themes/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Policy', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('Last updated: January 20, 2026', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us when you create an account, including your name, email, student ID, and profile details.',
            ),
            _buildSection(
              '2. How We Use Information',
              'We use the information to provide, maintain, and improve our services, to match you with potential partners, and to communicate with you.',
            ),
            _buildSection(
              '3. Information Sharing',
              'Your profile is visible to other registered and verified users. Your contact information is only shared with users whose interest you have accepted.',
            ),
            _buildSection(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal data against unauthorized processing and accidental loss.',
            ),
            _buildSection(
              '5. Your Rights',
              'You have the right to access, correct, or delete your personal information at any time through the application settings.',
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
