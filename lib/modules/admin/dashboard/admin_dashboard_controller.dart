import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class AdminDashboardController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final totalUsers = 0.obs;
  final pendingVerifications = 0.obs;
  final totalReports = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      
      final users = await _firestoreService.getAll(collection: FirebaseConstants.usersCollection);
      totalUsers.value = users.length;

      final pending = users.where((u) => u[FirebaseConstants.fieldIsVerified] == false).length;
      pendingVerifications.value = pending;

      final reports = await _firestoreService.getAll(collection: FirebaseConstants.reportsCollection);
      totalReports.value = reports.length;

    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
