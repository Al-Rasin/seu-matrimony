import 'package:get/get.dart';
import 'app_routes.dart';

// Bindings
import '../bindings/initial_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/matches_binding.dart';
import '../bindings/chat_binding.dart';
import '../bindings/profile_binding.dart';

// Screens - will be added as we implement them
import '../../modules/splash/splash_screen.dart';
import '../../modules/onboarding/onboarding_screen.dart';
import '../../modules/auth/login/login_screen.dart';
import '../../modules/auth/register/register_screen.dart';
import '../../modules/auth/forgot_password/forgot_password_screen.dart';
import '../../modules/registration/registration_screen.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/matches/matches_screen.dart';
import '../../modules/matches/profile_detail/profile_detail_screen.dart';
import '../../modules/matches/filters/filters_screen.dart';
import '../../modules/chat/chat_list/chat_list_screen.dart';
import '../../modules/chat/chat_detail/chat_detail_screen.dart';
import '../../modules/profile/my_profile/my_profile_screen.dart';
import '../../modules/profile/edit_profile/edit_profile_screen.dart';
import '../../modules/subscription/subscription_screen.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/notifications/notifications_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.matches,
      page: () => const MatchesScreen(),
      binding: MatchesBinding(),
    ),
    GetPage(
      name: AppRoutes.profileDetail,
      page: () => const ProfileDetailScreen(),
      binding: MatchesBinding(),
    ),
    GetPage(
      name: AppRoutes.filters,
      page: () => const FiltersScreen(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => const MyProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
  ];
}
