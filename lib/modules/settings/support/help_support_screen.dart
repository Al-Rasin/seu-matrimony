import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpTile(
            context,
            'FAQs',
            'Find answers to frequently asked questions',
            Icons.question_answer_outlined,
            () {},
          ),
          _buildHelpTile(
            context,
            'Contact Us',
            'Reach out to our support team',
            Icons.mail_outline,
            () {},
          ),
          _buildHelpTile(
            context,
            'Report a Problem',
            'Let us know if something is not working',
            Icons.report_problem_outlined,
            () {},
          ),
          _buildHelpTile(
            context,
            'Safety Tips',
            'Learn how to stay safe while using SEU Matrimony',
            Icons.security,
            () {},
          ),
          const SizedBox(height: 24),
          const Text(
            'Common Questions',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I verify my account?',
            'You can verify your account by uploading your SEU Student ID in the profile settings.',
          ),
          _buildFaqItem(
            'Is my data safe?',
            'Yes, we take privacy seriously. Your contact information is only visible to your accepted matches.',
          ),
          _buildFaqItem(
            'How do I delete my account?',
            'You can find the delete account option in the main Settings page under Account section.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}
