import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController
    with GetTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;

  final RxInt currentIndex = 0.obs;
  final RxBool isAnimating = false.obs;

  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      image:
          'assets/images/2012.i201.008.online_sale_outlet_isometric [Converted]-01 1.png', // Your first image path
      title: 'PITCH STUDIO',
      subtitle: 'DESIGN HIGH-QUALITY VIDEOS WITH SMART AI ENHANCEMENTS.',
      description:
          'LET THE APP GUIDE YOU THROUGH STORYBOARD AND CREATE EXCITING CONTENT.',
    ),
    OnboardingData(
      image:
          'assets/images/26601499_85z_2201_w009_n001_95c_p6_95 [Converted]-01 1.png', // Your second image path
      title: 'BUILD YOUR BUSINESS PROPOSAL',
      subtitle: 'GET SMART INSTANT RESPONSES AND TEXT.',
      description: 'CHAT WITH AI TO GUIDE, LEARN, OR CREATE EFFORTLESSLY.',
    ),
    OnboardingData(
      image:
          'assets/images/26761515_2106.i201.011.S.m004.c13.chatbot messenger AI isometric-01 [Converted]-01 1.png', // Your third image path
      title: 'PitchPal Store',
      subtitle: 'SHOP SEAMLESSLY WITHOUT LEAVING THE APP.',
      description: 'EXPLORE AND PURCHASE YOUR FAVORITES AT ONE PLACE.',
    ),
  ];

  // Animation getters
  AnimationController get fadeController => _fadeController;
  AnimationController get slideController => _slideController;
  AnimationController get scaleController => _scaleController;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _initializeAnimations();
    _startInitialAnimation();
  }

  void _initializeControllers() {
    pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startInitialAnimation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  void nextPage() async {
    if (isAnimating.value) return;

    if (currentIndex.value < onboardingPages.length - 1) {
      _animateToPage(currentIndex.value + 1);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('onboard', 'true');
      // Navigate to main app
      Get.offNamed(Routes.AUTH_INSTANCE_CHECKER);
    }
  }

  void previousPage() {
    if (isAnimating.value || currentIndex.value == 0) return;
    _animateToPage(currentIndex.value - 1);
  }

  void _animateToPage(int index) async {
    isAnimating.value = true;

    // Fade out current content
    await _fadeController.reverse();

    // Change page
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    currentIndex.value = index;

    // Fade in new content
    await _fadeController.forward();

    isAnimating.value = false;
  }

  void skipToEnd() {
    Get.offNamed(Routes.AUTHENTCATION);
  }

  @override
  void onClose() {
    pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.onClose();
  }
}

// onboarding_data.dart
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
