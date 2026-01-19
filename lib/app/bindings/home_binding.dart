import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/interest_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/home/dashboard/dashboard_controller.dart';
import '../../modules/profile/my_profile/my_profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<MatchRepository>(() => MatchRepository());
    Get.lazyPut<InterestRepository>(() => InterestRepository());
    Get.lazyPut<ChatRepository>(() => ChatRepository());

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<MyProfileController>(() => MyProfileController());
  }
}
