import 'package:get/get.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/interest_repository.dart';

class MatchesController extends GetxController {
  final MatchRepository _matchRepository = Get.find<MatchRepository>();
  final InterestRepository _interestRepository = Get.find<InterestRepository>();

  final matches = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'Filters'.obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final response = await _matchRepository.getMatches();
      matches.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    loadMatches();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Implement search logic
  }

  Future<void> sendInterest(String userId, bool interested) async {
    if (!interested) return;

    try {
      await _interestRepository.sendInterest(userId);
      Get.snackbar(
        'Success',
        'Interest sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send interest',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void viewProfile(String userId) {
    Get.toNamed('/profile-detail', arguments: {'userId': userId});
  }
}
