import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class MyProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final userName = ''.obs;
  final userEmail = ''.obs;
  final profilePhotoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = await _userRepository.getCurrentUser();
      userName.value = user['fullName'] ?? 'User';
      userEmail.value = user['email'] ?? '';
      profilePhotoUrl.value = user['profilePhotoUrl'] ?? '';
    } catch (e) {
      // Handle error
    }
  }

  void editPhoto() {
    Get.toNamed(AppRoutes.editProfile);
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout');
    }
  }
}
