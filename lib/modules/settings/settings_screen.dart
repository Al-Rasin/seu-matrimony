import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection('Account'),
          _buildTile('Privacy Settings', Icons.lock_outline, () {}),
          _buildTile('Notification Settings', Icons.notifications_outlined, () {}),
          _buildTile('Blocked Users', Icons.block, () {}),
          _buildSection('Support'),
          _buildTile('Help Center', Icons.help_outline, () {}),
          _buildTile('Contact Us', Icons.mail_outline, () {}),
          _buildTile('Report a Problem', Icons.flag_outlined, () {}),
          _buildSection('Legal'),
          _buildTile('Terms of Service', Icons.description_outlined, () {}),
          _buildTile('Privacy Policy', Icons.privacy_tip_outlined, () {}),
          _buildSection('About'),
          _buildTile('App Version', Icons.info_outline, () {},
              trailing: const Text('1.0.0')),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.iconPrimary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
