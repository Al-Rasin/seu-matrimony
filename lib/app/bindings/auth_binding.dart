import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../modules/auth/login/login_controller.dart';
import '../../modules/auth/register/register_controller.dart';
import '../../modules/auth/forgot_password/forgot_password_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
