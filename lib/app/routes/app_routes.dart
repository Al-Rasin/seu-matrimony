abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const emailVerification = '/email-verification';
  static const verificationPending = '/verification-pending';

  // Registration Steps
  static const registration = '/registration';

  // Main App
  static const home = '/home';
  static const dashboard = '/dashboard';

  // Admin
  static const adminDashboard = '/admin-dashboard';
  static const adminUserManagement = '/admin-user-management';
  static const adminUserDetail = '/admin-user-detail';
  static const adminEditUser = '/admin-edit-user';
  static const adminReports = '/admin-reports';
  static const adminAppSettings = '/admin-app-settings';

  // Matches
  static const matches = '/matches';
  static const profileDetail = '/profile-detail';
  static const filters = '/filters';
  static const matchPreference = '/match-preference';

  // Chat
  static const chatList = '/chat-list';
  static const chatDetail = '/chat-detail';

  // Calls
  static const call = '/call';

  // Profile
  static const myProfile = '/my-profile';
  static const editProfile = '/edit-profile';
  static const editBasicDetails = '/edit-basic-details';
  static const editPersonalDetails = '/edit-personal-details';
  static const editProfessionalDetails = '/edit-professional-details';
  static const editFamilyDetails = '/edit-family-details';
  static const editAbout = '/edit-about';
  static const editPreferences = '/edit-preferences';

  // Subscription
  static const subscription = '/subscription';
  static const paymentSuccess = '/payment-success';

  // Settings
  static const settings = '/settings';
  static const privacySettings = '/privacy-settings';
  static const notificationSettings = '/notification-settings';
  static const blockedUsers = '/blocked-users';

  // Notifications
  static const notifications = '/notifications';

  // Others
  static const termsAndConditions = '/terms-and-conditions';
  static const privacyPolicy = '/privacy-policy';
  static const helpAndSupport = '/help-and-support';
}
