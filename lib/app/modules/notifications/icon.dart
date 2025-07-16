// notification_icon_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:llm_video_shopify/app/modules/notifications/screen.dart';
import 'package:llm_video_shopify/app/services/firebase_notifications/firebase_notification_service.dart';

class NotificationIconWidget extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const NotificationIconWidget({
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<int>(
      stream: _getUnreadCountStream(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Padding(
          padding: padding ?? const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              IconButton(
                onPressed: () => _navigateToNotifications(context),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: iconColor ?? Theme.of(context).iconTheme.color,
                  size: iconSize,
                ),
                tooltip: 'Notifications',
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Stream<int> _getUnreadCountStream() {
    return FirebaseNotificationService().getUserNotifications().map(
      (notifications) => notifications.where((n) => !n.isRead).length,
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NotificationScreen()));
  }
}
