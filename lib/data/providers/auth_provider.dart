import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/network/api_response.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

/// Auth provider for handling authentication API calls
class AuthProvider extends ApiService {
  /// Login with username and password
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    return post<LoginResponse>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Register new user
  Future<ApiResponse<LoginResponse>> register(RegisterRequest request) async {
    return post<LoginResponse>(
      ApiConstants.register,
      data: request.toJson(),
      fromJson: (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Complete profile (multi-step registration)
  Future<ApiResponse<UserModel>> completeProfile(ProfileCompletionRequest request) async {
    return post<UserModel>(
      ApiConstants.completeProfile,
      data: request.toJson(),
      fromJson: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update profile step
  Future<ApiResponse<UserModel>> updateProfileStep(
    int step,
    Map<String, dynamic> data,
  ) async {
    return patch<UserModel>(
      '${ApiConstants.completeProfile}/$step',
      data: data,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Forgot password - send reset link/OTP
  Future<ApiResponse<void>> forgotPassword(String emailOrPhone) async {
    return post(
      ApiConstants.forgotPassword,
      data: {'email_or_phone': emailOrPhone},
    );
  }

  /// Reset password with OTP/token
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  /// Verify OTP
  Future<ApiResponse<void>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return post(
      ApiConstants.verifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
  }

  /// Resend OTP
  Future<ApiResponse<void>> resendOtp(String phone) async {
    return post(
      ApiConstants.resendOtp,
      data: {'phone': phone},
    );
  }

  /// Refresh access token
  Future<ApiResponse<RefreshTokenResponse>> refreshToken(String refreshToken) async {
    return post<RefreshTokenResponse>(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
      fromJson: (data) => RefreshTokenResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    return post(ApiConstants.logout);
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    return get<UserModel>(
      ApiConstants.profile,
      fromJson: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    return patch<UserModel>(
      ApiConstants.profile,
      data: data,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Upload profile photo
  Future<ApiResponse<UserModel>> uploadProfilePhoto(String base64Image) async {
    return post<UserModel>(
      ApiConstants.uploadProfilePhoto,
      data: {'profile_photo': base64Image},
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Upload SEU ID for verification
  Future<ApiResponse<void>> uploadSeuId(String base64Image) async {
    return post(
      ApiConstants.uploadSeuId,
      data: {'seu_id_image': base64Image},
    );
  }

  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return post(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  /// Delete account
  Future<ApiResponse<void>> deleteAccount(String password) async {
    return delete(
      ApiConstants.deleteAccount,
      data: {'password': password},
    );
  }

  /// Check if username is available
  Future<ApiResponse<bool>> checkUsername(String username) async {
    return get<bool>(
      '${ApiConstants.checkUsername}/$username',
      fromJson: (data) => data['available'] == true,
    );
  }

  /// Check if phone is available
  Future<ApiResponse<bool>> checkPhone(String phone) async {
    return get<bool>(
      '${ApiConstants.checkPhone}/$phone',
      fromJson: (data) => data['available'] == true,
    );
  }
}
