import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/settings/controllers/settings_controller.dart';

class SecurityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Security alerts - exactly matching the image
  final RxList<SecurityAlert> alerts =
      <SecurityAlert>[
        SecurityAlert(
          type: SecurityAlertType.warning,
          title: 'MULTIPLE FAILED LOGIN ATTEMPTS',
          time: '10:22 AM 10/02/2025',
          status: SecurityStatus.warning,
          description:
              'Multiple failed login attempts detected from unknown device',
        ),
        SecurityAlert(
          type: SecurityAlertType.critical,
          title: 'CRITICAL SECURITY BREACH DETECTED',
          time: '10:22 AM 10/02/2025',
          status: SecurityStatus.critical,
          description: 'Unauthorized access attempt detected on your account',
        ),
        SecurityAlert(
          type: SecurityAlertType.location,
          title: 'LAHORE PAKISTAN',
          time: '10:22 AM 10/02/2025',
          subtitle: '10:22 AM 10/02/2025',
          ip: 'IP: 192.168.1.1',
          status: SecurityStatus.success,
          description: 'Successful login from Lahore, Pakistan',
        ),
        SecurityAlert(
          type: SecurityAlertType.location,
          title: 'LAHORE PAKISTAN',
          time: '10:22 AM 10/02/2025',
          subtitle: '10:22 AM 10/02/2025',
          ip: 'IP: 192.168.1.1',
          status: SecurityStatus.fail,
          description: 'Failed login attempt from Lahore, Pakistan',
        ),
      ].obs;

  // Notification settings
  final RxBool receiveEmailAlerts = true.obs;
  final RxBool isLoading = false.obs;

  // Animation getters
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
  AnimationController get animationController => _animationController;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  void markAsRead(SecurityAlert alert) {
    isLoading.value = true;

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      alert.status = SecurityStatus.read;
      alerts.refresh();
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Alert marked as read',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void investigate(SecurityAlert alert) {
    isLoading.value = true;

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 1000), () {
      alert.status = SecurityStatus.investigating;
      alerts.refresh();
      isLoading.value = false;
      Get.snackbar(
        'Investigation Started',
        'Security team has been notified',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void toggleEmailAlerts() {
    receiveEmailAlerts.value = !receiveEmailAlerts.value;

    Get.snackbar(
      'Email Alerts ${receiveEmailAlerts.value ? 'Enabled' : 'Disabled'}',
      receiveEmailAlerts.value
          ? 'You will receive email notifications for security alerts'
          : 'Email notifications have been disabled',
      backgroundColor: const Color(0xFF4FC3F7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void showAlertDetails(SecurityAlert alert) {
    Get.dialog(
      AlertDialog(
        title: Text(
          alert.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${alert.time}'),
            const SizedBox(height: 8),
            if (alert.subtitle != null) ...[
              Text('Additional Time: ${alert.subtitle}'),
              const SizedBox(height: 8),
            ],
            if (alert.ip != null) ...[
              Text('IP Address: ${alert.ip}'),
              const SizedBox(height: 8),
            ],
            Text('Status: ${_getStatusText(alert.status)}'),
            const SizedBox(height: 8),
            Text('Type: ${_getTypeText(alert.type)}'),
            const SizedBox(height: 12),
            Text(
              alert.description ?? 'No additional details available',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          if (alert.status == SecurityStatus.warning ||
              alert.status == SecurityStatus.critical)
            ElevatedButton(
              onPressed: () {
                Get.back();
                if (alert.status == SecurityStatus.warning) {
                  markAsRead(alert);
                } else {
                  investigate(alert);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    alert.status == SecurityStatus.critical
                        ? Colors.red
                        : const Color(0xFF4FC3F7),
              ),
              child: Text(
                alert.status == SecurityStatus.critical
                    ? 'Investigate'
                    : 'Mark as Read',
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.warning:
        return 'Warning';
      case SecurityStatus.critical:
        return 'Critical';
      case SecurityStatus.success:
        return 'Success';
      case SecurityStatus.fail:
        return 'Failed';
      case SecurityStatus.read:
        return 'Read';
      case SecurityStatus.investigating:
        return 'Under Investigation';
      default:
        return 'Unknown';
    }
  }

  String _getTypeText(SecurityAlertType type) {
    switch (type) {
      case SecurityAlertType.warning:
        return 'Security Warning';
      case SecurityAlertType.critical:
        return 'Critical Alert';
      case SecurityAlertType.location:
        return 'Location Access';
      default:
        return 'Unknown';
    }
  }

  void refreshAlerts() async {
    isLoading.value = true;

    // Simulate API call to refresh alerts
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;
    Get.snackbar(
      'Refreshed',
      'Security alerts updated',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }
}
