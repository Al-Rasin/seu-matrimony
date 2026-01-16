import 'package:cloud_firestore/cloud_firestore.dart';

/// Match model for displaying potential matches
class MatchModel {
  final String id;
  final String fullName;
  final String? profilePhoto;
  final List<String>? photos;
  final int? age;
  final String? gender;
  final double? height;
  final String? religion;
  final String? maritalStatus;
  final String? department;
  final String? highestEducation;
  final String? occupation;
  final String? currentCity;
  final String? bio;
  final int profileCompletionPercentage;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final InterestStatus? interestStatus;
  final String? interestId;
  final bool isShortlisted;

  const MatchModel({
    required this.id,
    required this.fullName,
    this.profilePhoto,
    this.photos,
    this.age,
    this.gender,
    this.height,
    this.religion,
    this.maritalStatus,
    this.department,
    this.highestEducation,
    this.occupation,
    this.currentCity,
    this.bio,
    this.profileCompletionPercentage = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.interestStatus,
    this.interestId,
    this.isShortlisted = false,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString() ?? json['profilePhoto']?.toString(),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      height: json['height'] is double
          ? json['height']
          : double.tryParse(json['height']?.toString() ?? ''),
      religion: json['religion']?.toString(),
      maritalStatus: json['marital_status']?.toString() ?? json['maritalStatus']?.toString(),
      department: json['department']?.toString(),
      highestEducation: json['highest_education']?.toString() ?? json['highestEducation']?.toString(),
      occupation: json['occupation']?.toString(),
      currentCity: json['current_city']?.toString() ?? json['currentCity']?.toString(),
      bio: json['bio']?.toString(),
      profileCompletionPercentage: json['profile_completion_percentage'] is int
          ? json['profile_completion_percentage']
          : int.tryParse(json['profile_completion_percentage']?.toString() ?? '0') ?? 0,
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'].toString())
          : null,
      interestStatus: InterestStatus.fromString(
          json['interest_status']?.toString() ?? json['interestStatus']?.toString()),
      interestId: json['interest_id']?.toString() ?? json['interestId']?.toString(),
      isShortlisted: json['is_shortlisted'] == true || json['isShortlisted'] == true,
    );
  }

  /// Create MatchModel from Firestore document data
  factory MatchModel.fromFirestore(Map<String, dynamic> data) {
    // Helper to convert Firestore Timestamp to DateTime
    DateTime? timestampToDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return MatchModel(
      id: data['id']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      profilePhoto: data['profilePhoto']?.toString(),
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      age: data['age'] is int ? data['age'] : int.tryParse(data['age']?.toString() ?? ''),
      gender: data['gender']?.toString(),
      height: data['height'] is double
          ? data['height']
          : data['height'] is int
              ? (data['height'] as int).toDouble()
              : double.tryParse(data['height']?.toString() ?? ''),
      religion: data['religion']?.toString(),
      maritalStatus: data['maritalStatus']?.toString(),
      department: data['department']?.toString(),
      highestEducation: data['highestEducation']?.toString(),
      occupation: data['occupation']?.toString(),
      currentCity: data['currentCity']?.toString(),
      bio: data['about']?.toString() ?? data['bio']?.toString(),
      profileCompletionPercentage: data['profileCompletion'] is int
          ? data['profileCompletion']
          : int.tryParse(data['profileCompletion']?.toString() ?? '0') ?? 0,
      isVerified: data['isVerified'] == true,
      isOnline: data['isOnline'] == true,
      lastSeen: timestampToDateTime(data['lastSeen']),
      interestStatus: InterestStatus.none,
      interestId: null,
      isShortlisted: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'photos': photos,
      'age': age,
      'gender': gender,
      'height': height,
      'religion': religion,
      'marital_status': maritalStatus,
      'department': department,
      'highest_education': highestEducation,
      'occupation': occupation,
      'current_city': currentCity,
      'bio': bio,
      'profile_completion_percentage': profileCompletionPercentage,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'interest_status': interestStatus?.value,
      'interest_id': interestId,
      'is_shortlisted': isShortlisted,
    };
  }

  /// Get display height (e.g., "5'8\"")
  String? get displayHeight {
    if (height == null) return null;
    final feet = (height! / 30.48).floor();
    final inches = ((height! % 30.48) / 2.54).round();
    return "$feet'$inches\"";
  }

  /// Get age display string
  String get ageDisplay => age != null ? '$age yrs' : '';

  /// Get short info line (age, height, city)
  String get shortInfo {
    final parts = <String>[];
    if (age != null) parts.add('$age yrs');
    if (displayHeight != null) parts.add(displayHeight!);
    if (currentCity != null) parts.add(currentCity!);
    return parts.join(' | ');
  }

  /// Get education and job line
  String get educationJobLine {
    final parts = <String>[];
    if (highestEducation != null) parts.add(highestEducation!);
    if (occupation != null) parts.add(occupation!);
    return parts.join(' | ');
  }

  MatchModel copyWith({
    String? id,
    String? fullName,
    String? profilePhoto,
    List<String>? photos,
    int? age,
    String? gender,
    double? height,
    String? religion,
    String? maritalStatus,
    String? department,
    String? highestEducation,
    String? occupation,
    String? currentCity,
    String? bio,
    int? profileCompletionPercentage,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    InterestStatus? interestStatus,
    String? interestId,
    bool? isShortlisted,
  }) {
    return MatchModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      photos: photos ?? this.photos,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      department: department ?? this.department,
      highestEducation: highestEducation ?? this.highestEducation,
      occupation: occupation ?? this.occupation,
      currentCity: currentCity ?? this.currentCity,
      bio: bio ?? this.bio,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      interestStatus: interestStatus ?? this.interestStatus,
      interestId: interestId ?? this.interestId,
      isShortlisted: isShortlisted ?? this.isShortlisted,
    );
  }

  @override
  String toString() => 'MatchModel(id: $id, fullName: $fullName, age: $age)';
}

/// Interest status between users
enum InterestStatus {
  none('none'),
  sent('sent'),
  received('received'),
  accepted('accepted'),
  rejected('rejected');

  final String value;
  const InterestStatus(this.value);

  static InterestStatus? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'sent':
        return InterestStatus.sent;
      case 'received':
        return InterestStatus.received;
      case 'accepted':
        return InterestStatus.accepted;
      case 'rejected':
        return InterestStatus.rejected;
      default:
        return InterestStatus.none;
    }
  }

  String get displayText {
    switch (this) {
      case InterestStatus.none:
        return 'Send Interest';
      case InterestStatus.sent:
        return 'Interest Sent';
      case InterestStatus.received:
        return 'Respond';
      case InterestStatus.accepted:
        return 'Accepted';
      case InterestStatus.rejected:
        return 'Rejected';
    }
  }
}
