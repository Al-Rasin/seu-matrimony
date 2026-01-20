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
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadStats,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
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
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildUserStatsSection(),
                const SizedBox(height: 24),
                _buildActivitySection(),
                const SizedBox(height: 24),
                _buildOtherStatsSection(),
                const SizedBox(height: 24),
                _buildManagementSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Maintenance Mode',
                controller.maintenanceMode.value ? 'ON' : 'OFF',
                Icons.power_settings_new,
                controller.maintenanceMode.value ? Colors.red : Colors.green,
                onTap: () => _showMaintenanceDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Pending Reports',
                controller.pendingReports.value.toString(),
                Icons.report_problem,
                controller.pendingReports.value > 0 ? Colors.orange : Colors.green,
                onTap: () => Get.toNamed(AppRoutes.adminReports),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(75)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.caption),
                  Text(
                    value,
                    style: AppTextStyles.h4.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('User Statistics', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Users',
              controller.totalUsers.value.toString(),
              Icons.people,
              Colors.blue,
              onTap: () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 0}),
            ),
            _buildStatCard(
              'Pending Verification',
              controller.pendingVerifications.value.toString(),
              Icons.pending_actions,
              Colors.orange,
              onTap: () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 1}),
            ),
            _buildStatCard(
              'Verified Users',
              controller.verifiedUsers.value.toString(),
              Icons.verified_user,
              Colors.green,
              onTap: () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 2}),
            ),
            _buildStatCard(
              'Suspended Users',
              controller.suspendedUsers.value.toString(),
              Icons.block,
              Colors.red,
              onTap: () => Get.toNamed(AppRoutes.adminUserManagement, arguments: {'initialIndex': 4}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Registrations', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildActivityItem(
                  'Today',
                  controller.newUsersToday.value.toString(),
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildActivityItem(
                  'This Week',
                  controller.newUsersThisWeek.value.toString(),
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildActivityItem(
                  'This Month',
                  controller.newUsersThisMonth.value.toString(),
                  Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildOtherStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Platform Activity', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'Reports',
                controller.totalReports.value.toString(),
                Icons.report,
                Colors.red,
                onTap: () => Get.toNamed(AppRoutes.adminReports),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStatCard(
                'Conversations',
                controller.totalConversations.value.toString(),
                Icons.chat_bubble,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStatCard(
                'Interests',
                controller.totalInterests.value.toString(),
                Icons.favorite,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h4.copyWith(color: color)),
            Text(title, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Management', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        _buildActionTile(
          'User Management',
          'Manage users, verify profiles, change roles',
          Icons.manage_accounts,
          () => Get.toNamed(AppRoutes.adminUserManagement),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Reports',
          'Review and resolve user reports',
          Icons.report_problem,
          () => Get.toNamed(AppRoutes.adminReports),
          badge: controller.pendingReports.value > 0 ? controller.pendingReports.value.toString() : null,
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'App Settings',
          'Configure app settings and features',
          Icons.settings,
          () => Get.toNamed(AppRoutes.adminAppSettings),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    String? badge,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(25),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.labelLarge),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showMaintenanceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Maintenance Mode'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.maintenanceMode.value
                  ? 'Maintenance mode is currently ON. Users cannot access the app.'
                  : 'Maintenance mode is currently OFF. App is accessible to all users.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(controller.maintenanceMode.value ? 'Turn OFF' : 'Turn ON'),
              value: controller.maintenanceMode.value,
              onChanged: (value) {
                controller.toggleMaintenanceMode(value);
              },
              activeColor: Colors.red,
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
  }
}
