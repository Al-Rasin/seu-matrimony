import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_dashboard_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        await Get.find<AuthRepository>().logout();
                        Get.offAllNamed(AppRoutes.login);
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadStats,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Total Users',
                      controller.totalUsers.value.toString(),
                      Icons.people,
                      Colors.blue,
                      () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 0}),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Pending',
                      controller.pendingVerifications.value.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                      () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 1}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Reports',
                      controller.totalReports.value.toString(),
                      Icons.report_problem,
                      Colors.red,
                      () {
                        // Navigate to reports (if implemented)
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Management', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildActionTile(
                  'User Management',
                  'Verify users, block/unblock',
                  Icons.manage_accounts,
                  () {
                    Get.toNamed(AppRoutes.adminUserManagement);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.labelLarge),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
