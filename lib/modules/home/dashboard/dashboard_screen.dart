import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEU Matrimony'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Obx(() => Text(
                    'Welcome back,',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )),
              Obx(() => Text(
                    controller.userName.value,
                    style: AppTextStyles.h3,
                  )),
              const SizedBox(height: 16),
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by criteria',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Profile completion card
              Obx(() => controller.profileCompletion.value < 100
                  ? _buildProfileCompletionCard(controller)
                  : const SizedBox.shrink()),
              const SizedBox(height: 20),
              // Stats grid
              _buildStatsGrid(controller),
              const SizedBox(height: 24),
              // Recommended matches
              Text('Recommended Matches', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              _buildRecommendedMatches(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your profile is incomplete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Complete now to get more matches',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Complete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardController controller) {
    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Profile Views',
              controller.profileViews.value.toString(),
              AppColors.profileViews,
              Icons.visibility,
            ),
            _buildStatCard(
              'Sent Interest',
              controller.sentInterests.value.toString(),
              AppColors.sentInterest,
              Icons.favorite,
            ),
            _buildStatCard(
              'Interest Received',
              controller.receivedInterests.value.toString(),
              AppColors.receivedInterest,
              Icons.favorite_border,
            ),
            _buildStatCard(
              'Profile Accepted',
              controller.acceptedProfiles.value.toString(),
              AppColors.acceptedProfile,
              Icons.check_circle,
            ),
          ],
        ));
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedMatches(DashboardController controller) {
    return SizedBox(
      height: 180,
      child: Obx(() => controller.recommendedMatches.isEmpty
          ? const Center(child: Text('No recommendations yet'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recommendedMatches.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Match ${index + 1}',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                );
              },
            )),
    );
  }
}
