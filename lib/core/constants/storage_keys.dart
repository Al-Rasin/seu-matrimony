class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String firebaseToken = 'firebase_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';

  // User
  static const String userData = 'user_data';
  static const String profileCompletion = 'profile_completion';
  static const String isProfileComplete = 'is_profile_complete';

  // Onboarding
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String isFirstLaunch = 'is_first_launch';

  // Settings
  static const String notificationsEnabled = 'notifications_enabled';
  static const String darkModeEnabled = 'dark_mode_enabled';
  static const String language = 'language';

  // FCM
  static const String fcmToken = 'fcm_token';

  // Filters
  static const String savedFilters = 'saved_filters';
  static const String lastSearchFilters = 'last_search_filters';

  // Cache
  static const String cachedMatches = 'cached_matches';
  static const String cachedRecommendations = 'cached_recommendations';
  static const String lastCacheTime = 'last_cache_time';
}
