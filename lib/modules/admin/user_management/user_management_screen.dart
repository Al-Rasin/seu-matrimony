import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_management_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/firebase_constants.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadUsers,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) => controller.selectedSort.value = value,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.newest,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: SortOption.oldest,
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Text('Name (Z-A)'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: [
            Obx(() => Tab(text: 'All (${controller.totalCount.value})')),
            Obx(() => Tab(text: 'Pending (${controller.pendingCount.value})')),
            Obx(() => Tab(text: 'Verified (${controller.verifiedCount.value})')),
            Obx(() => Tab(text: 'Active (${controller.activeCount.value})')),
            Obx(() => Tab(text: 'Suspended (${controller.suspendedCount.value})')),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return _buildUserCard(user, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(UserManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search by name, email, phone, student ID, or department',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: AppTextStyles.h4.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, UserManagementController controller) {
    final isVerified = user[FirebaseConstants.fieldIsVerified] == true;
    final profileStatus = user['profileStatus']?.toString() ?? 'pending';
    final role = user[FirebaseConstants.fieldRole]?.toString() ?? 'user';
    final fullName = user[FirebaseConstants.fieldFullName] ?? 'Unknown';
    final email = user[FirebaseConstants.fieldEmail] ?? 'No Email';
    final phone = user[FirebaseConstants.fieldPhone] ?? '';
    final profilePhoto = user[FirebaseConstants.fieldProfilePhoto];
    final department = user[FirebaseConstants.fieldDepartment] ?? '';
    final userId = user['id'];
    final profileCompletion = user[FirebaseConstants.fieldProfileCompletion] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.adminUserDetail, arguments: user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Photo
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withAlpha(25),
                backgroundImage: profilePhoto != null && profilePhoto.toString().isNotEmpty
                    ? NetworkImage(profilePhoto.toString())
                    : null,
                child: profilePhoto == null || profilePhoto.toString().isEmpty
                    ? Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: AppTextStyles.labelLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (role != 'user')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              role == 'super_admin' ? 'Super Admin' : 'Admin',
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppTextStyles.caption.copyWith(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty || department.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [if (phone.isNotEmpty) phone, if (department.isNotEmpty) department].join(' • '),
                        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade500, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusBadge(
                          isVerified ? 'Verified' : 'Pending',
                          isVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _buildStatusBadge(
                          profileStatus.capitalizeFirst ?? profileStatus,
                          _getStatusColor(profileStatus),
                        ),
                        const Spacer(),
                        Text(
                          '$profileCompletion%',
                          style: TextStyle(
                            color: profileCompletion >= 80 ? Colors.green : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action Menu
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, user, controller),
                itemBuilder: (context) => _buildMenuItems(user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(Map<String, dynamic> user) {
    final isVerified = user[FirebaseConstants.fieldIsVerified] == true;
    final profileStatus = user['profileStatus']?.toString() ?? 'pending';

    return [
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility, size: 20),
            SizedBox(width: 8),
            Text('View Details'),
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
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'verify',
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.close : Icons.check,
              color: isVerified ? Colors.orange : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(isVerified ? 'Revoke Verification' : 'Verify User'),
          ],
        ),
      ),
      if (profileStatus != 'active')
        const PopupMenuItem(
          value: 'activate',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Set Active'),
            ],
          ),
        ),
      if (profileStatus != 'suspended')
        const PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(Icons.block, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Suspend User'),
            ],
          ),
        ),
      const PopupMenuItem(
        value: 'role',
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, size: 20),
            SizedBox(width: 8),
            Text('Change Role'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Delete User', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  void _handleAction(String value, Map<String, dynamic> user, UserManagementController controller) {
    final userId = user['id'];
    final isVerified = user[FirebaseConstants.fieldIsVerified] == true;

    switch (value) {
      case 'view':
        Get.toNamed(AppRoutes.adminUserDetail, arguments: user);
        break;
      case 'edit':
        Get.toNamed(AppRoutes.adminEditUser, arguments: user);
        break;
      case 'verify':
        controller.verifyUser(userId, !isVerified);
        break;
      case 'activate':
        controller.updateProfileStatus(userId, 'active');
        break;
      case 'suspend':
        _confirmSuspend(userId, controller);
        break;
      case 'role':
        _showRoleDialog(userId, user[FirebaseConstants.fieldRole]?.toString() ?? 'user', controller);
        break;
      case 'delete':
        _confirmDelete(userId, controller);
        break;
    }
  }

  void _confirmSuspend(String userId, UserManagementController controller) {
    Get.defaultDialog(
      title: 'Suspend User',
      middleText: 'Are you sure you want to suspend this user? They will not be able to access their account.',
      textConfirm: 'Suspend',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back();
        controller.updateProfileStatus(userId, 'suspended');
      },
    );
  }

  void _confirmDelete(String userId, UserManagementController controller) {
    Get.defaultDialog(
      title: 'Delete User',
      middleText: 'Are you sure you want to delete this user? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteUser(userId);
      },
    );
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
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: isSelected ? null : onTap,
    );
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
