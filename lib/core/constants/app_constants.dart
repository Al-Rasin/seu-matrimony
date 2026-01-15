class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SEU Matrimony';
  static const String appTagline = 'Find Your Perfect Match';

  // Pagination
  static const int defaultPageSize = 20;
  static const int matchesPageSize = 10;
  static const int messagesPageSize = 50;

  // Profile Limits
  static const int maxPhotos = 6;
  static const int minPhotos = 1;
  static const int maxBioLength = 500;
  static const int minAge = 18;
  static const int maxAge = 60;

  // Height (in cm)
  static const double minHeight = 120.0;
  static const double maxHeight = 220.0;

  // Agora
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  // Registration Steps
  static const int totalRegistrationSteps = 5;

  // Animation Durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Debounce Durations (milliseconds)
  static const int searchDebounce = 500;
  static const int typingIndicatorDebounce = 2000;

  // Cache Durations (minutes)
  static const int matchesCacheDuration = 5;
  static const int profileCacheDuration = 10;

  // Image Sizes
  static const double thumbnailSize = 100;
  static const double mediumImageSize = 300;
  static const double largeImageSize = 600;

  // Profile For Options
  static const List<String> profileForOptions = [
    'Self',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Relative',
    'Friend',
  ];

  // Gender Options
  static const List<String> genderOptions = ['Male', 'Female'];

  // Marital Status Options
  static const List<String> maritalStatusOptions = [
    'Never Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  // Religion Options
  static const List<String> religionOptions = [
    'Muslim',
    'Hindu',
    'Christian',
    'Buddhist',
    'Other',
  ];

  // Employment Options
  static const List<String> employmentOptions = [
    'Employed',
    'Self Employed',
    'Business',
    'Not Working',
    'Student',
  ];

  // Education Options
  static const List<String> educationOptions = [
    'High School',
    'Diploma',
    'Bachelor\'s',
    'Master\'s',
    'PhD',
    'Other',
  ];

  // Family Type Options
  static const List<String> familyTypeOptions = [
    'Joint Family',
    'Nuclear Family',
  ];

  // Annual Income Options (in BDT)
  static const List<String> annualIncomeOptions = [
    'Not Specified',
    'Below 2 Lakh',
    '2-5 Lakh',
    '5-10 Lakh',
    '10-20 Lakh',
    '20-50 Lakh',
    'Above 50 Lakh',
  ];
}
