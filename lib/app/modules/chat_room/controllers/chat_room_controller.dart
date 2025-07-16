// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room_history.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:llm_video_shopify/app/services/firebase_notifications/firebase_notification_service.dart';
import 'package:uuid/uuid.dart';

// Message Types
enum MessageType { text, video, image, file }

// Message Model
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final String? description;
  final MessageType messageType;
  final String? videoUrl;
  final String? thumbnailUrl;
  final DateTime sentTime;
  final List<String> readBy;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.description,
    required this.messageType,
    this.videoUrl,
    this.thumbnailUrl,
    required this.sentTime,
    required this.readBy,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'description': description,
      'messageType': messageType.toString(),
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'sentTime': sentTime.toIso8601String(),
      'readBy': readBy,
      'isDeleted': isDeleted,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chatRoomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      description: json['description'],
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == json['messageType'],
        orElse: () => MessageType.text,
      ),
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      sentTime: DateTime.parse(json['sentTime']),
      readBy: List<String>.from(json['readBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  bool get isRead => readBy.isNotEmpty;

  ChatMessage copyWith({List<String>? readBy, bool? isDeleted}) {
    return ChatMessage(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      description: description,
      messageType: messageType,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      sentTime: sentTime,
      readBy: readBy ?? this.readBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

// Chat Room Model
class ChatRoom {
  final String id;
  final List<String> participants;
  final List<UserModel> participantDetails;
  final String? lastMessage;
  final MessageType? lastMessageType;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isGroup;
  final String? groupName;
  final String? groupImageUrl;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.participantDetails,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.lastMessageSender,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
    required this.isGroup,
    this.groupName,
    this.groupImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'participantDetails':
          participantDetails.map((user) => user.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType?.toString(),
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSender': lastMessageSender,
      'unreadCounts':
          unreadCounts, // This will be stored as Map<String, dynamic> in Firestore
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      participantDetails:
          (json['participantDetails'] as List)
              .map((user) => UserModel.fromJson(user))
              .toList(),
      lastMessage: json['lastMessage'],
      lastMessageType:
          json['lastMessageType'] != null
              ? MessageType.values.firstWhere(
                (e) => e.toString() == json['lastMessageType'],
                orElse: () => MessageType.text,
              )
              : null,
      lastMessageTime:
          json['lastMessageTime'] != null
              ? DateTime.parse(json['lastMessageTime'])
              : null,
      lastMessageSender: json['lastMessageSender'],
      // Safe type conversion for unreadCounts
      unreadCounts:
          json['unreadCounts'] != null
              ? Map<String, int>.from(
                (json['unreadCounts'] as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, (value as num).toInt()),
                ),
              )
              : <String, int>{},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupImageUrl: json['groupImageUrl'],
    );
  }

  String getChatName(String currentUserId) {
    if (isGroup) {
      return groupName ?? 'Group Chat';
    }

    final otherUser = participantDetails.firstWhere(
      (user) => user.uid != currentUserId,
      orElse: () => participantDetails.first,
    );
    return otherUser.fullName;
  }

  String getChatImage(String currentUserId) {
    if (isGroup) {
      return groupImageUrl ?? '';
    }

    final otherUser = participantDetails.firstWhere(
      (user) => user.uid != currentUserId,
      orElse: () => participantDetails.first,
    );
    return otherUser.avatar ?? '';
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}

// Chat Controller
// Chat Controller
// Chat Controller
class ChatRoomController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Text controllers
  final TextEditingController emailSearchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Observable variables
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxList<UserModel> selectedUsers = <UserModel>[].obs;
  final RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  final RxList<ChatMessage> currentChatMessages = <ChatMessage>[].obs;

  final RxBool isSearching = RxBool(false);
  final RxBool isLoadingChats = RxBool(false);
  final RxBool isSendingMessage = RxBool(false);
  final RxString searchQuery = RxString('');

  // Current chat room
  final Rx<ChatRoom?> currentChatRoom = Rx<ChatRoom?>(null);
  final Rx<User?> currentUser = Rx<User?>(null);

  // Stream subscriptions for real-time listening
  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  StreamSubscription<QuerySnapshot>? _currentChatMessagesSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
    _startChatRoomsListener();

    // Listen to search query changes
    debounce(
      searchQuery,
      _searchUsers,
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    emailSearchController.dispose();
    messageController.dispose();
    _chatRoomsSubscription?.cancel();
    _currentChatMessagesSubscription?.cancel();
    super.onClose();
  }

  // Check authentication state
  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      if (user != null) {
        _updateUserOnlineStatus(true);
        _startChatRoomsListener();
      } else {
        _chatRoomsSubscription?.cancel();
        _currentChatMessagesSubscription?.cancel();
        chatRooms.clear();
        currentChatMessages.clear();
      }
    });
  }

  // Start real-time chat rooms listener
  void _startChatRoomsListener() {
    if (currentUser.value == null) return;

    _chatRoomsSubscription?.cancel();

    _chatRoomsSubscription = _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUser.value!.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final rooms =
                snapshot.docs
                    .map((doc) => ChatRoom.fromJson(doc.data()))
                    .toList();
            chatRooms.value = rooms;
          },
          onError: (error) {
            print('Error listening to chat rooms: $error');
            _showErrorSnackbar('Connection Error', 'Failed to sync chat rooms');
          },
        );
  }

  // Start real-time messages listener for current chat room
  void _startCurrentChatMessagesListener(String chatRoomId) {
    _currentChatMessagesSubscription?.cancel();

    _currentChatMessagesSubscription = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'sentTime',
          descending: false,
        ) // Changed to ascending for chronological order
        .snapshots()
        .listen(
          (snapshot) {
            final messages =
                snapshot.docs
                    .map((doc) => ChatMessage.fromJson(doc.data()))
                    .toList();
            currentChatMessages.value = messages;
          },
          onError: (error) {
            print('Error listening to messages: $error');
            _showErrorSnackbar('Connection Error', 'Failed to sync messages');
          },
        );
  }

  // Update user online status
  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    if (currentUser.value != null) {
      try {
        await _firestore.collection('users').doc(currentUser.value!.uid).update(
          {'isOnline': isOnline, 'lastSeen': DateTime.now().toIso8601String()},
        );
      } catch (e) {
        print('Error updating online status: $e');
      }
    }
  }

  // Search users by email
  Future<void> searchUserByEmail(String email) async {
    if (email.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    searchQuery.value = email.trim();
  }

  Future<void> _searchUsers(String email) async {
    if (email.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      // Search by email
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email.toLowerCase())
              .limit(1)
              .get();

      final List<UserModel> results = [];

      for (var doc in emailQuery.docs) {
        final userData = doc.data();
        if (userData['uid'] != currentUser.value?.uid) {
          results.add(UserModel.fromJson(userData));
        }
      }

      // If no exact email match, search by partial email
      if (results.isEmpty && email.contains('@')) {
        final partialQuery =
            await _firestore
                .collection('users')
                .where('email', isGreaterThanOrEqualTo: email.toLowerCase())
                .where('email', isLessThan: '${email.toLowerCase()}\uf8ff')
                .limit(5)
                .get();

        for (var doc in partialQuery.docs) {
          final userData = doc.data();
          if (userData['uid'] != currentUser.value?.uid) {
            results.add(UserModel.fromJson(userData));
          }
        }
      }

      searchResults.value = results;

      if (results.isEmpty) {
        _showErrorSnackbar('No User Found', 'No user found with email: $email');
      }
    } catch (e) {
      _showErrorSnackbar('Search Failed', 'Failed to search users: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // Add user to selected list
  void addUserToSelected(UserModel user) {
    if (!selectedUsers.any((u) => u.uid == user.uid)) {
      selectedUsers.add(user);
      emailSearchController.clear();
      searchResults.clear();
      searchQuery.value = '';
    }
  }

  // Remove user from selected list
  void removeUserFromSelected(UserModel user) {
    selectedUsers.removeWhere((u) => u.uid == user.uid);
    update();
  }

  // Clear selected users
  void clearSelectedUsers() {
    selectedUsers.clear();
    emailSearchController.clear();
    searchResults.clear();
    searchQuery.value = '';
  }

  // Send video to selected users
  // Send video to selected users
  Future<void> sendVideoToSelectedUsers({
    required String videoUrl,
    required String description,
    String? thumbnailUrl,
  }) async {
    if (selectedUsers.isEmpty) {
      _showErrorSnackbar(
        'No Recipients',
        'Please select at least one user to send the video',
      );
      return;
    }

    if (currentUser.value == null) {
      _showErrorSnackbar(
        'Authentication Error',
        'Please sign in to send videos',
      );
      return;
    }

    // Show loading dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissing by back button
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Sending video...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we send your video to ${selectedUsers.length} recipient${selectedUsers.length > 1 ? 's' : ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    isSendingMessage.value = true;

    try {
      // Store the count before clearing
      final recipientCount = selectedUsers.length;

      // Create chat rooms and send messages
      for (final user in selectedUsers) {
        await _sendVideoToUser(
          recipient: user,
          videoUrl: videoUrl,
          description: description,
          thumbnailUrl: thumbnailUrl,
        );
      }

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Clear selected users
      clearSelectedUsers();

      // Navigate back to first route
      Get.until((route) => route.isFirst);
      Get.delete<VideoScriptController>();
      Get.put(VideoScriptController());
      // Get.delete<ChatRoomController>();
      Get.to(() => ChatRoomHistoryScreen());

      // Show success snackbar
      _showSuccessSnackbar(
        'Video Sent!',
        'Video sent successfully to $recipientCount user${recipientCount > 1 ? 's' : ''}',
      );
    } catch (e) {
      print('Error sending video: $e');

      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error snackbar
      _showErrorSnackbar(
        'Send Failed',
        'Failed to send video: ${e.toString()}',
      );
    } finally {
      isSendingMessage.value = false;
      print('Sending message process completed');
    }
  }

  // Send video to a specific user
  Future<void> _sendVideoToUser({
    required UserModel recipient,
    required String videoUrl,
    required String description,
    String? thumbnailUrl,
  }) async {
    try {
      final existingRoomQuery =
          await _firestore
              .collection('chat_rooms')
              .where('participants', arrayContains: currentUser.value!.uid)
              .where('isGroup', isEqualTo: false)
              .get();

      ChatRoom? existingRoom;
      for (var doc in existingRoomQuery.docs) {
        final roomData = doc.data();
        final participants = List<String>.from(roomData['participants']);
        if (participants.contains(recipient.uid) && participants.length == 2) {
          existingRoom = ChatRoom.fromJson(roomData);
          break;
        }
      }

      String chatRoomId;
      if (existingRoom != null) {
        chatRoomId = existingRoom.id;
      } else {
        chatRoomId = _uuid.v4();

        final currentUserData =
            await _firestore
                .collection('users')
                .doc(currentUser.value!.uid)
                .get();

        final currentChatUser = UserModel.fromJson(currentUserData.data()!);

        final chatRoom = ChatRoom(
          id: chatRoomId,
          participants: [currentUser.value!.uid, recipient.uid],
          participantDetails: [currentChatUser, recipient],
          unreadCounts: <String, int>{
            currentUser.value!.uid: 0,
            recipient.uid: 0,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isGroup: false,
        );

        await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .set(chatRoom.toJson());
      }

      final messageId = _uuid.v4();
      final message = ChatMessage(
        id: messageId,
        chatRoomId: chatRoomId,
        senderId: currentUser.value!.uid,
        senderName: currentUser.value!.displayName ?? currentUser.value!.email!,
        content: 'Sent a video',
        description: description,
        messageType: MessageType.video,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        sentTime: DateTime.now(),
        readBy: [currentUser.value!.uid], // Mark as read by sender immediately
      );

      // Use batch write to ensure atomicity
      final batch = _firestore.batch();

      // Add message
      final messageRef = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);
      batch.set(messageRef, message.toJson());

      // Update chat room with last message and unread count
      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      batch.update(chatRoomRef, {
        'lastMessage': 'Sent a video',
        'lastMessageType': MessageType.video.toString(),
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageSender': currentUser.value!.uid,
        'updatedAt': DateTime.now().toIso8601String(),
        'unreadCounts.${recipient.uid}': FieldValue.increment(1),
      });

      // Execute batch
      await batch.commit();

      // Send notification AFTER the message is saved - ONLY if recipient is different from sender
      if (recipient.uid != currentUser.value!.uid) {
        try {
          FirebaseNotificationService notificationService =
              FirebaseNotificationService();
          await notificationService.sendNotificationToUser(
            receiverId: recipient.uid,
            title:
                'New video from ${currentUser.value!.displayName ?? 'Someone'}',
            body: 'Sent a video',
            type: 'chat',

            data: {'chatRoomId': chatRoomId, 'messageType': 'video'},
          );
          print(
            'Notification sent to ${recipient.uid} from ${currentUser.value!.uid}',
          );
        } catch (notificationError) {
          print('Error sending notification: $notificationError');
          // Don't throw error for notification failure
        }
      } else {
        print('Skipping notification: recipient is same as sender');
      }
    } catch (e) {
      throw Exception('Failed to send video to ${recipient.fullName}: $e');
    }
  }

  // Load chat rooms (keeping for backward compatibility, but real-time listener will handle this)
  Future<void> loadChatRooms() async {
    if (currentUser.value == null) return;
    // The real-time listener will handle this automatically
    print('Chat rooms are now loaded via real-time listener');
  }

  // Open chat room
  Future<void> openChatRoom(ChatRoom room) async {
    currentChatRoom.value = room;
    _startCurrentChatMessagesListener(room.id);
    await _markMessagesAsRead(room.id);
  }

  // Close current chat room
  void closeChatRoom() {
    currentChatRoom.value = null;
    _currentChatMessagesSubscription?.cancel();
    currentChatMessages.clear();
  }

  // Mark messages as read
  Future<void> _markMessagesAsRead(String chatRoomId) async {
    if (currentUser.value == null) return;

    try {
      // Reset unread count for current user
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'unreadCounts.${currentUser.value!.uid}': 0,
      });

      // Mark unread messages as read
      final unreadMessagesQuery =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where(
                'readBy',
                whereNotIn: [
                  [currentUser.value!.uid],
                ],
              )
              .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessagesQuery.docs) {
        final readBy = List<String>.from(doc.data()['readBy'] ?? []);
        if (!readBy.contains(currentUser.value!.uid)) {
          readBy.add(currentUser.value!.uid);
          batch.update(doc.reference, {'readBy': readBy});
        }
      }

      if (unreadMessagesQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Send text message
  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty ||
        currentChatRoom.value == null ||
        currentUser.value == null) {
      return;
    }

    try {
      final messageId = _uuid.v4();
      final message = ChatMessage(
        id: messageId,
        chatRoomId: currentChatRoom.value!.id,
        senderId: currentUser.value!.uid,
        senderName: currentUser.value!.displayName ?? currentUser.value!.email!,
        content: content.trim(),
        messageType: MessageType.text,
        sentTime: DateTime.now(),
        readBy: [currentUser.value!.uid], // Mark as read by sender immediately
      );

      // Get other participants for notifications
      final otherParticipants =
          currentChatRoom.value!.participants
              .where((id) => id != currentUser.value!.uid)
              .toList();

      // Use batch write to ensure atomicity
      final batch = _firestore.batch();

      // Add message
      final messageRef = _firestore
          .collection('chat_rooms')
          .doc(currentChatRoom.value!.id)
          .collection('messages')
          .doc(messageId);
      batch.set(messageRef, message.toJson());

      // Update chat room
      final chatRoomRef = _firestore
          .collection('chat_rooms')
          .doc(currentChatRoom.value!.id);

      final Map<String, dynamic> updates = {
        'lastMessage': content.trim(),
        'lastMessageType': MessageType.text.toString(),
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageSender': currentUser.value!.uid,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Increment unread count for other participants
      for (final participantId in otherParticipants) {
        updates['unreadCounts.$participantId'] = FieldValue.increment(1);
      }

      batch.update(chatRoomRef, updates);

      // Execute batch
      await batch.commit();

      // Send notifications to other participants - ONLY to different users
      for (final participantId in otherParticipants) {
        if (participantId != currentUser.value!.uid) {
          try {
            FirebaseNotificationService notificationService =
                FirebaseNotificationService();
            await notificationService.sendNotificationToUser(
              receiverId: participantId,
              title:
                  'New message from ${currentUser.value!.displayName ?? 'Someone'}',
              body:
                  content.length > 50
                      ? '${content.substring(0, 50)}...'
                      : content.trim(),
              type: 'chat',

              data: {
                'chatRoomId': currentChatRoom.value!.id,
                'messageType': 'text',
              },
            );
          } catch (notificationError) {
            print(
              'Error sending notification to $participantId: $notificationError',
            );
          }
        } else {}
      }

      // Clear message controller
      messageController.clear();
    } catch (e) {
      _showErrorSnackbar('Send Failed', 'Failed to send message: $e');
    }
  }

  // Format time
  String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  showerrorSnackBar(String title, String message) {
    return _showErrorSnackbar(title, message);
  }

  // Snackbar helpers
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
