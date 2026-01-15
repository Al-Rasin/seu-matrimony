import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../network/api_response.dart';
import '../errors/api_exceptions.dart';

/// Base API service class providing common HTTP methods
/// All feature-specific API services should extend this class
abstract class ApiService extends GetxService {
  late final DioClient _dioClient;

  @override
  void onInit() {
    super.onInit();
    _dioClient = Get.find<DioClient>();
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.get(
        endpoint,
        queryParameters: queryParameters,
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(data, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// GET request with pagination support
  Future<PaginatedResponse<T>> getPaginated<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final params = {
        'page': page,
        'per_page': perPage,
        ...?queryParameters,
      };

      final response = await _dioClient.get(
        endpoint,
        queryParameters: params,
      );

      final responseData = response.data as Map<String, dynamic>;
      return PaginatedResponse.fromJson(responseData, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Upload file with multipart form data
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.uploadFile(
        endpoint,
        filePath: filePath,
        fileField: fileField,
        additionalData: additionalData,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJsonT: fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
