import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../core/services/image_service.dart';
import 'base64_image.dart';

/// Image picker widget with preview
class ImagePickerWidget extends StatelessWidget {
  final String? currentImage;
  final void Function(String base64Image)? onImagePicked;
  final void Function()? onImageRemoved;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final String? label;
  final String? hint;
  final bool showRemoveButton;
  final bool cropEnabled;

  const ImagePickerWidget({
    super.key,
    this.currentImage,
    this.onImagePicked,
    this.onImageRemoved,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius,
    this.label,
    this.hint,
    this.showRemoveButton = true,
    this.cropEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _showPickerOptions,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: currentImage != null && currentImage!.isNotEmpty
                ? _buildImagePreview()
                : _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Base64Image(
            base64String: currentImage,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                onTap: _showPickerOptions,
              ),
              if (showRemoveButton && onImageRemoved != null) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete,
                  onTap: onImageRemoved,
                  color: AppColors.error,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: AppColors.iconSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          hint ?? 'Tap to add photo',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      _ImagePickerBottomSheet(
        onImagePicked: onImagePicked,
        cropEnabled: cropEnabled,
      ),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

/// Bottom sheet for image picker options
class _ImagePickerBottomSheet extends StatelessWidget {
  final void Function(String base64Image)? onImagePicked;
  final bool cropEnabled;

  const _ImagePickerBottomSheet({
    this.onImagePicked,
    this.cropEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Photo',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(fromCamera: true),
                ),
                _PickerOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(fromCamera: false),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    Get.back();

    final imageService = Get.find<ImageService>();

    // Pick the image file
    final file = fromCamera
        ? await imageService.pickFromCamera()
        : await imageService.pickFromGallery();

    if (file == null) return;

    // Optionally crop the image
    final finalFile = cropEnabled
        ? await imageService.cropImage(file)
        : file;

    if (finalFile == null) return;

    // Convert to base64
    final base64 = await imageService.fileToBase64(finalFile);

    if (base64 != null) {
      onImagePicked?.call(base64);
    }
  }
}

/// Picker option button
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multi-image picker widget
class MultiImagePickerWidget extends StatelessWidget {
  final List<String> images;
  final void Function(List<String> images)? onImagesChanged;
  final int maxImages;
  final double itemSize;
  final String? label;

  const MultiImagePickerWidget({
    super.key,
    required this.images,
    this.onImagesChanged,
    this.maxImages = 6,
    this.itemSize = 100,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppTextStyles.inputLabel),
              Text(
                '${images.length}/$maxImages',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...images.asMap().entries.map((entry) {
              return _ImageTile(
                base64Image: entry.value,
                size: itemSize,
                onRemove: () => _removeImage(entry.key),
              );
            }),
            if (images.length < maxImages)
              _AddImageTile(
                size: itemSize,
                onTap: _showPickerOptions,
              ),
          ],
        ),
      ],
    );
  }

  void _removeImage(int index) {
    final newImages = List<String>.from(images);
    newImages.removeAt(index);
    onImagesChanged?.call(newImages);
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      _ImagePickerBottomSheet(
        onImagePicked: (base64) {
          if (images.length < maxImages) {
            final newImages = List<String>.from(images);
            newImages.add(base64);
            onImagesChanged?.call(newImages);
          }
        },
        cropEnabled: true,
      ),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

/// Image tile for multi-picker
class _ImageTile extends StatelessWidget {
  final String base64Image;
  final double size;
  final VoidCallback? onRemove;

  const _ImageTile({
    required this.base64Image,
    required this.size,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Base64Image(
              base64String: base64Image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Add image tile button
class _AddImageTile extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _AddImageTile({
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.iconSecondary,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile photo picker (circular)
class ProfilePhotoPicker extends StatelessWidget {
  final String? currentImage;
  final void Function(String base64Image)? onImagePicked;
  final double size;
  final bool showEditIcon;

  const ProfilePhotoPicker({
    super.key,
    this.currentImage,
    this.onImagePicked,
    this.size = 120,
    this.showEditIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Stack(
        children: [
          CircularBase64Image(
            base64String: currentImage,
            size: size,
            borderWidth: 3,
            borderColor: AppColors.primary,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
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
        ],
      ),
    );
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      _ImagePickerBottomSheet(
        onImagePicked: onImagePicked,
        cropEnabled: true,
      ),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
