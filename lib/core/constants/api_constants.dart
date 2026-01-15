class ApiConstants {
  ApiConstants._();

  // Base URLs - Update these with your actual backend URL
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String devBaseUrl = 'http://localhost:8080/api/v1';
  static const String prodBaseUrl = 'https://api.seumatrimony.com/api/v1';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyPhone = '/auth/verify-phone';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String checkUsername = '/auth/check-username';
  static const String checkPhone = '/auth/check-phone';

  // User Endpoints
  static const String profile = '/users/me';
  static const String currentUser = '/users/me';
  static const String completeProfile = '/users/me/complete-profile';
  static const String updateBasicDetails = '/users/me/basic';
  static const String updatePersonalDetails = '/users/me/personal';
  static const String updateProfessionalDetails = '/users/me/professional';
  static const String updateFamilyDetails = '/users/me/family';
  static const String updatePreferences = '/users/me/preferences';
  static const String uploadPhoto = '/users/me/photos';
  static const String uploadProfilePhoto = '/users/me/profile-photo';
  static const String uploadSeuId = '/users/me/seu-id';
  static const String changePassword = '/users/me/change-password';
  static const String deleteAccount = '/users/me/delete';
  static const String userById = '/users';

  // Matches Endpoints
  static const String matches = '/matches';
  static const String recommendedMatches = '/matches/recommended';
  static const String newlyJoined = '/matches/newly-joined';
  static const String searchMatches = '/matches/search';

  // Interest Endpoints
  static const String interests = '/interests';
  static const String sentInterests = '/interests/sent';
  static const String receivedInterests = '/interests/received';

  // Profile Views Endpoints
  static const String profileViews = '/views';
  static const String whoViewedMe = '/views/who-viewed-me';
  static const String viewedByMe = '/views/viewed-by-me';

  // Shortlist Endpoints
  static const String shortlist = '/shortlist';
  static const String shortlistedMe = '/shortlist/shortlisted-me';

  // Chat Endpoints
  static const String conversations = '/conversations';

  // Block & Report Endpoints
  static const String block = '/block';
  static const String report = '/report';

  // Subscription Endpoints
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String mySubscription = '/subscriptions/my';
  static const String purchaseSubscription = '/subscriptions/purchase';
  static const String verifyPayment = '/subscriptions/verify-payment';

  // Call Endpoints
  static const String initiateCall = '/calls/initiate';
  static const String callToken = '/calls/token';
  static const String callHistory = '/calls/history';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String fcmToken = '/notifications/fcm-token';

  // Dashboard Endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String profileCompletion = '/dashboard/profile-completion';
}
