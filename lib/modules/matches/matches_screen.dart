import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'matches_controller.dart';
import '../../data/models/match_model.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/shimmer_widgets.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() {
            final hasFilters = controller.currentFilter.value.hasActiveFilters;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: controller.openFilters,
                ),
                if (hasFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, city, occupation...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          // Filter tabs
          SizedBox(
            height: 40,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: MatchTab.values.map((tab) {
                    return _buildFilterTab(tab, controller);
                  }).toList(),
                )),
          ),

          const SizedBox(height: 12),

          // Matches list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.matches.isEmpty) {
                return const MatchesListShimmer();
              }

              if (controller.hasError.value && controller.matches.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  message: controller.errorMessage.value,
                  buttonText: 'Retry',
                  onAction: controller.refreshMatches,
                );
              }

              if (controller.matches.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'No matches found',
                  message: _getEmptyMessage(controller.selectedTab.value),
                  buttonText: controller.currentFilter.value.hasActiveFilters
                      ? 'Clear Filters'
                      : null,
                  onAction: controller.currentFilter.value.hasActiveFilters
                      ? controller.clearFilters
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshMatches,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.matches.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.matches.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildMatchCard(
                      controller.matches[index],
                      controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(MatchTab tab, MatchesController controller) {
    final isSelected = controller.selectedTab.value == tab;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(controller.getTabName(tab)),
        selected: isSelected,
        onSelected: (_) => controller.selectTab(tab),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match, MatchesController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => controller.viewProfile(match.id),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: match.profilePhoto != null && match.profilePhoto!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: _buildProfileImage(match.profilePhoto!),
                        )
                      : _buildPlaceholderImage(),
                ),

                // Verified badge
                if (match.isVerified)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Online indicator
                if (match.isOnline)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Shortlist button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => controller.toggleShortlist(match.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        match.isShortlisted
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: match.isShortlisted
                            ? AppColors.primary
                            : AppColors.iconSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Profile info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    match.fullName,
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Basic info row
                  Row(
                    children: [
                      if (match.age != null)
                        _buildInfoChip(Icons.cake, match.ageDisplay),
                      if (match.displayHeight != null) ...[
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.height, match.displayHeight!),
                      ],
                      if (match.currentCity != null) ...[
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.location_on,
                          match.currentCity!,
                          overflow: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Education & Job
                  if (match.educationJobLine.isNotEmpty)
                    Text(
                      match.educationJobLine,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Interest action buttons
                  _buildInterestButtons(match, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String photoUrl) {
    // Check if it's a data URI (base64) or a network URL
    if (photoUrl.startsWith('data:')) {
      try {
        final uri = Uri.parse(photoUrl);
        if (uri.data != null) {
          return Image.memory(
            uri.data!.contentAsBytes(),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
          );
        }
      } catch (e) {
        return _buildPlaceholderImage();
      }
    }

    // Network URL
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool overflow = false}) {
    final widget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.iconSecondary),
        const SizedBox(width: 4),
        overflow
            ? Flexible(
                child: Text(
                  text,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(text, style: AppTextStyles.caption),
      ],
    );

    return overflow ? Expanded(child: widget) : widget;
  }

  Widget _buildInterestButtons(MatchModel match, MatchesController controller) {
    // Show different buttons based on interest status
    switch (match.interestStatus) {
      case InterestStatus.sent:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Interest Sent',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case InterestStatus.received:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interested in you!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptInterest(match.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.rejectInterest(match.id),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        );

      case InterestStatus.accepted:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Connected',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case InterestStatus.rejected:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Not interested',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        );

      case InterestStatus.none:
      case null:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interested with this profile?',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.sendInterest(match.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                    child: const Text('Yes, Interested'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.skipMatch(match.id),
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  String _getEmptyMessage(MatchTab tab) {
    switch (tab) {
      case MatchTab.all:
        return 'No matches found. Try adjusting your filters.';
      case MatchTab.matchPreference:
        return 'No recommended matches yet. Complete your profile for better suggestions.';
      case MatchTab.saved:
        return 'You haven\'t saved any profiles yet.';
      case MatchTab.sentInterests:
        return 'You haven\'t sent any interests yet.';
      case MatchTab.receivedInterests:
        return 'No interests received yet.';
    }
  }
}
