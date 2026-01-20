/// Paginated response model for list queries
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
  bool get hasMore => pagination.hasMorePages;
}

/// Pagination metadata


  
class PaginationMeta {

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;



  factory PaginationMeta.empty() {
    return PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 0,
      hasMorePages: false,
    );
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      lastPage: json['last_page'] ?? json['lastPage'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? 10,
      total: json['total'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? json['hasMorePages'] ?? false,
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
}
