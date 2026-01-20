import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../modules/admin/dashboard/admin_dashboard_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
  }
}
