import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final isProfileVisible = true.obs;
  final notifyNewMatches = true.obs;
  final notifyNewMessages = true.obs;
  final notifyInterests = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final user = await _userRepository.getCurrentUser();
      isProfileVisible.value = user['isProfileVisible'] ?? true;
      notifyNewMatches.value = user['notifyNewMatches'] ?? true;
      notifyNewMessages.value = user['notifyNewMessages'] ?? true;
      notifyInterests.value = user['notifyInterests'] ?? true;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updatePrivacy(bool value) async {
    isProfileVisible.value = value;
    await _userRepository.updateBasicDetails({'isProfileVisible': value});
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    switch (key) {
      case 'matches':
        notifyNewMatches.value = value;
        break;
      case 'messages':
        notifyNewMessages.value = value;
        break;
      case 'interests':
        notifyInterests.value = value;
        break;
    }
    await _userRepository.updateBasicDetails({'notify$key': value});
  }

  Future<void> changePassword() async {
    // Navigate to change password or show dialog
    Get.snackbar('Info', 'Password change link sent to your email');
    final email = _authRepository.currentUser?.email;
    if (email != null) {
      await _authRepository.sendPasswordResetEmail(email);
    }
  }

  Future<void> deleteAccount() async {
    // Show confirmation dialog
    Get.dialog(
      // ... dialog implementation
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed('/login');
  }
}
