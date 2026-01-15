import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

/// Generic error display widget
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showIcon;
  final double iconSize;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.onRetry,
    this.showIcon = true,
    this.iconSize = 64,
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
              Icon(
                icon ?? Icons.error_outline,
                size: iconSize,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
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
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(buttonText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.wifi_off_rounded,
      title: 'No Internet Connection',
      message: message ?? 'Please check your internet connection and try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
    );
  }
}

/// Server error widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.cloud_off_rounded,
      title: 'Server Error',
      message: message ?? 'Something went wrong on our end. Please try again later.',
      buttonText: 'Retry',
      onRetry: onRetry,
    );
  }
}

/// Timeout error widget
class TimeoutErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const TimeoutErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.timer_off_rounded,
      title: 'Request Timeout',
      message: 'The request took too long. Please try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
    );
  }
}

/// Not found error widget
class NotFoundErrorWidget extends StatelessWidget {
  final String? itemName;
  final VoidCallback? onBack;

  const NotFoundErrorWidget({
    super.key,
    this.itemName,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.search_off_rounded,
      title: '${itemName ?? 'Item'} Not Found',
      message: 'The ${itemName?.toLowerCase() ?? 'item'} you are looking for does not exist.',
      buttonText: 'Go Back',
      onRetry: onBack,
    );
  }
}

/// Permission denied error widget
class PermissionDeniedWidget extends StatelessWidget {
  final String? permission;
  final VoidCallback? onSettings;

  const PermissionDeniedWidget({
    super.key,
    this.permission,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.lock_outline_rounded,
      title: 'Permission Required',
      message: permission != null
          ? '$permission permission is required to use this feature.'
          : 'This feature requires additional permissions.',
      buttonText: 'Open Settings',
      onRetry: onSettings,
    );
  }
}

/// Unauthorized error widget
class UnauthorizedWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const UnauthorizedWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.person_off_rounded,
      title: 'Session Expired',
      message: 'Your session has expired. Please login again to continue.',
      buttonText: 'Login',
      onRetry: onLogin,
    );
  }
}

/// Inline error message for forms and small areas
class InlineError extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const InlineError({
    super.key,
    required this.message,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// Error banner for top of screens
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error,
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textOnPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRetry,
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.textOnPrimary,
                  size: 20,
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  Icons.close,
                  color: AppColors.textOnPrimary,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
