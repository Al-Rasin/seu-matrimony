import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

/// Custom app bar with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.bottom,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTextStyles.h4.copyWith(
                    color: foregroundColor ?? AppColors.textPrimary,
                  ),
                )
              : null),
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foregroundColor ?? AppColors.iconPrimary,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle ??
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Transparent app bar for screens with background images
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool useLightIcons;

  const TransparentAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.useLightIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = useLightIcons ? Colors.white : AppColors.iconPrimary;
    final textColor = useLightIcons ? Colors.white : AppColors.textPrimary;

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.h4.copyWith(color: textColor),
            )
          : null,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: iconColor,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: useLightIcons
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App bar with search functionality
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.iconPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: TextField(
        controller: controller,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: AppTextStyles.inputHint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: AppTextStyles.bodyMedium,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      actions: [
        if (controller?.text.isNotEmpty ?? false)
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.iconSecondary,
            ),
            onPressed: () {
              controller?.clear();
              onClear?.call();
            },
          ),
        ...?actions,
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App bar with tabs
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final TabController tabController;
  final List<Tab> tabs;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const TabbedAppBar({
    super.key,
    this.title,
    this.actions,
    required this.tabController,
    required this.tabs,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            )
          : null,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.iconPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      backgroundColor: AppColors.surface,
      elevation: 0,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

/// Sliver app bar for scrollable headers
class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.flexibleSpace,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.h4.copyWith(
                color: foregroundColor ?? AppColors.textPrimary,
              ),
            )
          : null,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: foregroundColor ?? AppColors.iconPrimary,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
}

/// Simple title app bar without back button
class SimpleTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SimpleTitleBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
      ),
      automaticallyImplyLeading: false,
      actions: actions,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
