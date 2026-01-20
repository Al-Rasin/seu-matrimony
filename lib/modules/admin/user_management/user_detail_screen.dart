import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../data/models/user_model.dart';
import 'user_management_controller.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserManagementController>();
    final userData = Get.arguments as Map<String, dynamic>;
    final user = UserModel.fromFirestore({...userData, 'id': userData['id'] ?? ''});

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(AppRoutes.adminEditUser, arguments: userData),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value, userData, controller),
            itemBuilder: (context) => _buildMenuItems(userData),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user, userData),
            const SizedBox(height: 24),
            _buildStatusSection(userData, controller),
            const SizedBox(height: 24),
            _buildSection('Basic Information', [
              _buildInfoRow('Full Name', user.fullName),
              _buildInfoRow('Email', user.email ?? 'Not provided'),
              _buildInfoRow('Phone', user.phone ?? 'Not provided'),
              _buildInfoRow('Gender', user.gender ?? 'Not provided'),
              _buildInfoRow('Date of Birth', _formatDate(user.dateOfBirth)),
              _buildInfoRow('Age', user.calculatedAge?.toString() ?? 'N/A'),
            ]),
            const SizedBox(height: 16),
            _buildSection('SEU Details', [
              _buildInfoRow('Department', user.department ?? 'Not provided'),
              _buildInfoRow('Student ID', user.studentId ?? 'Not provided'),
              _buildInfoRow('Currently Studying', user.isCurrentlyStudying == true ? 'Yes' : 'No'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Personal Details', [
              _buildInfoRow('Marital Status', user.maritalStatus ?? 'Not provided'),
              _buildInfoRow('Has Children', user.hasChildren == true ? 'Yes' : 'No'),
              if (user.hasChildren == true)
                _buildInfoRow('Number of Children', user.numberOfChildren?.toString() ?? 'N/A'),
              _buildInfoRow('Height', user.height != null ? '${user.height} ft' : 'Not provided'),
              _buildInfoRow('Religion', user.religion ?? 'Not provided'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Professional Details', [
              _buildInfoRow('Highest Education', user.highestEducation ?? 'Not provided'),
              _buildInfoRow('Education Details', user.educationDetails ?? 'Not provided'),
              _buildInfoRow('Employment Type', user.employmentType ?? 'Not provided'),
              _buildInfoRow('Occupation', user.occupation ?? 'Not provided'),
              _buildInfoRow('Annual Income', user.annualIncome ?? 'Not provided'),
              _buildInfoRow('Work Location', user.workLocation ?? 'Not provided'),
              _buildInfoRow('Company Name', user.companyName ?? 'Not provided'),
              _buildInfoRow('Current City', user.currentCity ?? 'Not provided'),
            ]),
            const SizedBox(height: 16),
            _buildSection('About', [
              _buildInfoRow('Bio', user.bio ?? 'Not provided'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Account Information', [
              _buildInfoRow('User ID', user.id),
              _buildInfoRow('Role', _formatRole(user.role)),
              _buildInfoRow('Profile Status', _formatProfileStatus(user.profileStatus)),
              _buildInfoRow('Profile Completion', '${user.profileCompletionPercentage}%'),
              _buildInfoRow('Email Verified', user.isEmailVerified ? 'Yes' : 'No'),
              _buildInfoRow('Account Verified', user.isVerified ? 'Yes' : 'No'),
              _buildInfoRow('Online Status', user.isOnline ? 'Online' : 'Offline'),
              _buildInfoRow('Last Seen', _formatDateTime(user.lastSeen)),
              _buildInfoRow('Created At', _formatDateTime(user.createdAt)),
              _buildInfoRow('Updated At', _formatDateTime(user.updatedAt)),
            ]),
            const SizedBox(height: 16),
            if (user.photos != null && user.photos!.isNotEmpty) ...[
              _buildSection('Photos', []),
              const SizedBox(height: 8),
              _buildPhotosGrid(user.photos!),
            ],
            const SizedBox(height: 32),
            _buildDangerZone(userData, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, Map<String, dynamic> userData) {
    final profilePhoto = userData[FirebaseConstants.fieldProfilePhoto];

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: profilePhoto != null && profilePhoto.toString().isNotEmpty
                ? NetworkImage(profilePhoto.toString())
                : null,
            child: profilePhoto == null || profilePhoto.toString().isEmpty
                ? Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 36, color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.fullName, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(user.email ?? 'No email', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatusSection(Map<String, dynamic> userData, UserManagementController controller) {
    final isVerified = userData[FirebaseConstants.fieldIsVerified] == true;
    final profileStatus = userData['profileStatus']?.toString() ?? 'pending';
    final role = userData[FirebaseConstants.fieldRole]?.toString() ?? 'user';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusChip(
          'Verification',
          isVerified ? 'Verified' : 'Pending',
          isVerified ? Colors.green : Colors.orange,
        ),
        _buildStatusChip(
          'Status',
          profileStatus.capitalizeFirst ?? profileStatus,
          _getStatusColor(profileStatus),
        ),
        _buildStatusChip(
          'Role',
          _formatRole(UserRole.fromString(role)),
          role == 'admin' || role == 'super_admin' ? Colors.purple : Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(List<String> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photos[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDangerZone(Map<String, dynamic> userData, UserManagementController controller) {
    final userId = userData['id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danger Zone', style: AppTextStyles.h4.copyWith(color: Colors.red)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              _buildDangerButton(
                'Suspend User',
                Icons.block,
                () => _confirmAction(
                  'Suspend User',
                  'Are you sure you want to suspend this user?',
                  () => controller.updateProfileStatus(userId, 'suspended'),
                ),
              ),
              const SizedBox(height: 8),
              _buildDangerButton(
                'Delete User Permanently',
                Icons.delete_forever,
                () => _confirmAction(
                  'Delete User',
                  'This action cannot be undone. Are you sure?',
                  () {
                    controller.deleteUser(userId);
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.red),
        label: Text(label, style: const TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems(Map<String, dynamic> userData) {
    final isVerified = userData[FirebaseConstants.fieldIsVerified] == true;
    final profileStatus = userData['profileStatus']?.toString() ?? 'pending';

    return [
      PopupMenuItem(
        value: 'verify',
        child: Row(
          children: [
            Icon(isVerified ? Icons.close : Icons.check, color: isVerified ? Colors.orange : Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(isVerified ? 'Revoke Verification' : 'Verify User'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text('Edit User'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'status_active',
        enabled: profileStatus != 'active',
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('Set Active'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'status_suspended',
        enabled: profileStatus != 'suspended',
        child: const Row(
          children: [
            Icon(Icons.block, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('Suspend User'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'change_role',
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, size: 20),
            SizedBox(width: 8),
            Text('Change Role'),
          ],
        ),
      ),
    ];
  }

  void _handleAction(String value, Map<String, dynamic> userData, UserManagementController controller) {
    final userId = userData['id'];
    final isVerified = userData[FirebaseConstants.fieldIsVerified] == true;

    switch (value) {
      case 'verify':
        controller.verifyUser(userId, !isVerified);
        break;
      case 'edit':
        Get.toNamed(AppRoutes.adminEditUser, arguments: userData);
        break;
      case 'status_active':
        controller.updateProfileStatus(userId, 'active');
        break;
      case 'status_suspended':
        controller.updateProfileStatus(userId, 'suspended');
        break;
      case 'change_role':
        _showRoleDialog(userId, userData[FirebaseConstants.fieldRole]?.toString() ?? 'user', controller);
        break;
    }
  }

  void _showRoleDialog(String userId, String currentRole, UserManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleOption('User', 'user', currentRole, () {
              controller.updateUserRole(userId, 'user');
              Get.back();
            }),
            _buildRoleOption('Admin', 'admin', currentRole, () {
              controller.updateUserRole(userId, 'admin');
              Get.back();
            }),
            _buildRoleOption('Super Admin', 'super_admin', currentRole, () {
              controller.updateUserRole(userId, 'super_admin');
              Get.back();
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String label, String value, String currentRole, VoidCallback onTap) {
    final isSelected = value == currentRole;
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: currentRole,
        onChanged: (_) => onTap(),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: isSelected ? null : onTap,
    );
  }

  void _confirmAction(String title, String message, VoidCallback onConfirm) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      default:
        return 'User';
    }
  }

  String _formatProfileStatus(ProfileStatus status) {
    switch (status) {
      case ProfileStatus.active:
        return 'Active';
      case ProfileStatus.suspended:
        return 'Suspended';
      case ProfileStatus.rejected:
        return 'Rejected';
      case ProfileStatus.deleted:
        return 'Deleted';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'deleted':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
