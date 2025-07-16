import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_view_controller.dart';

class SplashViewView extends GetView<SplashViewController> {
  const SplashViewView({super.key});
  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashViewController>(
      init: SplashViewController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
              ),
            ),
            child: Column(
              children: [
                // Main content area with blue background
                Expanded(flex: 85, child: _buildMainContent(controller)),

                // Bottom white section with button
                Expanded(flex: 15, child: _buildBottomSection(controller)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(SplashViewController controller) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Bulb Icon
          AnimatedBuilder(
            animation: controller.animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.logoFadeAnimation,
                child: ScaleTransition(
                  scale: controller.logoScaleAnimation,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      'assets/images/Frame 1000006451.png',
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Animated Main Title
          AnimatedBuilder(
            animation: controller.animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.titleFadeAnimation,
                child: SlideTransition(
                  position: controller.titleSlideAnimation,
                  child: const Text(
                    'PITCH DIFFERENT',
                    style: TextStyle(
                      fontSize: 28,
                          fontFamily: 'BebasNeue',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Animated Subtitle
          AnimatedBuilder(
            animation: controller.animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.subtitleFadeAnimation,
                child: const Text(
                  'Simple Tips, Smart Tech.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(SplashViewController controller) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller.bottomFadeAnimation,
          child: SlideTransition(
            position: controller.bottomSlideAnimation,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'CREATE. CONNECT. SHOP.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
