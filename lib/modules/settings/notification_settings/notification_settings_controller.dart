import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';

class NotificationSettingsController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final isLoading = false.obs;
  final notifyNewMatches = true.obs;
  final notifyNewMessages = true.obs;
  final notifyInterests = true.obs;
  final notifyProfileViews = true.obs;
  final notifyAppUpdates = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      isLoading.value = true;
      final user = await _userRepository.getCurrentUser();
      notifyNewMatches.value = user['notifyNewMatches'] ?? true;
      notifyNewMessages.value = user['notifyNewMessages'] ?? true;
      notifyInterests.value = user['notifyInterests'] ?? true;
      notifyProfileViews.value = user['notifyProfileViews'] ?? true;
      notifyAppUpdates.value = user['notifyAppUpdates'] ?? true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notification settings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    try {
      switch (key) {
        case 'NewMatches':
          notifyNewMatches.value = value;
          break;
        case 'NewMessages':
          notifyNewMessages.value = value;
          break;
        case 'Interests':
          notifyInterests.value = value;
          break;
        case 'ProfileViews':
          notifyProfileViews.value = value;
          break;
        case 'AppUpdates':
          notifyAppUpdates.value = value;
          break;
      }
      await _userRepository.updateBasicDetails({'notify$key': value});
    } catch (e) {
      Get.snackbar('Error', 'Failed to update setting');
      // Revert on failure
      _loadNotificationSettings();
    }
  }
}
