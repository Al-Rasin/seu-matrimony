import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/match_repository.dart';

class DashboardController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final MatchRepository _matchRepository = Get.find<MatchRepository>();

  final userName = 'User'.obs;
  final profileCompletion = 0.obs;
  final profileViews = 0.obs;
  final sentInterests = 0.obs;
  final receivedInterests = 0.obs;
  final acceptedProfiles = 0.obs;
  final recommendedMatches = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadUserData(),
        _loadStats(),
        _loadRecommendedMatches(),
      ]);
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
      profileCompletion.value = await _userRepository.getProfileCompletion();
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
      final response = await _matchRepository.getRecommendedMatches();
      recommendedMatches.value =
          List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}
