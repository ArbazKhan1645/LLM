import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';

import 'package:llm_video_shopify/app/modules/authentcation/controllers/authentcation_controller.dart';
import 'package:llm_video_shopify/app/modules/authentcation/widgets/signIn_form.dart';
import 'package:llm_video_shopify/app/modules/authentcation/widgets/signUp_form.dart';

class AuthView extends StatefulWidget {
  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late final AuthenticationController controller;
  late final AnimationController _tabAnimationController;
  late final AnimationController _backgroundController;
  late final Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AuthenticationController());

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeOutCubic,
      ),
    );

    _backgroundController.forward();
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _switchTab(bool isSignUp) {
    // Prevent rapid consecutive taps
    if (controller.isSignUp.value != isSignUp) {
      controller.isSignUp.value = isSignUp;
      _tabAnimationController.forward(from: 0);
      
      // Add haptic feedback for better UX
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            child: Column(
              children: [
                _buildModernHeader(size, theme),
                Expanded(child: _buildAnimatedBody()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(Size size, ThemeData theme) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 52),
              _buildLogo(),
              const SizedBox(height: 24),
              _buildTabSelector(size),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.purple[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildTabSelector(Size size) {
    return Obx(() {
      return Container(
        width: size.width * 0.7,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Animated indicator background
            AnimatedAlign(
              duration: const Duration(milliseconds: 250), // Slightly faster
              curve: Curves.easeInOutCubic,
              alignment: controller.isSignUp.value
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: size.width * 0.35,
                height: 44, // Slightly smaller to fit better
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[500]!, Colors.indigo[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Tab buttons
            Row(
              children: [
                // Sign Up Tab
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _switchTab(true),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.blue.withOpacity(0.1),
                      highlightColor: Colors.blue.withOpacity(0.05),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: controller.isSignUp.value
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: controller.isSignUp.value
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 15,
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ),
                    ),
                  ),
                ),
                // Sign In Tab
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _switchTab(false),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.blue.withOpacity(0.1),
                      highlightColor: Colors.blue.withOpacity(0.05),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: !controller.isSignUp.value
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: !controller.isSignUp.value
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 15,
                          ),
                          child: const Text("Sign In"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnimatedBody() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), // Slightly faster
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: controller.isSignUp.value
                      ? const Offset(-0.3, 0.0) // Reduced slide distance
                      : const Offset(0.3, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(controller.isSignUp.value),
              child: controller.isSignUp.value ? SignUpForm() : SignInForm(),
            ),
          ),
        ),
      );
    });
  }
}

// Improved utility class for better state management
class OptimizedAuthController extends GetxController {
  final _isSignUp = false.obs;
  final _isLoading = false.obs;
  final _canSwitch = true.obs; // Debounce flag

  bool get isSignUp => _isSignUp.value;
  bool get isLoading => _isLoading.value;
  bool get canSwitch => _canSwitch.value;

  set isSignUp(bool value) {
    if (_canSwitch.value && _isSignUp.value != value) {
      _isSignUp.value = value;
      _debounceSwitch();
    }
  }

  set isLoading(bool value) => _isLoading.value = value;

  void _debounceSwitch() {
    _canSwitch.value = false;
    Future.delayed(const Duration(milliseconds: 300), () {
      _canSwitch.value = true;
    });
  }

  void switchToSignUp() {
    if (_canSwitch.value) {
      isSignUp = true;
    }
  }

  void switchToSignIn() {
    if (_canSwitch.value) {
      isSignUp = false;
    }
  }

  void toggleAuthMode() {
    if (_canSwitch.value) {
      isSignUp = !isSignUp;
    }
  }
}