import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import 'base64_image.dart';

/// Avatar widget for displaying profile pictures
class AvatarWidget extends StatelessWidget {
  final String? imageBase64;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showOnlineIndicator;
  final bool isOnline;
  final bool showVerifiedBadge;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageBase64,
    this.name,
    this.size = 48,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.showVerifiedBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          _buildAvatar(),
          if (showOnlineIndicator) _buildOnlineIndicator(),
          if (showVerifiedBadge) _buildVerifiedBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? AppColors.primary,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(
          child: Base64Image(
            base64String: imageBase64,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback to initials avatar
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = name != null ? Helpers.getInitials(name!) : '?';
    final bgColor = backgroundColor ??
        (name != null ? Helpers.getColorFromString(name!) : AppColors.primary);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    final indicatorSize = size * 0.25;
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: indicatorSize,
        height: indicatorSize,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.success : AppColors.textHint,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    final badgeSize = size * 0.3;
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.verified,
          color: AppColors.primary,
          size: badgeSize,
        ),
      ),
    );
  }
}

/// Avatar with name and subtitle
class AvatarWithInfo extends StatelessWidget {
  final String? imageBase64;
  final String name;
  final String? subtitle;
  final double avatarSize;
  final bool showOnlineIndicator;
  final bool isOnline;
  final bool showVerifiedBadge;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AvatarWithInfo({
    super.key,
    this.imageBase64,
    required this.name,
    this.subtitle,
    this.avatarSize = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.showVerifiedBadge = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            AvatarWidget(
              imageBase64: imageBase64,
              name: name,
              size: avatarSize,
              showOnlineIndicator: showOnlineIndicator,
              isOnline: isOnline,
              showVerifiedBadge: showVerifiedBadge,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Stacked avatars for group display
class StackedAvatars extends StatelessWidget {
  final List<AvatarData> avatars;
  final double avatarSize;
  final double overlap;
  final int maxDisplay;
  final VoidCallback? onTap;

  const StackedAvatars({
    super.key,
    required this.avatars,
    this.avatarSize = 32,
    this.overlap = 0.3,
    this.maxDisplay = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayAvatars = avatars.take(maxDisplay).toList();
    final remaining = avatars.length - maxDisplay;
    final overlapPx = avatarSize * overlap;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: avatarSize,
        width: avatarSize +
            (displayAvatars.length - 1) * (avatarSize - overlapPx) +
            (remaining > 0 ? avatarSize - overlapPx : 0),
        child: Stack(
          children: [
            ...displayAvatars.asMap().entries.map((entry) {
              return Positioned(
                left: entry.key * (avatarSize - overlapPx),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: AvatarWidget(
                    imageBase64: entry.value.imageBase64,
                    name: entry.value.name,
                    size: avatarSize - 4,
                  ),
                ),
              );
            }),
            if (remaining > 0)
              Positioned(
                left: displayAvatars.length * (avatarSize - overlapPx),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: avatarSize * 0.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Avatar data model
class AvatarData {
  final String? imageBase64;
  final String? name;

  const AvatarData({
    this.imageBase64,
    this.name,
  });
}

/// Large profile avatar with edit option
class ProfileAvatar extends StatelessWidget {
  final String? imageBase64;
  final String? name;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditTap;
  final bool showVerifiedBadge;

  const ProfileAvatar({
    super.key,
    this.imageBase64,
    this.name,
    this.size = 120,
    this.showEditButton = false,
    this.onEditTap,
    this.showVerifiedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarWidget(
          imageBase64: imageBase64,
          name: name,
          size: size,
          borderWidth: 4,
          borderColor: AppColors.primary,
          showVerifiedBadge: showVerifiedBadge,
        ),
        if (showEditButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small avatar badge (for notifications, messages)
class AvatarBadge extends StatelessWidget {
  final String? imageBase64;
  final String? name;
  final int badgeCount;
  final double avatarSize;

  const AvatarBadge({
    super.key,
    this.imageBase64,
    this.name,
    this.badgeCount = 0,
    this.avatarSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AvatarWidget(
          imageBase64: imageBase64,
          name: name,
          size: avatarSize,
        ),
        if (badgeCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
