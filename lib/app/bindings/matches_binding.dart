import 'package:get/get.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/interest_repository.dart';
import '../../modules/matches/matches_controller.dart';
import '../../modules/matches/profile_detail/profile_detail_controller.dart';
import '../../modules/matches/filters/filters_controller.dart';

class MatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchRepository>(() => MatchRepository());
    Get.lazyPut<InterestRepository>(() => InterestRepository());
    Get.lazyPut<MatchesController>(() => MatchesController());
    Get.lazyPut<ProfileDetailController>(() => ProfileDetailController());
    Get.lazyPut<FiltersController>(() => FiltersController());
  }
}
