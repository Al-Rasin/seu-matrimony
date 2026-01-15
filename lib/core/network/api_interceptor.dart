import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get Firebase ID token and add to headers
    try {
      final firebaseService = Get.find<FirebaseService>();
      final idToken = await firebaseService.getIdToken();

      if (idToken != null) {
        options.headers['Authorization'] = 'Bearer $idToken';
      }
    } catch (e) {
      // Firebase service not available yet, continue without token
    }

    // Add any additional headers if needed
    final storageService = Get.find<StorageService>();
    final accessToken = storageService.accessToken;

    if (accessToken != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh the Firebase token
        final firebaseService = Get.find<FirebaseService>();
        final newToken = await firebaseService.getIdToken(forceRefresh: true);

        if (newToken != null) {
          // Retry the request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final dio = Dio();
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        }
      } catch (e) {
        // Token refresh failed, logout user
        final storageService = Get.find<StorageService>();
        await storageService.clearAuthData();
        Get.offAllNamed('/login');
      }
    }

    // Handle other errors
    final errorMessage = _getErrorMessage(err);
    final customError = DioException(
      requestOptions: err.requestOptions,
      error: errorMessage,
      response: err.response,
      type: err.type,
    );

    return handler.next(customError);
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _handleBadResponse(Response? response) {
    if (response == null) {
      return 'Unknown error occurred.';
    }

    switch (response.statusCode) {
      case 400:
        final data = response.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This action cannot be completed.';
      case 422:
        final data = response.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Error occurred. Status code: ${response.statusCode}';
    }
  }
}
