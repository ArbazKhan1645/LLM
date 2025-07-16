// Main Dashboard Widget
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/dashboard/controllers/dashboard_controller.dart';

class DashboardModule extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Main content area
          Positioned.fill(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(controller.selectedIndex.value),
                  child: controller.getCurrentScreen(),
                ),
              ),
            ),
          ),

          // Floating Navigation Bar
          Positioned(
            bottom: 34,
            left: 20,
            right: 20,
            child: Obx(
              () => AnimatedSlide(
                offset:
                    controller.isNavigationVisible.value
                        ? Offset.zero
                        : const Offset(0, 2),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: FloatingNavigationBar(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Professional Floating Navigation Bar
class FloatingNavigationBar extends StatelessWidget {
  final DashboardController controller;

  const FloatingNavigationBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF36B4E6), Color(0xFF36B4E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              controller.screens.length,
              (index) => _buildNavItem(context, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final screen = controller.screens[index];
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeScreen(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 0,
              height: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Icon
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? screen.selectedIcon : screen.icon,
                color: Colors.white,
                size: isSelected ? 26 : 24,
              ),
            ),

            // Badge for notifications
            // if (screen.badgeCount != null && screen.badgeCount! > 0)
            //   Positioned(
            //     top: 12,
            //     right: 12,
            //     child: Container(
            //       padding: const EdgeInsets.all(4),
            //       decoration: const BoxDecoration(
            //         color: Color(0xFFFF4757),
            //         shape: BoxShape.circle,
            //       ),
            //       constraints: const BoxConstraints(
            //         minWidth: 18,
            //         minHeight: 18,
            //       ),
            //       child: Text(
            //         screen.badgeCount! > 99
            //             ? '99+'
            //             : screen.badgeCount.toString(),
            //         style: const TextStyle(
            //           color: Colors.white,
            //           fontSize: 10,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
