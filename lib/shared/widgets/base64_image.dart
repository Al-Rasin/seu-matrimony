import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../core/utils/image_utils.dart';

/// Widget to display base64 encoded images
class Base64Image extends StatelessWidget {
  final String? base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const Base64Image({
    super.key,
    this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (base64String == null || base64String!.isEmpty) {
      return _buildPlaceholder();
    }

    if (!ImageUtils.isValidBase64Image(base64String)) {
      return _buildError();
    }

    try {
      final bytes = ImageUtils.base64ToBytes(base64String!);

      Widget image = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );

      if (borderRadius != null) {
        image = ClipRRect(
          borderRadius: borderRadius!,
          child: image,
        );
      }

      return Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: image,
      );
    } catch (_) {
      return _buildError();
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.background,
            borderRadius: borderRadius,
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.iconSecondary,
              size: 32,
            ),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.background,
            borderRadius: borderRadius,
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.iconSecondary,
              size: 32,
            ),
          ),
        );
  }
}

/// Circular base64 image (for avatars)
class CircularBase64Image extends StatelessWidget {
  final String? base64String;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const CircularBase64Image({
    super.key,
    this.base64String,
    this.size = 48,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: Base64Image(
          base64String: base64String,
          width: size,
          height: size,
          fit: BoxFit.cover,
          backgroundColor: backgroundColor,
          placeholder: placeholder ?? _defaultPlaceholder(),
          errorWidget: errorWidget ?? _defaultPlaceholder(),
        ),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? AppColors.background,
      child: Icon(
        Icons.person,
        color: AppColors.iconSecondary,
        size: size * 0.5,
      ),
    );
  }
}

/// Base64 image with loading indicator
class Base64ImageWithLoading extends StatefulWidget {
  final String? base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const Base64ImageWithLoading({
    super.key,
    this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<Base64ImageWithLoading> createState() => _Base64ImageWithLoadingState();
}

class _Base64ImageWithLoadingState extends State<Base64ImageWithLoading> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(Base64ImageWithLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64String != widget.base64String) {
      _loadImage();
    }
  }

  void _loadImage() {
    if (widget.base64String == null || widget.base64String!.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulate async loading for large images
    Future.microtask(() {
      if (mounted) {
        final isValid = ImageUtils.isValidBase64Image(widget.base64String);
        setState(() {
          _isLoading = false;
          _hasError = !isValid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: widget.borderRadius,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: widget.borderRadius,
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.iconSecondary,
            size: 32,
          ),
        ),
      );
    }

    return Base64Image(
      base64String: widget.base64String,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      borderRadius: widget.borderRadius,
    );
  }
}

/// Gallery view for multiple base64 images
class Base64ImageGallery extends StatelessWidget {
  final List<String> images;
  final double itemHeight;
  final double spacing;
  final BorderRadius? borderRadius;
  final void Function(int index)? onImageTap;

  const Base64ImageGallery({
    super.key,
    required this.images,
    this.itemHeight = 200,
    this.spacing = 8,
    this.borderRadius,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => onImageTap?.call(0),
        child: Base64Image(
          base64String: images[0],
          height: itemHeight,
          width: double.infinity,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      );
    }

    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageTap?.call(index),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Base64Image(
                base64String: images[index],
                height: itemHeight,
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grid view for multiple base64 images
class Base64ImageGrid extends StatelessWidget {
  final List<String> images;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final BorderRadius? borderRadius;
  final void Function(int index)? onImageTap;
  final int? maxImages;

  const Base64ImageGrid({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    this.spacing = 8,
    this.childAspectRatio = 1,
    this.borderRadius,
    this.onImageTap,
    this.maxImages,
  });

  @override
  Widget build(BuildContext context) {
    final displayImages = maxImages != null && images.length > maxImages!
        ? images.take(maxImages!).toList()
        : images;
    final hasMore = maxImages != null && images.length > maxImages!;
    final moreCount = images.length - maxImages!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        final isLastWithMore = hasMore && index == displayImages.length - 1;

        return GestureDetector(
          onTap: () => onImageTap?.call(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Base64Image(
                base64String: displayImages[index],
                borderRadius: borderRadius ?? BorderRadius.circular(8),
              ),
              if (isLastWithMore)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$moreCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
