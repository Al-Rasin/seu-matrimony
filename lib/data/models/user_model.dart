/// User model for SEU Matrimony app
class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final UserRole role;
  final ProfileStatus profileStatus;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Basic Details
  final String? gender;
  final DateTime? dateOfBirth;
  final int? age;
  final String? department;
  final String? studentId;
  final bool? isCurrentlyStudying;

  // Personal Details
  final String? maritalStatus;
  final bool? hasChildren;
  final int? numberOfChildren;
  final double? height;
  final String? religion;

  // Professional Details
  final String? highestEducation;
  final String? educationDetails;
  final String? employmentType;
  final String? occupation;
  final String? annualIncome;
  final String? workLocation;
  final String? companyName;
  final String? currentCity;

  // About
  final String? bio;
  final List<String>? photos;

  // Profile Completion
  final int profileCompletionPercentage;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.profilePhoto,
    this.role = UserRole.user,
    this.profileStatus = ProfileStatus.pending,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.updatedAt,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.department,
    this.studentId,
    this.isCurrentlyStudying,
    this.maritalStatus,
    this.hasChildren,
    this.numberOfChildren,
    this.height,
    this.religion,
    this.highestEducation,
    this.educationDetails,
    this.employmentType,
    this.occupation,
    this.annualIncome,
    this.workLocation,
    this.companyName,
    this.currentCity,
    this.bio,
    this.photos,
    this.profileCompletionPercentage = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profilePhoto: json['profile_photo']?.toString() ?? json['profilePhoto']?.toString(),
      role: UserRole.fromString(json['role']?.toString()),
      profileStatus: ProfileStatus.fromString(json['profile_status']?.toString() ?? json['profileStatus']?.toString()),
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      lastSeen: json['last_seen'] != null ? DateTime.tryParse(json['last_seen'].toString()) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'].toString()) : null,
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      department: json['department']?.toString(),
      studentId: json['student_id']?.toString() ?? json['studentId']?.toString(),
      isCurrentlyStudying: json['is_currently_studying'] == true || json['isCurrentlyStudying'] == true,
      maritalStatus: json['marital_status']?.toString() ?? json['maritalStatus']?.toString(),
      hasChildren: json['has_children'] == true || json['hasChildren'] == true,
      numberOfChildren: json['number_of_children'] is int ? json['number_of_children'] : int.tryParse(json['number_of_children']?.toString() ?? ''),
      height: json['height'] is double ? json['height'] : double.tryParse(json['height']?.toString() ?? ''),
      religion: json['religion']?.toString(),
      highestEducation: json['highest_education']?.toString() ?? json['highestEducation']?.toString(),
      educationDetails: json['education_details']?.toString() ?? json['educationDetails']?.toString(),
      employmentType: json['employment_type']?.toString() ?? json['employmentType']?.toString(),
      occupation: json['occupation']?.toString(),
      annualIncome: json['annual_income']?.toString() ?? json['annualIncome']?.toString(),
      workLocation: json['work_location']?.toString() ?? json['workLocation']?.toString(),
      companyName: json['company_name']?.toString() ?? json['companyName']?.toString(),
      currentCity: json['current_city']?.toString() ?? json['currentCity']?.toString(),
      bio: json['bio']?.toString(),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      profileCompletionPercentage: json['profile_completion_percentage'] is int
          ? json['profile_completion_percentage']
          : int.tryParse(json['profile_completion_percentage']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_photo': profilePhoto,
      'role': role.value,
      'profile_status': profileStatus.value,
      'is_verified': isVerified,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'age': age,
      'department': department,
      'student_id': studentId,
      'is_currently_studying': isCurrentlyStudying,
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'number_of_children': numberOfChildren,
      'height': height,
      'religion': religion,
      'highest_education': highestEducation,
      'education_details': educationDetails,
      'employment_type': employmentType,
      'occupation': occupation,
      'annual_income': annualIncome,
      'work_location': workLocation,
      'company_name': companyName,
      'current_city': currentCity,
      'bio': bio,
      'photos': photos,
      'profile_completion_percentage': profileCompletionPercentage,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? profilePhoto,
    UserRole? role,
    ProfileStatus? profileStatus,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    String? department,
    String? studentId,
    bool? isCurrentlyStudying,
    String? maritalStatus,
    bool? hasChildren,
    int? numberOfChildren,
    double? height,
    String? religion,
    String? highestEducation,
    String? educationDetails,
    String? employmentType,
    String? occupation,
    String? annualIncome,
    String? workLocation,
    String? companyName,
    String? currentCity,
    String? bio,
    List<String>? photos,
    int? profileCompletionPercentage,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      profileStatus: profileStatus ?? this.profileStatus,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      isCurrentlyStudying: isCurrentlyStudying ?? this.isCurrentlyStudying,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      height: height ?? this.height,
      religion: religion ?? this.religion,
      highestEducation: highestEducation ?? this.highestEducation,
      educationDetails: educationDetails ?? this.educationDetails,
      employmentType: employmentType ?? this.employmentType,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      workLocation: workLocation ?? this.workLocation,
      companyName: companyName ?? this.companyName,
      currentCity: currentCity ?? this.currentCity,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
    );
  }

  /// Get display name (full name or username)
  String get displayName => fullName.isNotEmpty ? fullName : username;

  /// Get age from date of birth
  int? get calculatedAge {
    if (dateOfBirth == null) return age;
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// Check if profile is complete
  bool get isProfileComplete => profileCompletionPercentage >= 100;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  @override
  String toString() => 'UserModel(id: $id, username: $username, fullName: $fullName)';
}

/// User roles
enum UserRole {
  user('user'),
  admin('admin'),
  superAdmin('super_admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }
}

/// Profile status
enum ProfileStatus {
  pending('pending'),
  active('active'),
  suspended('suspended'),
  rejected('rejected'),
  deleted('deleted');

  final String value;
  const ProfileStatus(this.value);

  static ProfileStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return ProfileStatus.active;
      case 'suspended':
        return ProfileStatus.suspended;
      case 'rejected':
        return ProfileStatus.rejected;
      case 'deleted':
        return ProfileStatus.deleted;
      default:
        return ProfileStatus.pending;
    }
  }
}
