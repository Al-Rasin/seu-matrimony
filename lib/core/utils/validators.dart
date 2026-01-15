/// Form field validators for input validation
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate password with strength requirements
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate confirm password matches
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number (Bangladesh format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    // Bangladesh phone: 01XXXXXXXXX (11 digits) or +8801XXXXXXXXX
    final phoneRegex = RegExp(r'^(\+?880)?1[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate username
  static String? username(String? value, {int minLength = 3, int maxLength = 20}) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Username must be less than $maxLength characters';
    }
    // Only alphanumeric and underscore
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validate full name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter your full name';
    }
    // Only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validate age
  static String? age(String? value, {int minAge = 18, int maxAge = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    if (age > maxAge) {
      return 'Please enter a valid age';
    }
    return null;
  }

  /// Validate height in cm
  static String? height(String? value, {int minHeight = 100, int maxHeight = 250}) {
    if (value == null || value.trim().isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }
    if (height < minHeight || height > maxHeight) {
      return 'Height must be between $minHeight and $maxHeight cm';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'This field'} must be less than $length characters';
    }
    return null;
  }

  /// Validate numeric value
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validate URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate SEU Student ID format
  static String? seuStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    // SEU ID format: YYYY-X-XX-XXX (e.g., 2020-1-60-001)
    final idRegex = RegExp(r'^\d{4}-\d-\d{2}-\d{3}$');
    if (!idRegex.hasMatch(value.trim())) {
      return 'Please enter a valid SEU Student ID (e.g., 2020-1-60-001)';
    }
    return null;
  }

  /// Validate dropdown selection
  static String? dropdownRequired(dynamic value, {String? fieldName}) {
    if (value == null) {
      return 'Please select ${fieldName ?? 'an option'}';
    }
    return null;
  }

  /// Validate bio/description text
  static String? bio(String? value, {int maxLength = 500}) {
    if (value != null && value.length > maxLength) {
      return 'Bio must be less than $maxLength characters';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
