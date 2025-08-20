import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    return OnboardingScreen();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      init: OnboardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Top section with image and white background
              Expanded(flex: 55, child: _buildTopSection(controller)),

              // Bottom section with blue background and content
              Expanded(flex: 45, child: _buildBottomSection(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(OnboardingController controller) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: PageView.builder(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.currentIndex.value = index;
        },
        itemCount: controller.onboardingPages.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller.scaleController,
            builder: (context, child) {
              return ScaleTransition(
                scale: controller.scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Main Image
                      Expanded(
                        child: Image.asset(
                          controller.onboardingPages[index].image,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Top Title
                      if (index == 0)
                        FadeTransition(
                          opacity: controller.fadeAnimation,
                          child: const Text(
                            'WHAT YOU CAN DO',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(OnboardingController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF4FC3F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Obx(() {
        final currentPage =
            controller.onboardingPages[controller.currentIndex.value];

        return AnimatedBuilder(
          animation: controller.fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: controller.fadeAnimation,
              child: SlideTransition(
                position: controller.slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Main Title
                      Text(
                        currentPage.title,
                        style: const TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        currentPage.subtitle,
                        style: const TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        currentPage.description,
                        style: const TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                      ),

                      const Spacer(),

                      // Bottom Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page Indicators and Skip
                          Row(
                            children: [
                              // Skip Button
                              GestureDetector(
                                onTap: controller.skipToEnd,
                                child: const Text(
                                  'SKIP',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 40),

                              // Page Indicators
                              Row(
                                children: List.generate(
                                  controller.onboardingPages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width:
                                        controller.currentIndex.value == index
                                            ? 20
                                            : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          controller.currentIndex.value == index
                                              ? Colors.white
                                              : Colors.white54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Next/Get Started Button
                          _buildActionButton(controller),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildActionButton(OnboardingController controller) {
    final isLastPage =
        controller.currentIndex.value == controller.onboardingPages.length - 1;

    return SizedBox(
      width: isLastPage ? 140 : 60,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isLastPage ? Colors.black : Colors.white24,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: controller.nextPage,
            child: Center(
              child:
                  isLastPage
                      ? const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      )
                      : const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
