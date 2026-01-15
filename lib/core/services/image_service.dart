import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/// Service for handling image picking, compression, and base64 conversion
class ImageService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  /// Maximum file size in bytes (500KB for profile photos)
  static const int maxProfilePhotoSize = 500 * 1024;

  /// Maximum file size in bytes (1MB for ID documents)
  static const int maxIdDocumentSize = 1024 * 1024;

  /// Maximum file size in bytes (300KB for chat images)
  static const int maxChatImageSize = 300 * 1024;

  /// Pick image from gallery
  Future<File?> pickFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality ?? 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _showError('Failed to pick image from gallery');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickFromCamera({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality ?? 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _showError('Failed to capture image from camera');
      return null;
    }
  }

  /// Show image source picker dialog
  Future<File?> pickImage({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return pickFromCamera(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } else {
      return pickFromGallery(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality ?? 80,
        limit: limit,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      _showError('Failed to pick images');
      return [];
    }
  }

  /// Crop image with specified aspect ratio
  Future<File?> cropImage(
    File imageFile, {
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF00BF41),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: aspectRatio != null,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      _showError('Failed to crop image');
      return null;
    }
  }

  /// Pick and crop profile photo (square aspect ratio)
  Future<File?> pickProfilePhoto() async {
    final file = await pickImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (file == null) return null;

    return cropImage(
      file,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
  }

  /// Convert file to base64 string
  Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      _showError('Failed to convert image');
      return null;
    }
  }

  /// Convert bytes to base64 string
  String bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Decode base64 string to bytes
  Uint8List? base64ToBytes(String base64String) {
    try {
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      return base64Decode(cleanBase64);
    } catch (e) {
      return null;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Check if file size is within limit
  Future<bool> isFileSizeValid(File file, int maxSizeBytes) async {
    final size = await getFileSize(file);
    return size <= maxSizeBytes;
  }

  /// Get image dimensions
  Future<Size?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      return null;
    }
  }

  /// Get file extension
  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  bool isImageFile(File file) {
    final extension = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is a PDF
  bool isPdfFile(File file) {
    return getFileExtension(file) == 'pdf';
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
    );
  }
}
