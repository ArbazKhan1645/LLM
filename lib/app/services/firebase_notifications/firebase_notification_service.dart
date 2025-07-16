// firebase_notification_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/models/notification_model/notification_model.dart';
import 'package:llm_video_shopify/app/modules/notifications/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase Notification Service
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Static avatar paths
  static const List<String> staticAvatars = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
  ];

  // Collections
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';

  // Notification channels
  static const String chatChannelId = 'chat_notifications';
  static const String generalChannelId = 'general_notifications';

  String? _currentUserToken;
  String? _currentUserId;

  // Initialize Firebase Messaging
  Future<void> initialize() async {
    _currentUserId = _auth.currentUser?.uid;

    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get and save FCM token
    await _initializeFCMToken();

    // Setup message handlers
    _setupMessageHandlers();

    // Update user status
    await _updateUserOnlineStatus(true);

    print('Firebase Notification Service initialized successfully');
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      chatChannelId,
      'Chat Notifications',
      description: 'Notifications for chat messages',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          generalChannelId,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
        );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(chatChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  // Initialize FCM token
  Future<void> _initializeFCMToken() async {
    try {
      _currentUserToken = await _firebaseMessaging.getToken();
      if (_currentUserToken != null && _currentUserId != null) {
        await _saveTokenToFirestore(_currentUserToken!, _currentUserId!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        _currentUserToken = token;
        if (_currentUserId != null) {
          await _saveTokenToFirestore(token, _currentUserId!);
        }
      });
    } catch (e) {
      print('Error initializing FCM token: $e');
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token, String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userData = UserModel(
        uid: userId,
        email: user.email.toString(),
        fullName: user.displayName ?? 'User',
        userType: UserType.user,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: '',
        fcmToken: token,
        deviceType: Platform.isAndroid ? 'android' : 'ios',
        lastSeen: DateTime.now(),
        isOnline: true,
        avatar: await _getUserAvatar(userId),
      );

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(userData.toJson(), SetOptions(merge: true));

      // Cache token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      print('FCM token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get user avatar (randomly assign if not set)
  Future<String> _getUserAvatar(String userId) async {
    try {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists && doc.data()?['avatar'] != null) {
        return doc.data()!['avatar'];
      }

      // Assign random avatar
      return staticAvatars[userId.hashCode % staticAvatars.length];
    } catch (e) {
      return staticAvatars[0];
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle terminated app message taps
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessageTap(message);
      }
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Save notification to Firestore
    await _saveNotificationToFirestore(message);
    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle background message tap
  Future<void> _handleBackgroundMessageTap(RemoteMessage message) async {
    print('Message tapped: ${message.messageId}');

    // Navigate to appropriate screen based on message data
    if (message.data['type'] == 'chat') {
      // Navigate to chat screen
      // You can use a navigation service or global navigator key
      _navigateToChat(message.data['senderId'], message.data['chatId']);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    try {
      // Get sender avatar

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            chatChannelId,
            'Chat Notifications',
            channelDescription: 'Notifications for chat messages',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',

            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              contentTitle: notification.title,
              summaryText: 'New message',
            ),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            // actions: [
            //   const AndroidNotificationAction(
            //     'reply',
            //     'Reply',
            //     inputs: [
            //       AndroidNotificationActionInput(label: 'Type a message...'),
            //     ],
            //   ),
            //   const AndroidNotificationAction('mark_read', 'Mark as Read'),
            // ],
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(data),
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);

      if (response.actionId == 'reply') {
        // Handle reply action
        _handleQuickReply(data, response.input);
      } else if (response.actionId == 'mark_read') {
        // Mark as read
        _markNotificationAsRead(data['notificationId']);
      } else {
        // Navigate to chat
        _navigateToChat(data['senderId'], data['chatId']);
      }
    }
  }

  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final data = message.data;
      final notification = NotificationModel(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? 'Unknown',
        receiverId: _currentUserId ?? '',
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        avatar: data['avatar'] ?? staticAvatars[0],
        type: data['type'] ?? 'general',
        data: data,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore
          .collection(notificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());

      print('Notification saved to Firestore');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // UPDATED: Send notification to specific user with proper validation
  Future<bool> sendNotificationToUser({
    required String receiverId,
    required String title,
    required String body,
    required String type,
    String? senderId,
    Map<String, dynamic>? data,
    String? chatId,
  }) async {
    try {
      // Get current user ID
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('BLOCKED: Current user is null, cannot send notification');
        return false;
      }

      // Use provided senderId or fallback to current user
      final actualSenderId = senderId ?? currentUserId;

      // CRITICAL: Prevent sending notification to self
      if (receiverId == actualSenderId || receiverId == currentUserId) {
        print('BLOCKED: Not sending notification to self. Receiver: $receiverId, Sender: $actualSenderId, Current: $currentUserId');
        return false;
      }

      // Double validation that receiverId and senderId are different
      if (receiverId == actualSenderId) {
        print('BLOCKED: Receiver and sender are the same: $receiverId');
        return false;
      }

      print('VALIDATION PASSED: Sending notification from $actualSenderId to $receiverId');

      // Check for duplicate recent notifications (within last 10 seconds)
      final tenSecondsAgo = DateTime.now().subtract(const Duration(seconds: 10));
      final recentNotifications = await _firestore
          .collection(notificationsCollection)
          .where('receiverId', isEqualTo: receiverId)
          .where('senderId', isEqualTo: actualSenderId)
          .where('type', isEqualTo: type)
          .where('timestamp', isGreaterThan: tenSecondsAgo)
          .limit(1)
          .get();

      if (recentNotifications.docs.isNotEmpty) {
        print('BLOCKED: Duplicate notification detected within 10 seconds');
        return false;
      }

      // Get receiver's data
      final receiverDoc =
          await _firestore.collection(usersCollection).doc(receiverId).get();

      if (!receiverDoc.exists) {
        print('BLOCKED: Receiver not found: $receiverId');
        return false;
      }

      final receiverData = UserModel.fromJson(receiverDoc.data()!);
      
      // Get sender data
      final senderData = await _getCurrentUserData();
      if (senderData == null) {
        print('BLOCKED: Sender data not found');
        return false;
      }

      // Final validation - ensure sender and receiver are different users
      if (senderData.uid == receiverData.uid) {
        print('BLOCKED: Sender and receiver are the same user');
        return false;
      }

      // Create unique notification ID to prevent duplicates
      final notificationId = '${actualSenderId}_${receiverId}_${type}_${DateTime.now().millisecondsSinceEpoch}';

      // Prepare notification data
      final notificationData = {
        'senderId': senderData.uid,
        'senderName': senderData.fullName,
        'receiverId': receiverId,
        'type': type,
        'avatar': senderData.avatar,
        'chatId': chatId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'notificationId': notificationId,
        ...?data,
      };

      // Send FCM message only if receiver has a valid token
      bool fcmSuccess = false;
      if (receiverData.fcmToken != null && receiverData.fcmToken!.isNotEmpty) {
        fcmSuccess = await _sendFCMMessage(
          token: receiverData.fcmToken!,
          title: title,
          body: body,
          data: notificationData,
        );
        print('FCM sent: $fcmSuccess');
      } else {
        print('WARNING: Receiver has no FCM token');
      }

      // Always save notification to Firestore for offline users and history
      final notification = NotificationModel(
        id: notificationId,
        senderId: senderData.uid,
        senderName: senderData.fullName,
        receiverId: receiverId,
        title: title,
        body: body,
        avatar: senderData.avatar ?? staticAvatars[0],
        type: type,
        data: notificationData,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .set(notification.toMap());

      print('Notification saved to Firestore with ID: $notificationId');
      print('Final result - FCM: $fcmSuccess, Firestore: true');
      
      return true; // Return true if at least Firestore save was successful
    } catch (e) {
      print('ERROR in sendNotificationToUser: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Send FCM message using HTTP API
  Future<bool> _sendFCMMessage({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get access token using service account credentials
      final accessToken = await _getAccessToken();

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/llm-app-93388/messages:send',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': data.map((key, value) => MapEntry(key, value.toString())), // Convert all values to strings
          },
        }),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
        return true;
      } else {
        print('FCM failed with status: ${response.statusCode}, body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending FCM message: $e');
      return false;
    }
  }

  Future<String> _getAccessToken() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "llm-app-93388",
      "private_key_id": "9b8c1f691e1f815fe705d62a9c4f07cbe94742b5",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQClqKqsgicZ1W72\nB7Uayf/fkoA/vMnVJ2EXO5yShrN2Pkh3gaZJn83WUCspjfX5gVn4737HyttwP37a\nlfSGnOlC5SBiC2NJclnNStzSlxP+GKM8QadD+dArKc2Qw660Usu26A92KNLsX8VM\np3wBHxbOohdoJXz3Um5vpuFj9QUS7onIGu7P1piZSn/RurA1dFontQf4F1vcTREG\n3zbf2d8PMxiruQybFgrDJ6ao1eoljCe7tPPi7IHw5fR8bkUy2vvBEAGVWmBGoGzZ\n8S5jB39aw0mJ2kjnIc6PjhPr7fkb70p+euVTwc7/Kfp6k/W8raKydNuS9MYJfnjL\niJEim4ZNAgMBAAECggEACdH21CUfBkQFwOXyEXV6CpnXqm+Zk14zPjpVbMY5a0AD\n8bmozuJ/RD4aYOs+cpz9ZWllHZjj60KIVZLgHP6+QS3t/oHoT9lMg4P1lTJJiB2T\nx6WosbnkYjqnKfa/q4bg9qXJDNscrdB7lLC1BCgApR0swArA3rRvQYUmBVPoChgr\nV3ViKJPqhdkePTsGlqWW8T6D4UlEtQXQSIrwshhxxl/Nh1zcfoFZM3HegDVT6ygi\nHjxeSx61qgDGspu1WUJ2acX6vr9qgQMXohgPAwVff5H0Mu92piCwSmiA9IixZ+dk\nkNq4pmQqQuUqfcqDQTXa/bR2Q9k5D1ifByW/oNrA4QKBgQDmOq73ovy2Ja7RpzPm\nB+JBYat52KJJyUQB+dy8dbTCdJvpi2DjAmM5swExheA0IdZQMLwTGZx6F2DsohwL\nSynqPhNYrC0DXPJA9VjSnt2GqtcQ64CSLe1xeM8pLGYyvtGhzesbn5FCbEWF8oUK\nEfj2xPZZJ9fab8fBvx96T/+19QKBgQC4M7EMVHLiiHRV6RNrpBpkwsdB1IaId7AU\nwpmf1yAL4O2DIYE5YxIekY/1S9NfIjdOdULG25Cv9ySllC7HHnZgxGTvw++rTIx0\n9SesBT4I94UtbH2Wdkymr8QqIttEYWmJ1bUNCmRMlhfT0VUpOwHi+oLtJaDH+tz5\nnfxxpsN/+QKBgQDbQhwLvu9JUQ3yoHgupGd3uNqjygqUltbrwtfTq42ge4lYm+KD\nj2yMMMv8K/Ff9LGz4RXcYtHA/K7T7Xcj0ktyx/eIxUCBKW2VK5OR0rZKYD094eqq\nTI8LN/Ci16PkxBHFNOSphAfE6HQ1osfM1VzzNpUeR3GsmDP3cls6EyIGWQKBgQCp\nKjfPxgKYDo8gkuPV+CiRHtxVlbNTwu9/sVPamnuAzTnzMqL1rAlo72+Q6+kbtlWq\nhUAlVmGjaMpMEjF/hnda2SKFm6EQ5UUc6ERd05asL30sQTV5J/2vGz6BH+/U9c0x\n24ThjAie2Tzat6WJLvrFlCEHX4YwAjBMQg4j5e4nKQKBgDkcxCV5Lo38DCKN79um\nlWwjmTeEnpzbJb3QTYjXJn651fxCilEC80ar2KSPor8MTsaDRecS/4EoyS3Qqa8F\n40PqFBPhRx0Og2Q5Rba4rRBPiKHeJJsw+Vnm9+sjC4TZAOEQBZyTHsMxXHYzPV2P\nTb48It+ngUOVO0x2CKHeZ/NM\n-----END PRIVATE KEY-----\n",
      "client_email": "fcm-server@llm-app-93388.iam.gserviceaccount.com",
      "client_id": "115574550694982078996",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/fcm-server%40llm-app-93388.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    });

    final client = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    return client.credentials.accessToken.data;
  }

  // Get current user data
  Future<UserModel?> _getCurrentUserData() async {
    try {
      if (_currentUserId == null) return null;

      final doc =
          await _firestore
              .collection(usersCollection)
              .doc(_currentUserId!)
              .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // Get user notifications stream
  Stream<List<NotificationModel>> getUserNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(notificationsCollection)
        .where('receiverId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => NotificationModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Mark notification as read
  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Update user online status
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    if (_currentUserId == null) return;

    try {
      await _firestore.collection(usersCollection).doc(_currentUserId!).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  // Handle quick reply
  Future<void> _handleQuickReply(
    Map<String, dynamic> data,
    String? reply,
  ) async {
    if (reply == null || reply.isEmpty) return;

    // Send reply message
    await sendNotificationToUser(
      receiverId: data['senderId'],
      title: 'New message',
      body: reply,
      type: 'chat',
      chatId: data['chatId'],
    );
  }

  // Navigate to chat (implement based on your navigation)
  void _navigateToChat(String? senderId, String? chatId) {
    // Implement navigation to chat screen
    Get.to(() => NotificationScreen());
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    if (_currentUserId == null) return 0;

    try {
      final snapshot =
          await _firestore
              .collection(notificationsCollection)
              .where('receiverId', isEqualTo: _currentUserId)
              .where('isRead', isEqualTo: false)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Clean up duplicate notifications
  Future<void> cleanupDuplicateNotifications() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Get all notifications for current user
      final notifications = await _firestore
          .collection(notificationsCollection)
          .where('receiverId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      final Map<String, List<QueryDocumentSnapshot>> grouped = {};
      
      // Group by sender + type + approximate time (within 10 seconds)
      for (final doc in notifications.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final type = data['type'] as String? ?? '';
        final timestamp = data['timestamp'] as Timestamp?;
        final timeInMillis = timestamp?.millisecondsSinceEpoch ?? 0;
        final timeGroup = (timeInMillis / 10000).floor(); // 10 second groups
        
        final key = '${senderId}_${type}_$timeGroup';
        grouped[key] = grouped[key] ?? [];
        grouped[key]!.add(doc);
      }

      // Delete duplicates (keep only the first one in each group)
      final batch = _firestore.batch();
      int deletedCount = 0;
      
      for (final group in grouped.values) {
        if (group.length > 1) {
          // Keep the first, delete the rest
          for (int i = 1; i < group.length; i++) {
            batch.delete(group[i].reference);
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        await batch.commit();
        print('Cleaned up $deletedCount duplicate notifications');
      }
    } catch (e) {
      print('Error cleaning up duplicate notifications: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _updateUserOnlineStatus(false);
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}