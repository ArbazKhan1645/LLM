import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _bottomFadeAnimation;
  late Animation<Offset> _bottomSlideAnimation;

  Timer? _navigationTimer;

  // Getters for animations
  Animation<double> get logoFadeAnimation => _logoFadeAnimation;
  Animation<double> get logoScaleAnimation => _logoScaleAnimation;
  Animation<double> get titleFadeAnimation => _titleFadeAnimation;
  Animation<Offset> get titleSlideAnimation => _titleSlideAnimation;
  Animation<double> get subtitleFadeAnimation => _subtitleFadeAnimation;
  Animation<double> get bottomFadeAnimation => _bottomFadeAnimation;
  Animation<Offset> get bottomSlideAnimation => _bottomSlideAnimation;
  AnimationController get animationController => _animationController;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimationSequence();
    _startNavigationTimer();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations (0.0 - 0.4)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Title animations (0.2 - 0.6)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle animations (0.4 - 0.7)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Bottom section animations (0.6 - 1.0)
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _bottomSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimationSequence() {
    _animationController.forward();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(milliseconds: 3500), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isOnboarding = prefs.get('onboard') ?? '';
    if (isOnboarding.toString().isEmpty) {
      Get.offNamed(Routes.ONBOARDING); // Change this to your desired route
    } else {
      Get.offNamed(Routes.AUTH_INSTANCE_CHECKER);
    }
  }

  @override
  void onClose() {
    _animationController.dispose();
    _navigationTimer?.cancel();
    super.onClose();
  }
}
