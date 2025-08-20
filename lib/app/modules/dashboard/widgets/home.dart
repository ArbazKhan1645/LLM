import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/llm_built/widgets/store.dart';
import 'package:llm_video_shopify/app/modules/notifications/icon.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/store_home.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:llm_video_shopify/app/services/current_user_service/current_user_service.dart';
import 'package:llm_video_shopify/chat_bot_script.dart';

// Home Controller extending Dashboard functionality
class HomeController extends GetxController {
  // User data
  final RxString userName = (UserService.to.user.value?.fullName ?? 'N/A').obs;
  final RxString userEmail =
      (UserService.to.user.value?.email ?? 'N/A Email').obs;
  final RxString userAvatar = 'assets/images/Ellipse.png'.obs;

  // UI state
  final RxBool isLoading = false.obs;
  final RxInt selectedQuickAction = (-1).obs;

  // Quick actions data
  final List<QuickAction> quickActions = [
    QuickAction(
      id: 'build_proposal',
      title: 'BUILD PROPOSAL',
      subtitle: 'Build professional proposals',
      icon: Icons.description_outlined,
      color: const Color(0xFF4A90E2),
      route: '/chat',
    ),
    QuickAction(
      id: 'record_video',
      title: 'RECORD VIDEO',
      subtitle: 'Add some personalisation to your proposals',
      icon: Icons.videocam_outlined,
      color: const Color(0xFF4A90E2),
      route: '/recording',
    ),
    QuickAction(
      id: 'PitchPal store',
      title: 'PitchPal Store',
      subtitle: 'Boost your look on camera for maximum impact',
      icon: Icons.store_outlined,
      color: const Color(0xFF4A90E2),
      route: '/store',
    ),
    QuickAction(
      id: 'Coming',
      title: 'COMING SOON!',
      subtitle: '',
      icon: Icons.commit_outlined,
      color: const Color(0xFF4A90E2),
      route: '/',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() async {
    isLoading.value = true;

    // In real app, load from API or local storage
    userName.value = UserService.to.user.value?.fullName ?? 'N/A';
    userEmail.value = UserService.to.user.value?.email ?? 'N/A Email';

    isLoading.value = false;
  }

  void onQuickActionTap(QuickAction action) {
    HapticFeedback.lightImpact();

    // Visual feedback
    selectedQuickAction.value = quickActions.indexOf(action);

    // Reset selection after animation
    Future.delayed(const Duration(milliseconds: 200), () {
      selectedQuickAction.value = -1;
    });

    // Navigate based on action
    _handleNavigation(action);
  }

  void _handleNavigation(QuickAction action) {
    switch (action.id) {
      case 'build_proposal':
        Get.toNamed(Routes.LLM_BUILT);

        break;
      case 'record_video':
        Get.to(() => ZapierChatbotWebView());
        break;
      case 'PitchPal store':
        Get.to(() => ProductListPage());
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'More features will be available soon!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4A90E2),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
    }
  }

  void onProfileTap() {
    HapticFeedback.lightImpact();
    Get.toNamed(Routes.PROFILE);
  }
}

// Quick Action Model
class QuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  QuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// Main Home Screen Widget
class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? _buildLoadingState()
                  : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4A90E2), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Loading your workspace...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 12),
          _buildWelcomeSection(),
          const SizedBox(height: 12),
          _buildQuickActions(),
          const SizedBox(height: 100), // Space for floating nav
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: controller.onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Center(
                child: Text(
                  controller.userName.value.isNotEmpty
                      ? controller.userName.value[0].toUpperCase()
                      : 'U',
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          NotificationIconWidget(),
          // Notification Button
          // GestureDetector(
          //   onTap: controller.onNotificationTap,
          //   child: Container(
          //     width: 44,
          //     height: 44,
          //     decoration: BoxDecoration(
          //       color: Colors.grey[100],
          //       shape: BoxShape.circle,
          //     ),
          //     child: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         Icon(
          //           Icons.notifications_outlined,
          //           color: Colors.grey[700],
          //           size: 24,
          //         ),
          //         // Notification badge
          //         Positioned(
          //           top: 8,
          //           right: 8,
          //           child: Container(
          //             width: 12,
          //             height: 12,
          //             decoration: const BoxDecoration(
          //               color: Color(0xFFFF4757),
          //               shape: BoxShape.circle,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            'WELCOME ${controller.userName.value}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Ready to create amazing content and proposals today?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
      ),
      itemCount: controller.quickActions.length,
      itemBuilder: (context, index) {
        final action = controller.quickActions[index];
        return _buildQuickActionCard(action, index);
      },
    );
  }

  Widget _buildQuickActionCard(QuickAction action, int index) {
    return Obx(
      () => AnimatedScale(
        scale: controller.selectedQuickAction.value == index ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: () => controller.onQuickActionTap(action),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(action.icon, color: action.color, size: 18),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    action.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Subtitle
                  Text(
                    action.subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  // Arrow Icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: action.color,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
