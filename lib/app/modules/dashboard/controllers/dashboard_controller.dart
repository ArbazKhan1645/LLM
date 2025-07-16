import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room_history.dart';
import 'package:llm_video_shopify/app/modules/dashboard/widgets/home.dart';
import 'package:llm_video_shopify/app/modules/profile/views/profile_view.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/views/shopify_store_view.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/store_home.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/users_video_screen.dart';
import 'package:llm_video_shopify/app/services/firebase_notifications/firebase_notification_service.dart';

// Dashboard Controller - Enterprise-level state management
class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Navigation state
  final RxInt selectedIndex = 0.obs;
  final RxBool isNavigationVisible = true.obs;

  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();
  // Animation controllers
  late AnimationController _animationController;

  // Performance optimization
  final RxBool isLoading = false.obs;
  final RxString currentScreenTitle = 'Home'.obs;

  // Screen management
  final List<DashboardScreen> screens = [
    DashboardScreen(
      id: 'home',
      title: 'Home',
      icon: Icons.home_rounded,
      selectedIcon: Icons.home,
    ),
    DashboardScreen(
      id: 'messages',
      title: 'Messages',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      badgeCount: 3,
    ),
    DashboardScreen(
      id: 'videos',
      title: 'Videos',
      icon: Icons.video_library_outlined,
      selectedIcon: Icons.video_library_rounded,
    ),
    DashboardScreen(
      id: 'analytics',
      title: 'Analytics',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
    DashboardScreen(
      id: 'profile',
      title: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeNotificationService();
    _initializeAnimations();
    _updateCurrentScreen();
  }

  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  void changeScreen(int index) {
    if (index == selectedIndex.value) return;

    // Haptic feedback for premium feel
    HapticFeedback.lightImpact();

    selectedIndex.value = index;
    _updateCurrentScreen();

    // Trigger navigation animation
    _animationController.reset();
    _animationController.forward();
  }

  void _updateCurrentScreen() {
    currentScreenTitle.value = screens[selectedIndex.value].title;
  }

  void toggleNavigationVisibility() {
    isNavigationVisible.value = !isNavigationVisible.value;
  }

  // Method to get current screen widget
  Widget getCurrentScreen() {
    switch (selectedIndex.value) {
      case 0:
        return HomeScreen();
      case 1:
        return ChatRoomHistoryScreen();
      case 2:
        return UserVideosScreen();
      case 3:
        return ProductListPage();
      case 4:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}

class DashboardScreen {
  final String id;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;

  DashboardScreen({
    required this.id,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });
}
