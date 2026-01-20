import 'package:get/get.dart';
import 'app_routes.dart';

// Bindings
import '../bindings/initial_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/matches_binding.dart';
import '../bindings/chat_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/admin_binding.dart';
import '../bindings/notification_binding.dart';
import '../bindings/settings_binding.dart';

// Screens - will be added as we implement them
import '../../modules/splash/splash_screen.dart';
import '../../modules/onboarding/onboarding_screen.dart';
import '../../modules/auth/login/login_screen.dart';
import '../../modules/auth/register/register_screen.dart';
import '../../modules/auth/register/email_verification_screen.dart';
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
import '../../modules/profile/edit_profile/edit_basic_details_screen.dart';
import '../../modules/profile/edit_profile/edit_personal_details_screen.dart';
import '../../modules/profile/edit_profile/edit_professional_details_screen.dart';
import '../../modules/profile/edit_profile/edit_family_details_screen.dart';
import '../../modules/profile/edit_profile/edit_about_screen.dart';
import '../../modules/profile/edit_profile/edit_partner_preferences_screen.dart';
import '../../modules/subscription/subscription_screen.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/settings/privacy_settings/privacy_settings_screen.dart';
import '../../modules/settings/notification_settings/notification_settings_screen.dart';
import '../../modules/settings/blocked_users/blocked_users_screen.dart';
import '../../modules/settings/support/help_support_screen.dart';
import '../../modules/settings/legal/terms_conditions_screen.dart';
import '../../modules/settings/legal/privacy_policy_screen.dart';
import '../../modules/notifications/notifications_screen.dart';
import '../../modules/admin/dashboard/admin_dashboard_screen.dart';
import '../../modules/admin/user_management/user_management_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: AdminBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.adminUserManagement,
      page: () => const UserManagementScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => EmailVerificationScreen(email: Get.arguments ?? ''),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.matches,
      page: () => const MatchesScreen(),
      binding: MatchesBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.profileDetail,
      page: () => const ProfileDetailScreen(),
      binding: MatchesBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.filters,
      page: () => const FiltersScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailScreen(),
      binding: ChatBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => const MyProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editBasicDetails,
      page: () => const EditBasicDetailsScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editPersonalDetails,
      page: () => const EditPersonalDetailsScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editProfessionalDetails,
      page: () => const EditProfessionalDetailsScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editFamilyDetails,
      page: () => const EditFamilyDetailsScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editAbout,
      page: () => const EditAboutScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.editPreferences,
      page: () => const EditPartnerPreferencesScreen(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.privacySettings,
      page: () => const PrivacySettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.blockedUsers,
      page: () => const BlockedUsersScreen(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.helpAndSupport,
      page: () => const HelpSupportScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const TermsConditionsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
