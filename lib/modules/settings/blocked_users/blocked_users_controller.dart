import 'package:get/get.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/models/match_model.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firestore_service.dart';

class BlockedUsersController extends GetxController {
  final MatchRepository _matchRepository = Get.find<MatchRepository>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final isLoading = false.obs;
  final blockedUsers = <MatchModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    try {
      isLoading.value = true;
      final currentUserId = _matchRepository.currentUserId;
      if (currentUserId == null) return;

      // Get blocked user IDs from blocks collection
      final blocks = await _firestoreService.getWhere(
        collection: FirebaseConstants.blocksCollection,
        field: FirebaseConstants.fieldBlockerId,
        isEqualTo: currentUserId,
      );

      final List<MatchModel> users = [];
      for (final block in blocks) {
        final blockedUserId = block[FirebaseConstants.fieldBlockedUserId] as String?;
        if (blockedUserId != null) {
          final userData = await _firestoreService.getById(
            collection: FirebaseConstants.usersCollection,
            documentId: blockedUserId,
          );
          if (userData != null) {
            users.add(MatchModel.fromFirestore(userData));
          }
        }
      }
      blockedUsers.assignAll(users);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load blocked users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final success = await _matchRepository.unblockUser(userId);
      if (success) {
        blockedUsers.removeWhere((u) => u.id == userId);
        Get.snackbar('Success', 'User unblocked successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user');
    }
  }
}
