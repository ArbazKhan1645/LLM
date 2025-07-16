import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController  with GetSingleTickerProviderStateMixin {
late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Observables for settings
  final RxString selectedLanguage = 'English'.obs;
  final RxString selectedTimezone = 'UTC+05:00'.obs;
  final RxBool restrictContentAccess = true.obs;
  final RxBool featuredToggle = false.obs;
  final RxBool adminAlerts = true.obs;

  // Role management
  final RxList<UserRole> roles = <UserRole>[
    UserRole(name: 'ADMIN', type: RoleType.admin),
    UserRole(name: 'MODERATOR', type: RoleType.moderator),
    UserRole(name: 'USER', type: RoleType.user),
  ].obs;

  // Animation getters
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  AnimationController get animationController => _animationController;

  // Dropdown options
  final List<String> languages = ['English', 'Urdu', 'Arabic', 'Spanish'];
  final List<String> timezones = ['UTC+05:00', 'UTC+00:00', 'UTC-05:00', 'UTC+08:00'];

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
    Get.snackbar('Language Updated', 'Language changed to $language');
  }

  void selectTimezone(String timezone) {
    selectedTimezone.value = timezone;
    Get.snackbar('Timezone Updated', 'Timezone changed to $timezone');
  }

  void toggleRestrictContentAccess() {
    restrictContentAccess.value = !restrictContentAccess.value;
  }

  void toggleFeaturedToggle() {
    featuredToggle.value = !featuredToggle.value;
  }

  void toggleAdminAlerts() {
    adminAlerts.value = !adminAlerts.value;
  }

  void editRole(UserRole role) {
    Get.toNamed('/edit-role', arguments: role);
  }

  void addNewRole() {
    Get.toNamed('/add-role');
  }

  void navigateToSecurity() {
    Get.toNamed('/security');
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}

// models.dart
enum RoleType { admin, moderator, user }


class UserRole {
  final String name;
  final RoleType type;

  UserRole({required this.name, required this.type});
}

enum SecurityAlertType { warning, critical, location }
enum SecurityStatus { warning, critical, success, fail, read, investigating }

class SecurityAlert {
  final SecurityAlertType type;
  final String title;
  final String time;
  final String? subtitle;
  final String? ip;
  final String? description;
  SecurityStatus status;

  SecurityAlert({
    required this.type,
    required this.title,
    required this.time,
    this.subtitle,
    this.ip,
    this.description,
    required this.status,
  });
}