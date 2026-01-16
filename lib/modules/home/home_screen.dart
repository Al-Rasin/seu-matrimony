import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'dashboard/dashboard_screen.dart';
import '../matches/matches_screen.dart';
import '../chat/chat_list/chat_list_screen.dart';
import '../profile/my_profile/my_profile_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [DashboardScreen(), MatchesScreen(), ChatListScreen(), MyProfileScreen()],
        ),
      ),
      bottomNavigationBar: Obx(() => BottomNavBar(currentIndex: controller.currentIndex.value, onTap: controller.changeTab)),
    );
  }
}
