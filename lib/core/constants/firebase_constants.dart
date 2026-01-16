/// Firebase Firestore collection names and field constants
class FirebaseConstants {
  FirebaseConstants._();

  // ==================== COLLECTION NAMES ====================

  /// Users collection - stores all user profiles
  static const String usersCollection = 'users';

  /// Interests collection - interest requests between users
  static const String interestsCollection = 'interests';

  /// Conversations collection - chat conversations
  static const String conversationsCollection = 'conversations';

  /// Messages subcollection under conversations
  static const String messagesSubcollection = 'messages';

  /// Shortlists collection - saved/bookmarked profiles
  static const String shortlistsCollection = 'shortlists';

  /// Profile views collection - tracks who viewed which profile
  static const String profileViewsCollection = 'profileViews';

  /// Reports collection - user reports
  static const String reportsCollection = 'reports';

  /// Blocks collection - blocked users
  static const String blocksCollection = 'blocks';

  /// Subscriptions collection - user subscriptions
  static const String subscriptionsCollection = 'subscriptions';

  /// Subscription plans collection - available plans
  static const String subscriptionPlansCollection = 'subscriptionPlans';

  /// Notifications collection - user notifications
  static const String notificationsCollection = 'notifications';

  /// App settings collection - app configuration
  static const String appSettingsCollection = 'appSettings';

  // ==================== USER FIELDS ====================

  static const String fieldUserId = 'userId';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldFullName = 'fullName';
  static const String fieldGender = 'gender';
  static const String fieldDateOfBirth = 'dateOfBirth';
  static const String fieldAge = 'age';
  static const String fieldDepartment = 'department';
  static const String fieldStudentId = 'studentId';
  static const String fieldCurrentlyStudying = 'currentlyStudying';
  static const String fieldMaritalStatus = 'maritalStatus';
  static const String fieldChildren = 'children';
  static const String fieldHeight = 'height';
  static const String fieldReligion = 'religion';
  static const String fieldHighestEducation = 'highestEducation';
  static const String fieldEmploymentStatus = 'employmentStatus';
  static const String fieldOccupation = 'occupation';
  static const String fieldCurrentCity = 'currentCity';
  static const String fieldAbout = 'about';
  static const String fieldProfilePhoto = 'profilePhoto';
  static const String fieldSeuIdDocument = 'seuIdDocument';
  static const String fieldProfileFor = 'profileFor';
  static const String fieldRole = 'role';
  static const String fieldIsVerified = 'isVerified';
  static const String fieldIsOnline = 'isOnline';
  static const String fieldLastSeen = 'lastSeen';
  static const String fieldProfileCompletion = 'profileCompletion';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // ==================== INTEREST FIELDS ====================

  static const String fieldFromUserId = 'fromUserId';
  static const String fieldToUserId = 'toUserId';
  static const String fieldStatus = 'status';

  // Interest status values
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';

  // ==================== CONVERSATION FIELDS ====================

  static const String fieldParticipants = 'participants';
  static const String fieldLastMessage = 'lastMessage';
  static const String fieldLastMessageAt = 'lastMessageAt';
  static const String fieldUnreadCount = 'unreadCount';

  // ==================== MESSAGE FIELDS ====================

  static const String fieldSenderId = 'senderId';
  static const String fieldContent = 'content';
  static const String fieldType = 'type';
  static const String fieldReadAt = 'readAt';
  static const String fieldIsRead = 'isRead';

  // Message types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';

  // ==================== SHORTLIST FIELDS ====================

  static const String fieldSavedUserId = 'savedUserId';

  // ==================== PROFILE VIEW FIELDS ====================

  static const String fieldViewerId = 'viewerId';
  static const String fieldViewedUserId = 'viewedUserId';
  static const String fieldViewedAt = 'viewedAt';

  // ==================== REPORT FIELDS ====================

  static const String fieldReporterId = 'reporterId';
  static const String fieldReportedUserId = 'reportedUserId';
  static const String fieldReason = 'reason';
  static const String fieldDescription = 'description';

  // Report status values
  static const String reportStatusPending = 'pending';
  static const String reportStatusReviewed = 'reviewed';
  static const String reportStatusResolved = 'resolved';

  // ==================== BLOCK FIELDS ====================

  static const String fieldBlockerId = 'blockerId';
  static const String fieldBlockedUserId = 'blockedUserId';

  // ==================== SUBSCRIPTION FIELDS ====================

  static const String fieldPlanId = 'planId';
  static const String fieldStartDate = 'startDate';
  static const String fieldEndDate = 'endDate';
  static const String fieldPaymentDetails = 'paymentDetails';

  // Subscription status values
  static const String subscriptionStatusActive = 'active';
  static const String subscriptionStatusExpired = 'expired';
  static const String subscriptionStatusCancelled = 'cancelled';

  // ==================== SUBSCRIPTION PLAN FIELDS ====================

  static const String fieldName = 'name';
  static const String fieldPlanDescription = 'description';
  static const String fieldPrice = 'price';
  static const String fieldDuration = 'duration';
  static const String fieldFeatures = 'features';
  static const String fieldIsActive = 'isActive';

  // ==================== NOTIFICATION FIELDS ====================

  static const String fieldTitle = 'title';
  static const String fieldBody = 'body';
  static const String fieldData = 'data';

  // ==================== USER ROLES ====================

  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  // ==================== QUERY LIMITS ====================

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int recommendedMatchesLimit = 10;
  static const int recentNotificationsLimit = 20;

  // ==================== IMAGE CONSTRAINTS ====================

  /// Maximum image size in bytes (500KB)
  static const int maxImageSize = 500 * 1024;

  /// Image quality for compression (0-100)
  static const int imageQuality = 70;

  /// Maximum image dimension
  static const int maxImageDimension = 1024;
}
