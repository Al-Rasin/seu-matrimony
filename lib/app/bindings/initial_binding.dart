import 'package:get/get.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../../core/services/storage_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/presence_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/call_service.dart';
import '../../core/services/mock_data_service.dart';
import '../../data/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (always available)
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<MockDataService>(MockDataService(), permanent: true);

    // Firebase-dependent services (only if Firebase is initialized)
    if (isFirebaseInitialized) {
      Get.put<FirebaseService>(FirebaseService(), permanent: true);
      Get.put<FirestoreService>(FirestoreService(), permanent: true);
      Get.put<AuthService>(AuthService(), permanent: true);
      Get.put<PresenceService>(PresenceService(), permanent: true);
      Get.put<NotificationService>(NotificationService(), permanent: true);
      Get.put<CallService>(CallService(), permanent: true);
    }

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository());
  }
}
