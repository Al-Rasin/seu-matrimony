import 'package:get/get.dart';
import '../../data/repositories/user_repository.dart';
import '../../modules/registration/registration_controller.dart';
import '../../modules/profile/my_profile/my_profile_controller.dart';
import '../../modules/profile/edit_profile/edit_profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<RegistrationController>(() => RegistrationController());
    Get.lazyPut<MyProfileController>(() => MyProfileController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
