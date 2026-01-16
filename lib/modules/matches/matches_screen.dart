import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'matches_controller.dart';
import '../../data/models/match_model.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';

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
            padding: EdgeInsets.all(16.w),
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
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          // Filter tabs
          SizedBox(
            height: 40.h,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: MatchTab.values.map((tab) {
                    return _buildFilterTab(tab, controller);
                  }).toList(),
                )),
          ),

          SizedBox(height: 12.h),

          // Matches list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.matches.isEmpty) {
                return const LoadingWidget();
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.matches.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.matches.length) {
                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(
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
      padding: EdgeInsets.only(right: 8.w),
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
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => controller.viewProfile(match.id),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            Stack(
              children: [
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                  ),
                  child: match.profilePhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: Image.memory(
                            Uri.parse(match.profilePhoto!).data!.contentAsBytes(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),

                // Verified badge
                if (match.isVerified)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
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
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Shortlist button
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () => controller.toggleShortlist(match.id),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
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
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Profile info
            Padding(
              padding: EdgeInsets.all(16.w),
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
                  SizedBox(height: 8.h),

                  // Basic info row
                  Row(
                    children: [
                      if (match.age != null)
                        _buildInfoChip(Icons.cake, match.ageDisplay),
                      if (match.displayHeight != null) ...[
                        SizedBox(width: 12.w),
                        _buildInfoChip(Icons.height, match.displayHeight!),
                      ],
                      if (match.currentCity != null) ...[
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildInfoChip(
                            Icons.location_on,
                            match.currentCity!,
                            overflow: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),

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

                  SizedBox(height: 16.h),

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

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.person,
        size: 80.sp,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool overflow = false}) {
    final widget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.iconSecondary),
        SizedBox(width: 4.w),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 8.w),
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
            SizedBox(height: 8.h),
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
                SizedBox(width: 12.w),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: AppColors.success, size: 18.sp),
              SizedBox(width: 8.w),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.r),
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
            SizedBox(height: 8.h),
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
                SizedBox(width: 12.w),
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
