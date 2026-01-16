import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../../../data/models/match_model.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/shimmer_widgets.dart';

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
              Text(
                'Welcome back,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const StatsGridShimmer();
      }
      return GridView.count(
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
      );
    });
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
      height: 200,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const HorizontalMatchesShimmer();
        }
        if (controller.recommendedMatches.isEmpty) {
          return const Center(child: Text('No recommendations yet'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.recommendedMatches.length,
          itemBuilder: (context, index) {
            final match = controller.recommendedMatches[index];
            return _buildMatchCard(match);
          },
        );
      }),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return GestureDetector(
      onTap: () => Get.toNamed('/profile-detail', arguments: {'matchId': match.id}),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.shade200,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: match.profilePhoto != null
                          ? Image.memory(
                              Uri.parse(match.profilePhoto!).data!.contentAsBytes(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                    // Online indicator
                    if (match.isOnline)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    // Verified badge
                    if (match.isVerified)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.fullName,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    match.shortInfo,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey.shade400,
      ),
    );
  }
}
