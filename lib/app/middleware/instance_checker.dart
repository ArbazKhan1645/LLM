// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';

class AuthInstanceCheck extends StatefulWidget {
  const AuthInstanceCheck({super.key});

  @override
  State<AuthInstanceCheck> createState() => _AuthInstanceCheckState();
}

class _AuthInstanceCheckState extends State<AuthInstanceCheck> {
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    try {
      // Wait a bit for Firebase to fully initialize
      await Future.delayed(const Duration(milliseconds: 400));

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Get.offNamed(
          user.email == 'admin@admin.com'
              ? Routes.ADMIN_DASHBOARD
              : Routes.DASHBOARD,
        );
      } else {
        Get.offNamed(Routes.AUTHENTCATION);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Authentication error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });
    _checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return _buildErrorView();
    }

    return _buildShimmerLoading();
  }

  Widget _buildErrorView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _retry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header shimmer
          _buildShimmerHeader(),

          // Body content shimmer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Options grid shimmer
                  _buildShimmerOptionsGrid(),
                ],
              ),
            ),
          ),

          // Bottom navigation shimmer
          _buildShimmerBottomNav(),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildShimmerBox(50, 50, borderRadius: 25),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerBox(100, 16, borderRadius: 8),
                    const SizedBox(height: 8),
                    _buildShimmerBox(150, 14, borderRadius: 7),
                  ],
                ),
              ),
              _buildShimmerBox(40, 40, borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerOptionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShimmerBox(40, 40, borderRadius: 20),
                const SizedBox(height: 12),
                _buildShimmerBox(80, 14, borderRadius: 7),
                const SizedBox(height: 6),
                _buildShimmerBox(60, 12, borderRadius: 6),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerBottomNav() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerBox(24, 24, borderRadius: 12),
                  const SizedBox(height: 4),
                  _buildShimmerBox(40, 10, borderRadius: 5),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: _buildShimmerAnimation(),
    );
  }

  Widget _buildShimmerAnimation() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
