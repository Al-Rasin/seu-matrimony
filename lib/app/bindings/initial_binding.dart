import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<DioClient>(DioClient(), permanent: true);
    Get.put<FirebaseService>(FirebaseService(), permanent: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository());
  }
}
