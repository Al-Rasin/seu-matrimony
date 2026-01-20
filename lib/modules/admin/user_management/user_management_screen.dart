import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_management_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/firebase_constants.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Verified'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserCard(user, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, UserManagementController controller) {
    final isVerified = user[FirebaseConstants.fieldIsVerified] == true;
    final fullName = user[FirebaseConstants.fieldFullName] ?? 'Unknown';
    final email = user[FirebaseConstants.fieldEmail] ?? 'No Email';
    final userId = user['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(fullName, style: AppTextStyles.labelLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Text(
                isVerified ? 'Verified' : 'Pending',
                style: TextStyle(
                  color: isVerified ? Colors.green.shade800 : Colors.orange.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'verify') {
              controller.verifyUser(userId, !isVerified);
            } else if (value == 'delete') {
              _confirmDelete(userId, controller);
            }
          },
          itemBuilder: (context) => [
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
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text('Delete User', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
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
}
