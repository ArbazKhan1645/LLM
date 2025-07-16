import 'package:get/get.dart';

import '../middleware/instance_checker.dart';
import '../modules/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/views/admin_dashboard_view.dart';
import '../modules/authentcation/bindings/authentcation_binding.dart';
import '../modules/authentcation/views/authentcation_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat_room/bindings/chat_room_binding.dart';
import '../modules/chat_room/views/chat_room_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/llm_built/bindings/llm_built_binding.dart';
import '../modules/llm_built/views/llm_built_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/reported_list/bindings/reported_list_binding.dart';
import '../modules/reported_list/views/reported_list_view.dart';
import '../modules/security/bindings/security_binding.dart';
import '../modules/security/views/security_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shopify_store/bindings/shopify_store_binding.dart';
import '../modules/shopify_store/views/shopify_store_view.dart';
import '../modules/splash_view/bindings/splash_view_binding.dart';
import '../modules/splash_view/views/splash_view_view.dart';
import '../modules/store/bindings/store_binding.dart';
import '../modules/store/views/store_view.dart';
import '../modules/users_managment/bindings/users_managment_binding.dart';
import '../modules/users_managment/views/users_managment_view.dart';
import '../modules/video_history/bindings/video_history_binding.dart';
import '../modules/video_history/views/video_history_view.dart';
import '../modules/video_script/bindings/video_script_binding.dart';
import '../modules/video_script/views/video_script_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_VIEW;

  static final routes = [
    GetPage(
      name: _Paths.AUTH_INSTANCE_CHECKER,
      page: () => const AuthInstanceCheck(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_VIEW,
      page: () => const SplashViewView(),
      binding: SplashViewBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTCATION,
      page: () => const AuthentcationView(),
      binding: AuthentcationBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_SCRIPT,
      page: () => const VideoScriptView(),
      binding: VideoScriptBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_HISTORY,
      page: () => const VideoHistoryView(),
      binding: VideoHistoryBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.STORE,
      page: () => const StoreView(),
      binding: StoreBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.SECURITY,
      page: () => const SecurityView(),
      binding: SecurityBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: _Paths.REPORTED_LIST,
      page: () => const ReportedListView(),
      binding: ReportedListBinding(),
    ),
    GetPage(
      name: _Paths.USERS_MANAGMENT,
      page: () => const UsersManagmentView(),
      binding: UsersManagmentBinding(),
    ),
    GetPage(
      name: _Paths.LLM_BUILT,
      page: () => const LlmBuiltView(),
      binding: LlmBuiltBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_ROOM,
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
    ),
    GetPage(
      name: _Paths.SHOPIFY_STORE,
      page: () => const ShopifyStoreView(),
      binding: ShopifyStoreBinding(),
    ),
  ];
}
