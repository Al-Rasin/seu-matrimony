import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

/// Base custom card widget
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.elevation = 2,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05 * elevation),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

/// Profile card for displaying match profiles
class ProfileCard extends StatelessWidget {
  final String name;
  final String? age;
  final String? location;
  final String? occupation;
  final Widget? avatar;
  final bool isOnline;
  final bool isVerified;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const ProfileCard({
    super.key,
    required this.name,
    this.age,
    this.location,
    this.occupation,
    this.avatar,
    this.isOnline = false,
    this.isVerified = false,
    this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.background,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: avatar ??
                      const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.iconSecondary,
                      ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                if (age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    age!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.iconSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (occupation != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 14,
                        color: AppColors.iconSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          occupation!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onFavorite != null)
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? AppColors.error : AppColors.iconSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Stats card for dashboard
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info card with icon and text
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            const Icon(
              Icons.chevron_right,
              color: AppColors.iconSecondary,
            ),
        ],
      ),
    );
  }
}

/// Action card with button
class ActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final String buttonText;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? accentColor;

  const ActionCard({
    super.key,
    required this.title,
    this.description,
    required this.buttonText,
    this.icon,
    required this.onPressed,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return CustomCard(
      borderColor: color.withValues(alpha: 0.3),
      backgroundColor: color.withValues(alpha: 0.05),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: 40,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

/// Outlined card variant
class OutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const OutlinedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      margin: margin,
      borderColor: borderColor ?? AppColors.border,
      borderRadius: borderRadius,
      elevation: 0,
      backgroundColor: Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}
