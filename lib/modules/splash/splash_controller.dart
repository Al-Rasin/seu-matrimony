import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate loading time for splash screen
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    final hasSeenOnboarding = _storageService.hasSeenOnboarding;
    final isLoggedIn = _storageService.isLoggedIn;

    if (!hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
