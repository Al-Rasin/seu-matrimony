import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

/// Generic empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final double iconSize;
  final bool showIcon;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.onAction,
    this.customIcon,
    this.iconSize = 80,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              customIcon ??
                  Icon(
                    icon ?? Icons.inbox_outlined,
                    size: iconSize,
                    color: AppColors.iconSecondary,
                  ),
              const SizedBox(height: 24),
            ],
            if (title != null)
              Text(
                title!,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && buttonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty matches state
class NoMatchesWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoMatchesWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border_rounded,
      title: 'No Matches Yet',
      message: 'Start exploring profiles to find your perfect match.',
      buttonText: 'Explore Profiles',
      onAction: onExplore,
    );
  }
}

/// Empty messages state
class NoMessagesWidget extends StatelessWidget {
  final VoidCallback? onStartChat;

  const NoMessagesWidget({
    super.key,
    this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No Messages',
      message: 'Start a conversation with your matches.',
      buttonText: 'Find Matches',
      onAction: onStartChat,
    );
  }
}

/// Empty notifications state
class NoNotificationsWidget extends StatelessWidget {
  const NoNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_rounded,
      title: 'No Notifications',
      message: 'You\'re all caught up! Check back later for updates.',
    );
  }
}

/// Empty search results state
class NoSearchResultsWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResultsWidget({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No results found for "$searchQuery". Try a different search term.'
          : 'No results found. Try adjusting your search criteria.',
      buttonText: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }
}

/// Empty interests state (sent/received)
class NoInterestsWidget extends StatelessWidget {
  final bool isSent;
  final VoidCallback? onExplore;

  const NoInterestsWidget({
    super.key,
    this.isSent = true,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: isSent ? Icons.send_outlined : Icons.inbox_outlined,
      title: isSent ? 'No Interests Sent' : 'No Interests Received',
      message: isSent
          ? 'Express interest in profiles you like.'
          : 'When someone expresses interest in you, it will appear here.',
      buttonText: isSent ? 'Browse Profiles' : null,
      onAction: isSent ? onExplore : null,
    );
  }
}

/// Empty photos state
class NoPhotosWidget extends StatelessWidget {
  final VoidCallback? onAddPhotos;

  const NoPhotosWidget({
    super.key,
    this.onAddPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.photo_library_outlined,
      title: 'No Photos',
      message: 'Add photos to make your profile more attractive.',
      buttonText: 'Add Photos',
      onAction: onAddPhotos,
    );
  }
}

/// Empty shortlisted profiles state
class NoShortlistedWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoShortlistedWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.bookmark_border_rounded,
      title: 'No Shortlisted Profiles',
      message: 'Save profiles you\'re interested in to view them later.',
      buttonText: 'Browse Profiles',
      onAction: onExplore,
    );
  }
}

/// Empty blocked users state
class NoBlockedUsersWidget extends StatelessWidget {
  const NoBlockedUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.block_rounded,
      title: 'No Blocked Users',
      message: 'Users you block will appear here.',
    );
  }
}

/// Empty data generic state
class NoDataWidget extends StatelessWidget {
  final String dataType;
  final VoidCallback? onRefresh;

  const NoDataWidget({
    super.key,
    required this.dataType,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.folder_open_outlined,
      title: 'No $dataType',
      message: 'There is no $dataType available at the moment.',
      buttonText: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }
}

/// Compact empty state for lists
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 48,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
