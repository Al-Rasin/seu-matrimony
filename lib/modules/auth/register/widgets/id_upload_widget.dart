import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../core/services/image_service.dart';

/// Widget for uploading SEU ID document during registration
class IdUploadWidget extends StatelessWidget {
  final String? imageBase64;
  final File? imageFile;
  final ValueChanged<String>? onImageSelected;
  final ValueChanged<File>? onFileSelected;
  final VoidCallback? onRemove;
  final String label;
  final String hint;
  final bool isRequired;
  final String? errorText;

  const IdUploadWidget({
    super.key,
    this.imageBase64,
    this.imageFile,
    this.onImageSelected,
    this.onFileSelected,
    this.onRemove,
    this.label = 'SEU ID Card',
    this.hint = 'Upload a clear photo of your SEU ID card',
    this.isRequired = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBase64 != null || imageFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Upload area
        GestureDetector(
          onTap: hasImage ? null : _showPickerOptions,
          child: Container(
            width: double.infinity,
            height: hasImage ? null : 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasImage ? AppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : hasImage
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                width: errorText != null ? 1.5 : 1,
              ),
            ),
            child: hasImage ? _buildPreview() : _buildPlaceholder(),
          ),
        ),
        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        // Hint text
        if (errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            hint,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.badge_outlined,
            size: 30,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to upload ID',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG (Max 5MB)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageFile != null
              ? Image.file(
                  imageFile!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : imageBase64 != null
                  ? _buildBase64Image()
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _showPickerOptions,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Change'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBase64Image() {
    // Decode base64 and display
    try {
      final bytes = Uri.parse('data:image/png;base64,$imageBase64').data?.contentAsBytes();
      if (bytes != null) {
        return Image.memory(
          bytes,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      // Fallback for invalid base64
    }
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.surface,
      child: Center(
        child: Icon(Icons.image, size: 50, color: AppColors.textHint),
      ),
    );
  }

  void _showPickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              'Upload SEU ID',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to upload your ID',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(fromCamera: true),
                ),
                _buildPickerOption(
                  icon: Icons.photo_library,
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

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    Get.back();

    final imageService = Get.find<ImageService>();
    final file = fromCamera
        ? await imageService.pickFromCamera()
        : await imageService.pickFromGallery();

    if (file == null) return;

    // Notify with file
    onFileSelected?.call(file);

    // Convert to base64 and notify
    final base64 = await imageService.fileToBase64(file);
    if (base64 != null) {
      onImageSelected?.call(base64);
    }
  }
}
