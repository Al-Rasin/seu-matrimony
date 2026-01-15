import 'user_model.dart';

/// Login response model
class LoginResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final UserModel? user;

  const LoginResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      accessToken: json['access_token']?.toString() ?? json['accessToken']?.toString() ?? json['token']?.toString(),
      refreshToken: json['refresh_token']?.toString() ?? json['refreshToken']?.toString(),
      expiresIn: json['expires_in'] is int ? json['expires_in'] : int.tryParse(json['expires_in']?.toString() ?? ''),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'user': user?.toJson(),
    };
  }

  /// Check if login was successful with valid token
  bool get isValid => success && accessToken != null && accessToken!.isNotEmpty;

  /// Check if user needs to complete registration
  bool get needsRegistration => user?.profileCompletionPercentage != null && user!.profileCompletionPercentage < 100;

  @override
  String toString() => 'LoginResponse(success: $success, message: $message, hasToken: ${accessToken != null})';
}

/// Token refresh response
class RefreshTokenResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;

  const RefreshTokenResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] == true,
      accessToken: json['access_token']?.toString() ?? json['accessToken']?.toString() ?? json['token']?.toString(),
      refreshToken: json['refresh_token']?.toString() ?? json['refreshToken']?.toString(),
      expiresIn: json['expires_in'] is int ? json['expires_in'] : int.tryParse(json['expires_in']?.toString() ?? ''),
    );
  }

  bool get isValid => success && accessToken != null && accessToken!.isNotEmpty;
}
