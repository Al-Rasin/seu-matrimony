/// Register request model for initial registration
class RegisterRequest {
  final String fullName;
  final String phone;
  final String username;
  final String password;
  final String confirmPassword;
  final String profileFor;
  final String? seuIdImage; // Base64 encoded SEU ID image
  final bool acceptedTerms;

  const RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.profileFor,
    this.seuIdImage,
    this.acceptedTerms = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'username': username,
      'password': password,
      'confirm_password': confirmPassword,
      'profile_for': profileFor,
      'seu_id_image': seuIdImage,
      'accepted_terms': acceptedTerms,
    };
  }

  /// Validate the request
  String? validate() {
    if (fullName.trim().isEmpty) {
      return 'Full name is required';
    }
    if (phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (username.trim().isEmpty) {
      return 'Username is required';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (profileFor.isEmpty) {
      return 'Please select who this profile is for';
    }
    if (!acceptedTerms) {
      return 'Please accept the terms and conditions';
    }
    return null;
  }

  @override
  String toString() => 'RegisterRequest(username: $username, fullName: $fullName)';
}

/// Profile completion request for multi-step registration
class ProfileCompletionRequest {
  // Step 1: Basic Details
  final String? gender;
  final DateTime? dateOfBirth;
  final String? department;
  final String? studentId;
  final bool? isCurrentlyStudying;

  // Step 2: Personal Details
  final String? maritalStatus;
  final String? email;
  final bool? hasChildren;
  final int? numberOfChildren;
  final double? height;
  final String? religion;

  // Step 3: Professional Details
  final String? highestEducation;
  final String? educationDetails;
  final String? employmentType;
  final String? occupation;
  final String? annualIncome;
  final String? workLocation;
  final String? companyName;
  final String? currentCity;

  // Step 4: About Yourself
  final String? bio;
  final String? profilePhoto; // Base64 encoded

  const ProfileCompletionRequest({
    this.gender,
    this.dateOfBirth,
    this.department,
    this.studentId,
    this.isCurrentlyStudying,
    this.maritalStatus,
    this.email,
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
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    // Only include non-null values
    if (gender != null) map['gender'] = gender;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth!.toIso8601String();
    if (department != null) map['department'] = department;
    if (studentId != null) map['student_id'] = studentId;
    if (isCurrentlyStudying != null) map['is_currently_studying'] = isCurrentlyStudying;
    if (maritalStatus != null) map['marital_status'] = maritalStatus;
    if (email != null) map['email'] = email;
    if (hasChildren != null) map['has_children'] = hasChildren;
    if (numberOfChildren != null) map['number_of_children'] = numberOfChildren;
    if (height != null) map['height'] = height;
    if (religion != null) map['religion'] = religion;
    if (highestEducation != null) map['highest_education'] = highestEducation;
    if (educationDetails != null) map['education_details'] = educationDetails;
    if (employmentType != null) map['employment_type'] = employmentType;
    if (occupation != null) map['occupation'] = occupation;
    if (annualIncome != null) map['annual_income'] = annualIncome;
    if (workLocation != null) map['work_location'] = workLocation;
    if (companyName != null) map['company_name'] = companyName;
    if (currentCity != null) map['current_city'] = currentCity;
    if (bio != null) map['bio'] = bio;
    if (profilePhoto != null) map['profile_photo'] = profilePhoto;

    return map;
  }

  ProfileCompletionRequest copyWith({
    String? gender,
    DateTime? dateOfBirth,
    String? department,
    String? studentId,
    bool? isCurrentlyStudying,
    String? maritalStatus,
    String? email,
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
    String? profilePhoto,
  }) {
    return ProfileCompletionRequest(
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      isCurrentlyStudying: isCurrentlyStudying ?? this.isCurrentlyStudying,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      email: email ?? this.email,
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
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

/// Profile for options
class ProfileForOptions {
  static const String self = 'self';
  static const String son = 'son';
  static const String daughter = 'daughter';
  static const String brother = 'brother';
  static const String sister = 'sister';
  static const String relative = 'relative';
  static const String friend = 'friend';

  static const List<String> all = [
    self,
    son,
    daughter,
    brother,
    sister,
    relative,
    friend,
  ];

  static String getDisplayName(String value) {
    switch (value) {
      case self:
        return 'Self';
      case son:
        return 'Son';
      case daughter:
        return 'Daughter';
      case brother:
        return 'Brother';
      case sister:
        return 'Sister';
      case relative:
        return 'Relative';
      case friend:
        return 'Friend';
      default:
        return value;
    }
  }
}
