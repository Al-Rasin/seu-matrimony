import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class UserManagementController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final results = await _firestoreService.getAll(collection: FirebaseConstants.usersCollection);
      users.value = results;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyUser(String userId, bool isVerified) async {
    await _firestoreService.update(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
      data: {FirebaseConstants.fieldIsVerified: isVerified},
    );
    loadUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _firestoreService.delete(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
    );
    loadUsers();
  }
}
