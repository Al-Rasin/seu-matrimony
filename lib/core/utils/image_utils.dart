import 'dart:convert';
import 'dart:typed_data';

/// Image utility functions for base64 conversion and image handling
class ImageUtils {
  ImageUtils._();

  /// Convert bytes to base64 string
  static String bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Convert base64 string to bytes
  static Uint8List base64ToBytes(String base64String) {
    // Remove data URL prefix if present
    final cleanBase64 = removeDataUrlPrefix(base64String);
    return base64Decode(cleanBase64);
  }

  /// Create a data URL from base64 string
  /// Format: data:image/[type];base64,[data]
  static String toDataUrl(String base64String, {String mimeType = 'image/jpeg'}) {
    final cleanBase64 = removeDataUrlPrefix(base64String);
    return 'data:$mimeType;base64,$cleanBase64';
  }

  /// Remove data URL prefix from base64 string
  static String removeDataUrlPrefix(String dataUrl) {
    if (dataUrl.contains(',')) {
      return dataUrl.split(',').last;
    }
    return dataUrl;
  }

  /// Check if string is a valid base64 encoded image
  static bool isValidBase64Image(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      final cleanBase64 = removeDataUrlPrefix(value);
      base64Decode(cleanBase64);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get image mime type from base64 data URL
  static String? getMimeTypeFromDataUrl(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return null;
    final mimeMatch = RegExp(r'data:([^;]+);').firstMatch(dataUrl);
    return mimeMatch?.group(1);
  }

  /// Get file extension from mime type
  static String getExtensionFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      case 'image/bmp':
        return 'bmp';
      case 'image/svg+xml':
        return 'svg';
      default:
        return 'jpg';
    }
  }

  /// Get mime type from file extension
  static String getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase().replaceAll('.', '')) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }

  /// Estimate file size from base64 string (in bytes)
  static int estimateFileSizeFromBase64(String base64String) {
    final cleanBase64 = removeDataUrlPrefix(base64String);
    // Base64 encoding increases size by ~33%
    // Formula: (base64Length * 3) / 4 - padding
    final padding = cleanBase64.endsWith('==')
        ? 2
        : cleanBase64.endsWith('=')
            ? 1
            : 0;
    return ((cleanBase64.length * 3) ~/ 4) - padding;
  }

  /// Check if image size is within limit
  static bool isWithinSizeLimit(String base64String, int maxSizeInBytes) {
    final size = estimateFileSizeFromBase64(base64String);
    return size <= maxSizeInBytes;
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Detect image type from bytes (magic bytes)
  static String? detectImageType(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return 'image/gif';
    }

    // WebP: 52 49 46 46 ... 57 45 42 50
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'image/bmp';
    }

    return null;
  }

  /// Detect image type from base64 string
  static String? detectImageTypeFromBase64(String base64String) {
    try {
      final bytes = base64ToBytes(base64String);
      return detectImageType(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Create placeholder image data URL (1x1 transparent PNG)
  static String get transparentPixelDataUrl {
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
  }

  /// Create a solid color placeholder (1x1 pixel)
  static String createColorPlaceholder(int r, int g, int b) {
    // Simple 1x1 PNG with specified color
    final bytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, // IHDR length
      0x49, 0x48, 0x44, 0x52, // IHDR
      0x00, 0x00, 0x00, 0x01, // width = 1
      0x00, 0x00, 0x00, 0x01, // height = 1
      0x08, 0x02, // bit depth = 8, color type = 2 (RGB)
      0x00, 0x00, 0x00, // compression, filter, interlace
      0x90, 0x77, 0x53, 0xDE, // CRC
      0x00, 0x00, 0x00, 0x0C, // IDAT length
      0x49, 0x44, 0x41, 0x54, // IDAT
      0x08, 0xD7, 0x63, r, g, b, 0x00, 0x00, // compressed pixel data
      0x00, 0x00, 0x00, 0x00, // placeholder CRC
      0x00, 0x00, 0x00, 0x00, // IEND length
      0x49, 0x45, 0x4E, 0x44, // IEND
      0xAE, 0x42, 0x60, 0x82, // CRC
    ]);
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }

  /// Max image sizes for different use cases (in bytes)
  static const int maxProfilePhotoSize = 5 * 1024 * 1024; // 5 MB
  static const int maxGalleryImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxThumbnailSize = 500 * 1024; // 500 KB
}
