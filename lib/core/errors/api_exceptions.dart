/// Custom exceptions for API error handling
library;

/// Base exception class for all API-related exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Thrown when there is no internet connection
class NetworkException extends ApiException {
  NetworkException({String? message}) : super(message: message ?? 'No internet connection. Please check your network.', statusCode: null);
}

/// Thrown when the request times out
class TimeoutException extends ApiException {
  TimeoutException({String? message}) : super(message: message ?? 'Request timed out. Please try again.', statusCode: 408);
}

/// Thrown when the server returns 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException({String? message, super.data}) : super(message: message ?? 'Invalid request. Please check your input.', statusCode: 400);
}

/// Thrown when the user is not authenticated (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message}) : super(message: message ?? 'Session expired. Please login again.', statusCode: 401);
}

/// Thrown when the user doesn't have permission (403)
class ForbiddenException extends ApiException {
  ForbiddenException({String? message}) : super(message: message ?? 'You do not have permission to access this resource.', statusCode: 403);
}

/// Thrown when the requested resource is not found (404)
class NotFoundException extends ApiException {
  NotFoundException({String? message}) : super(message: message ?? 'The requested resource was not found.', statusCode: 404);
}

/// Thrown when there's a conflict (409)
class ConflictException extends ApiException {
  ConflictException({String? message, super.data})
      : super(message: message ?? 'A conflict occurred. The resource may already exist.', statusCode: 409);
}

/// Thrown when validation fails (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(message: message ?? 'Validation failed. Please check your input.', statusCode: 422, data: errors);
}

/// Thrown when the server encounters an error (500)
class ServerException extends ApiException {
  ServerException({String? message}) : super(message: message ?? 'Server error. Please try again later.', statusCode: 500);
}

/// Thrown when the service is unavailable (503)
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException({String? message})
      : super(message: message ?? 'Service temporarily unavailable. Please try again later.', statusCode: 503);
}

/// Thrown for unknown/unexpected errors
class UnknownException extends ApiException {
  UnknownException({String? message, super.statusCode}) : super(message: message ?? 'An unexpected error occurred.');
}

/// Thrown when request is cancelled
class CancelledException extends ApiException {
  CancelledException({String? message}) : super(message: message ?? 'Request was cancelled.', statusCode: null);
}
