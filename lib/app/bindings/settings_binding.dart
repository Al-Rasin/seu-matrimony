import 'package:get/get.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/settings/privacy_settings/privacy_settings_controller.dart';
import '../../modules/settings/notification_settings/notification_settings_controller.dart';
import '../../modules/settings/blocked_users/blocked_users_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<MatchRepository>(() => MatchRepository());
    
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<PrivacySettingsController>(() => PrivacySettingsController());
    Get.lazyPut<NotificationSettingsController>(() => NotificationSettingsController());
    Get.lazyPut<BlockedUsersController>(() => BlockedUsersController());
  }
}
