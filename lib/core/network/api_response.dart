/// Standard API response model for consistent response handling
library;

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final PaginationMeta? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
    this.pagination,
  });

  /// Create from JSON response
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] ?? json['status'] == 'success',
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: json['statusCode'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }

  /// Create a success response
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    PaginationMeta? pagination,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
      pagination: pagination,
    );
  }

  /// Create an error response
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Check if response has pagination
  bool get hasPagination => pagination != null;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

/// Pagination metadata for list responses
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final currentPage = json['currentPage'] ?? json['current_page'] ?? 1;
    final lastPage = json['lastPage'] ?? json['last_page'] ?? 1;

    return PaginationMeta(
      currentPage: currentPage as int,
      lastPage: lastPage as int,
      perPage: (json['perPage'] ?? json['per_page'] ?? 10) as int,
      total: (json['total'] ?? 0) as int,
      hasMorePages: json['hasMorePages'] ?? json['has_more_pages'] ?? currentPage < lastPage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'lastPage': lastPage,
      'perPage': perPage,
      'total': total,
      'hasMorePages': hasMorePages,
    };
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$lastPage, total: $total)';
  }
}

/// List response with pagination support
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    return PaginatedResponse<T>(
      items: dataList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      pagination: PaginationMeta.fromJson(json['pagination'] ?? json['meta'] ?? {}),
    );
  }

  /// Check if there are more pages to load
  bool get hasMore => pagination.hasMorePages;

  /// Check if this is the first page
  bool get isFirstPage => pagination.currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => pagination.currentPage >= pagination.lastPage;

  /// Check if the list is empty
  bool get isEmpty => items.isEmpty;

  /// Check if the list is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Get the count of items
  int get count => items.length;
}
