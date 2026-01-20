import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class DashboardController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final MatchRepository _matchRepository = Get.find<MatchRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final userName = 'User'.obs;
  final profileCompletion = 0.obs;
  final isAdminVerified = false.obs;
  final profileViews = 0.obs;
  final sentInterests = 0.obs;
  final receivedInterests = 0.obs;
  final acceptedProfiles = 0.obs;
  final recommendedMatches = <MatchModel>[].obs;
  final isLoading = false.obs;
  final unreadNotificationCount = 0.obs;

  StreamSubscription? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _subscribeToUnreadNotifications();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToUnreadNotifications() {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    _notificationSubscription = _firestoreService.queryStream(
      collection: FirebaseConstants.notificationsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldUserId,
          operator: QueryOperator.isEqualTo,
          value: userId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldIsRead,
          operator: QueryOperator.isEqualTo,
          value: false,
        ),
      ],
    ).listen((data) {
      unreadNotificationCount.value = data.length;
    }, onError: (e) {
      // Handle error silently
    });
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([_loadUserData(), _loadStats(), _loadRecommendedMatches()]);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userRepository.getCurrentUser();
      userName.value = user['fullName'] ?? 'User';
      // Recalculate profile completion to ensure it's up to date
      profileCompletion.value = await _userRepository.recalculateProfileCompletion();
      isAdminVerified.value = await _authRepository.isAdminVerified();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _userRepository.getDashboardStats();
      profileViews.value = stats['profileViews'] ?? 0;
      sentInterests.value = stats['sentInterests'] ?? 0;
      receivedInterests.value = stats['receivedInterests'] ?? 0;
      acceptedProfiles.value = stats['acceptedProfiles'] ?? 0;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadRecommendedMatches() async {
    try {
      final response = await _matchRepository.getRecommendedMatches(perPage: 5);
      recommendedMatches.value = response.items;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}
