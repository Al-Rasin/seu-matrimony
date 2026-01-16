/// Match filter model for filtering potential matches
class MatchFilter {
  final int? minAge;
  final int? maxAge;
  final double? minHeight;
  final double? maxHeight;
  final String? religion;
  final String? maritalStatus;
  final String? education;
  final String? city;
  final String? occupation;
  final String? department;
  final bool? verifiedOnly;
  final bool? withPhotoOnly;
  final bool? onlineOnly;

  const MatchFilter({
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
    this.religion,
    this.maritalStatus,
    this.education,
    this.city,
    this.occupation,
    this.department,
    this.verifiedOnly,
    this.withPhotoOnly,
    this.onlineOnly,
  });

  /// Convert to query parameters for API
  Map<String, dynamic> toQueryParams() {
    return {
      if (minAge != null) 'min_age': minAge,
      if (maxAge != null) 'max_age': maxAge,
      if (minHeight != null) 'min_height': minHeight,
      if (maxHeight != null) 'max_height': maxHeight,
      if (religion != null && religion!.isNotEmpty) 'religion': religion,
      if (maritalStatus != null && maritalStatus!.isNotEmpty) 'marital_status': maritalStatus,
      if (education != null && education!.isNotEmpty) 'education': education,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (occupation != null && occupation!.isNotEmpty) 'occupation': occupation,
      if (department != null && department!.isNotEmpty) 'department': department,
      if (verifiedOnly == true) 'verified_only': true,
      if (withPhotoOnly == true) 'with_photo_only': true,
      if (onlineOnly == true) 'online_only': true,
    };
  }

  /// Create from query parameters
  factory MatchFilter.fromQueryParams(Map<String, dynamic> params) {
    return MatchFilter(
      minAge: params['min_age'] as int?,
      maxAge: params['max_age'] as int?,
      minHeight: params['min_height'] as double?,
      maxHeight: params['max_height'] as double?,
      religion: params['religion'] as String?,
      maritalStatus: params['marital_status'] as String?,
      education: params['education'] as String?,
      city: params['city'] as String?,
      occupation: params['occupation'] as String?,
      department: params['department'] as String?,
      verifiedOnly: params['verified_only'] as bool?,
      withPhotoOnly: params['with_photo_only'] as bool?,
      onlineOnly: params['online_only'] as bool?,
    );
  }

  /// Create a copy with updated values
  MatchFilter copyWith({
    int? minAge,
    int? maxAge,
    double? minHeight,
    double? maxHeight,
    String? religion,
    String? maritalStatus,
    String? education,
    String? city,
    String? occupation,
    String? department,
    bool? verifiedOnly,
    bool? withPhotoOnly,
    bool? onlineOnly,
  }) {
    return MatchFilter(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      department: department ?? this.department,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      withPhotoOnly: withPhotoOnly ?? this.withPhotoOnly,
      onlineOnly: onlineOnly ?? this.onlineOnly,
    );
  }

  /// Check if any filter is applied
  bool get hasActiveFilters {
    return minAge != null ||
        maxAge != null ||
        minHeight != null ||
        maxHeight != null ||
        (religion != null && religion!.isNotEmpty) ||
        (maritalStatus != null && maritalStatus!.isNotEmpty) ||
        (education != null && education!.isNotEmpty) ||
        (city != null && city!.isNotEmpty) ||
        (occupation != null && occupation!.isNotEmpty) ||
        (department != null && department!.isNotEmpty) ||
        verifiedOnly == true ||
        withPhotoOnly == true ||
        onlineOnly == true;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (minAge != null || maxAge != null) count++;
    if (minHeight != null || maxHeight != null) count++;
    if (religion != null && religion!.isNotEmpty) count++;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) count++;
    if (education != null && education!.isNotEmpty) count++;
    if (city != null && city!.isNotEmpty) count++;
    if (occupation != null && occupation!.isNotEmpty) count++;
    if (department != null && department!.isNotEmpty) count++;
    if (verifiedOnly == true) count++;
    if (withPhotoOnly == true) count++;
    if (onlineOnly == true) count++;
    return count;
  }

  /// Clear all filters
  static const MatchFilter empty = MatchFilter();

  @override
  String toString() {
    return 'MatchFilter(age: $minAge-$maxAge, height: $minHeight-$maxHeight, '
        'religion: $religion, status: $maritalStatus, edu: $education, '
        'city: $city, dept: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchFilter &&
        other.minAge == minAge &&
        other.maxAge == maxAge &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        other.religion == religion &&
        other.maritalStatus == maritalStatus &&
        other.education == education &&
        other.city == city &&
        other.occupation == occupation &&
        other.department == department &&
        other.verifiedOnly == verifiedOnly &&
        other.withPhotoOnly == withPhotoOnly &&
        other.onlineOnly == onlineOnly;
  }

  @override
  int get hashCode {
    return Object.hash(
      minAge,
      maxAge,
      minHeight,
      maxHeight,
      religion,
      maritalStatus,
      education,
      city,
      occupation,
      department,
      verifiedOnly,
      withPhotoOnly,
      onlineOnly,
    );
  }
}

/// Advanced filter options for special queries
class AdvancedFilter {
  final bool? newlyJoined;
  final bool? viewedYou;
  final bool? shortlistedYou;
  final bool? viewedByYou;
  final bool? shortlistedByYou;
  final bool? sentRequest;
  final bool? receivedRequest;
  final bool? acceptedRequest;

  const AdvancedFilter({
    this.newlyJoined,
    this.viewedYou,
    this.shortlistedYou,
    this.viewedByYou,
    this.shortlistedByYou,
    this.sentRequest,
    this.receivedRequest,
    this.acceptedRequest,
  });

  /// Convert to query parameters
  Map<String, dynamic> toQueryParams() {
    return {
      if (newlyJoined == true) 'newly_joined': true,
      if (viewedYou == true) 'viewed_you': true,
      if (shortlistedYou == true) 'shortlisted_you': true,
      if (viewedByYou == true) 'viewed_by_you': true,
      if (shortlistedByYou == true) 'shortlisted_by_you': true,
      if (sentRequest == true) 'sent_request': true,
      if (receivedRequest == true) 'received_request': true,
      if (acceptedRequest == true) 'accepted_request': true,
    };
  }

  /// Check if any advanced filter is active
  bool get hasActiveFilters {
    return newlyJoined == true ||
        viewedYou == true ||
        shortlistedYou == true ||
        viewedByYou == true ||
        shortlistedByYou == true ||
        sentRequest == true ||
        receivedRequest == true ||
        acceptedRequest == true;
  }

  /// Empty filter
  static const AdvancedFilter empty = AdvancedFilter();

  AdvancedFilter copyWith({
    bool? newlyJoined,
    bool? viewedYou,
    bool? shortlistedYou,
    bool? viewedByYou,
    bool? shortlistedByYou,
    bool? sentRequest,
    bool? receivedRequest,
    bool? acceptedRequest,
  }) {
    return AdvancedFilter(
      newlyJoined: newlyJoined ?? this.newlyJoined,
      viewedYou: viewedYou ?? this.viewedYou,
      shortlistedYou: shortlistedYou ?? this.shortlistedYou,
      viewedByYou: viewedByYou ?? this.viewedByYou,
      shortlistedByYou: shortlistedByYou ?? this.shortlistedByYou,
      sentRequest: sentRequest ?? this.sentRequest,
      receivedRequest: receivedRequest ?? this.receivedRequest,
      acceptedRequest: acceptedRequest ?? this.acceptedRequest,
    );
  }
}

/// Combined filters for comprehensive matching
class CombinedFilter {
  final MatchFilter basic;
  final AdvancedFilter advanced;

  const CombinedFilter({
    this.basic = const MatchFilter(),
    this.advanced = const AdvancedFilter(),
  });

  /// Convert to combined query parameters
  Map<String, dynamic> toQueryParams() {
    return {
      ...basic.toQueryParams(),
      ...advanced.toQueryParams(),
    };
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return basic.hasActiveFilters || advanced.hasActiveFilters;
  }

  /// Get total active filter count
  int get activeFilterCount {
    int count = basic.activeFilterCount;
    if (advanced.newlyJoined == true) count++;
    if (advanced.viewedYou == true) count++;
    if (advanced.shortlistedYou == true) count++;
    if (advanced.viewedByYou == true) count++;
    if (advanced.shortlistedByYou == true) count++;
    if (advanced.sentRequest == true) count++;
    if (advanced.receivedRequest == true) count++;
    if (advanced.acceptedRequest == true) count++;
    return count;
  }

  /// Empty combined filter
  static const CombinedFilter empty = CombinedFilter();

  CombinedFilter copyWith({
    MatchFilter? basic,
    AdvancedFilter? advanced,
  }) {
    return CombinedFilter(
      basic: basic ?? this.basic,
      advanced: advanced ?? this.advanced,
    );
  }
}
