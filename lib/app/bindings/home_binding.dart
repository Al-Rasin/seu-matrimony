import 'package:get/get.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../modules/home/home_controller.dart';
import '../../modules/home/dashboard/dashboard_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<MatchRepository>(() => MatchRepository());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
