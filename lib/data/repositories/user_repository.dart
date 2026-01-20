import 'package:get/get.dart';
import 'dart:convert';
import '../../core/services/mock_data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';

/// Repository for user-related operations
/// Handles both mock data and Firestore
class UserRepository {
  final StorageService _storageService = Get.find<StorageService>();

  // Lazy initialization for Firebase services (may not be available if Firebase not initialized)
  FirestoreService? _firestoreService;
  AuthService? _authService;

  FirestoreService get firestoreService {
    _firestoreService ??= Get.find<FirestoreService>();
    return _firestoreService!;
  }

  AuthService get authService {
    _authService ??= Get.find<AuthService>();
    return _authService!;
  }

  /// Check if using Firebase or mock data
  bool get useFirebase => !MockDataService.useMockData;

  /// Get current user ID
  String? get currentUserId => useFirebase ? authService.currentUserId : _storageService.userId;

  // ==================== GET USER DATA ====================

  /// Get current logged in user data
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );

      if (userData == null) {
        throw Exception('User data not found');
      }

      return userData;
    }

    // Mock data fallback
    final userData = await _storageService.getUserData();
    if (userData != null) {
      return jsonDecode(userData);
    }
    // Return default mock user data
    return {
      'id': 'user_001',
      'fullName': 'Al Rasin',
      'email': 'alrasin500@gmail.com',
      'phone': '+8801712345678',
    };
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    if (useFirebase) {
      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );

      if (userData == null) {
        throw Exception('User not found');
      }

      return userData;
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': userId,
      'fullName': 'Mock User',
      'email': 'mockuser@example.com',
    };
  }

  /// Stream current user data (real-time updates)
  Stream<Map<String, dynamic>?> streamCurrentUser() {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        return Stream.value(null);
      }

      return firestoreService.getByIdStream(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
    }

    // Mock - return empty stream
    return Stream.value(null);
  }

  // ==================== UPDATE USER DATA ====================

  /// Update basic details (Step 1 of registration)
  Future<Map<String, dynamic>> updateBasicDetails(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Add updated timestamp
      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      // Calculate and update profile completion
      await _updateProfileCompletion(userId);

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update personal details (Step 2 of registration)
  Future<Map<String, dynamic>> updatePersonalDetails(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      await _updateProfileCompletion(userId);

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update professional details (Step 3 of registration)
  Future<Map<String, dynamic>> updateProfessionalDetails(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      await _updateProfileCompletion(userId);

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update family details
  Future<Map<String, dynamic>> updateFamilyDetails(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      await _updateProfileCompletion(userId);

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update about/bio (Step 4 of registration)
  Future<Map<String, dynamic>> updateAbout(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      await _updateProfileCompletion(userId);

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update match preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      data[FirebaseConstants.fieldUpdatedAt] = DateTime.now().toIso8601String();

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: data,
      );

      return {'success': true, ...data};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true, ...data};
  }

  /// Update profile photo (base64)
  Future<Map<String, dynamic>> updateProfilePhoto(String base64Photo) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldProfilePhoto: base64Photo,
          FirebaseConstants.fieldUpdatedAt: DateTime.now().toIso8601String(),
        },
      );

      await _updateProfileCompletion(userId);

      return {'success': true};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true};
  }

  /// Update SEU ID document (base64)
  Future<Map<String, dynamic>> updateSeuIdDocument(String base64Document) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldSeuIdDocument: base64Document,
          FirebaseConstants.fieldUpdatedAt: DateTime.now().toIso8601String(),
        },
      );

      return {'success': true};
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true};
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String token) async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) return;

      await firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldFcmToken: token,
        },
      );
    }
  }

  // ==================== DASHBOARD STATS ====================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Get profile views count (where viewedUserId == current user)
      final profileViews = await firestoreService.getWhere(
        collection: FirebaseConstants.profileViewsCollection,
        field: FirebaseConstants.fieldViewedUserId,
        isEqualTo: userId,
      );

      // Get sent interests count (where fromUserId == current user)
      final sentInterests = await firestoreService.getWhere(
        collection: FirebaseConstants.interestsCollection,
        field: FirebaseConstants.fieldFromUserId,
        isEqualTo: userId,
      );

      // Get received interests count (where toUserId == current user)
      final receivedInterests = await firestoreService.getWhere(
        collection: FirebaseConstants.interestsCollection,
        field: FirebaseConstants.fieldToUserId,
        isEqualTo: userId,
      );

      // Get accepted interests count
      final acceptedSent = await firestoreService.query(
        collection: FirebaseConstants.interestsCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldFromUserId,
            operator: QueryOperator.isEqualTo,
            value: userId,
          ),
          QueryFilter(
            field: FirebaseConstants.fieldStatus,
            operator: QueryOperator.isEqualTo,
            value: FirebaseConstants.statusAccepted,
          ),
        ],
      );

      final acceptedReceived = await firestoreService.query(
        collection: FirebaseConstants.interestsCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldToUserId,
            operator: QueryOperator.isEqualTo,
            value: userId,
          ),
          QueryFilter(
            field: FirebaseConstants.fieldStatus,
            operator: QueryOperator.isEqualTo,
            value: FirebaseConstants.statusAccepted,
          ),
        ],
      );

      return {
        'profileViews': profileViews.length,
        'sentInterests': sentInterests.length,
        'receivedInterests': receivedInterests.length,
        'acceptedProfiles': acceptedSent.length + acceptedReceived.length,
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'profileViews': 156,
      'sentInterests': 23,
      'receivedInterests': 45,
      'acceptedProfiles': 12,
    };
  }

  /// Get profile completion percentage
  Future<int> getProfileCompletion() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) return 0;

      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );

      if (userData == null) return 0;

      final completion = userData[FirebaseConstants.fieldProfileCompletion];
      return completion is int ? completion : 0;
    }

    // Mock data fallback
    final userData = await _storageService.getUserData();
    if (userData != null) {
      final user = UserModel.fromJson(jsonDecode(userData));
      return user.profileCompletionPercentage;
    }
    return 85;
  }

  // ==================== HELPER METHODS ====================

  /// Calculate and update profile completion percentage
  Future<void> _updateProfileCompletion(String userId) async {
    final userData = await firestoreService.getById(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
    );

    if (userData == null) return;

    int completion = 0;
    int totalFields = 0;

    // Basic details (4 fields)
    totalFields += 4;
    if (_hasValue(userData[FirebaseConstants.fieldFullName])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldGender])) completion++;
    // Check both 'dateOfBirth' and legacy 'dob' field
    if (_hasValue(userData[FirebaseConstants.fieldDateOfBirth]) || _hasValue(userData['dob'])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldDepartment])) completion++;

    // Personal details (4 fields)
    totalFields += 4;
    if (_hasValue(userData[FirebaseConstants.fieldMaritalStatus])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldHeight])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldReligion])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldStudentId])) completion++;

    // Professional details (4 fields)
    totalFields += 4;
    if (_hasValue(userData[FirebaseConstants.fieldHighestEducation])) completion++;
    // Check both 'employmentStatus' and legacy 'employment' field
    if (_hasValue(userData[FirebaseConstants.fieldEmploymentStatus]) || _hasValue(userData['employment'])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldOccupation])) completion++;
    if (_hasValue(userData[FirebaseConstants.fieldCurrentCity])) completion++;

    // About (1 field) - check both 'about' and legacy 'bio' field
    totalFields++;
    if (_hasValue(userData[FirebaseConstants.fieldAbout]) || _hasValue(userData['bio'])) completion++;

    // Profile photo (1 field)
    totalFields++;
    if (_hasValue(userData[FirebaseConstants.fieldProfilePhoto])) completion++;

    // SEU ID document (1 field)
    totalFields++;
    if (_hasValue(userData[FirebaseConstants.fieldSeuIdDocument])) completion++;

    // Calculate percentage
    final percentage = totalFields > 0 ? ((completion / totalFields) * 100).round() : 0;

    // Update in Firestore
    await firestoreService.update(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
      data: {
        FirebaseConstants.fieldProfileCompletion: percentage,
      },
    );
  }

  /// Check if a value is not null and not empty
  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    return true;
  }

  /// Check if user has completed basic required fields (for login redirect)
  Future<bool> hasBasicProfileInfo() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) return false;

      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );

      if (userData == null) return false;

      // Required fields: gender and either dateOfBirth or dob
      final hasGender = _hasValue(userData[FirebaseConstants.fieldGender]);
      final hasDob = _hasValue(userData[FirebaseConstants.fieldDateOfBirth]) || _hasValue(userData['dob']);

      return hasGender && hasDob;
    }

    return true;
  }

  /// Recalculate and update profile completion percentage
  Future<int> recalculateProfileCompletion() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) return 0;

      await _updateProfileCompletion(userId);

      // Return the new completion percentage
      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      return userData?[FirebaseConstants.fieldProfileCompletion] ?? 0;
    }
    return 0;
  }

  /// Mark profile as complete (after registration)
  Future<void> markProfileComplete() async {
    if (useFirebase) {
      final userId = authService.currentUserId;
      if (userId == null) return;

      await _updateProfileCompletion(userId);
    }
  }

  /// Check if user profile is complete (has basic info)
  Future<bool> isProfileComplete() async {
    return await hasBasicProfileInfo();
  }
}
