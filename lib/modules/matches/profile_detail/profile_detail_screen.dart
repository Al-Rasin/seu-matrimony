import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_detail_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileDetailController());

    return Scaffold(
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.person, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showOptionsMenu(context, controller),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.profile['name'] ?? 'Unknown',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoItem(Icons.cake,
                                '${controller.profile['age'] ?? 0} yrs'),
                            _buildInfoItem(Icons.height,
                                '${controller.profile['height'] ?? 0} cm'),
                            _buildInfoItem(Icons.school,
                                controller.profile['education'] ?? 'N/A'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInterestSection(controller),
                        const SizedBox(height: 24),
                        _buildSection('About', controller.profile['bio'] ?? ''),
                        _buildSection('Basic Details', ''),
                        _buildSection('Professional Details', ''),
                      ],
                    ),
                  ),
                ),
              ],
            )),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.iconSecondary),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildInterestSection(ProfileDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interested with this profile?', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.sendInterest(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text('Yes, Interested'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.sendInterest(false),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 8),
        Text(
          content.isEmpty ? 'Not provided' : content,
          style: AppTextStyles.bodyMedium,
        ),
        const Divider(height: 32),
      ],
    );
  }

  void _showOptionsMenu(
      BuildContext context, ProfileDetailController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block User'),
            onTap: () {
              Navigator.pop(context);
              controller.blockUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report User'),
            onTap: () {
              Navigator.pop(context);
              controller.reportUser();
            },
          ),
        ],
      ),
    );
  }
}
