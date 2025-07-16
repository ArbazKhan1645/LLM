import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/users_managment/views/detail.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';

// Enhanced User Model with Firebase Integration
class UserManagementModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final UserType userType;
  final String? businessName;
  final String? businessLink;
  final String? businessAddress;
  final String? professionalStatus;
  final String? industry;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStatus status;
  final int videoCount;
  final int chatCount;
  final double totalStorageUsed;
  final List<String> bannedBy;
  final DateTime? bannedDate;
  final String? banReason;
  final String? shopifyAccessToken;
  final List<ActivityLogModel> activityLogs;

  UserManagementModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.userType,
    this.businessName,
    this.businessLink,
    this.businessAddress,
    this.professionalStatus,
    this.industry,
    this.profileImageUrl,
    required this.isEmailVerified,
    required this.isOnline,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.videoCount,
    required this.chatCount,
    required this.totalStorageUsed,
    required this.bannedBy,
    this.bannedDate,
    this.banReason,
    this.shopifyAccessToken,
    required this.activityLogs,
  });

  factory UserManagementModel.fromFirestore(
    Map<String, dynamic> userData,
    Map<String, dynamic> userStats,
    List<ActivityLogModel> logs,
  ) {
    return UserManagementModel(
      uid: userData['uid'] ?? '',
      fullName: userData['fullName'] ?? '',
      email: userData['email'] ?? '',
      phoneNumber: userData['phoneNumber'],
      userType: UserType.values.firstWhere(
        (e) => e.toString() == userData['userType'],
        orElse: () => UserType.user,
      ),
      businessName: userData['businessName'],
      businessLink: userData['businessLink'],
      businessAddress: userData['businessAddress'],
      professionalStatus: userData['professionalStatus'],
      industry: userData['industry'],
      profileImageUrl: userData['profileImageUrl'],
      isEmailVerified: userData['isEmailVerified'] ?? false,
      isOnline: userData['isOnline'] ?? false,
      // lastSeen: userData['lastSeen'] != null
      //     ? (userData['lastSeen'] is Timestamp
      //         ? (userData['lastSeen'] as Timestamp).toDate()
      //         : DateTime.parse(userData['lastSeen']))
      //     : null,
      shopifyAccessToken: userData['shopifyAccessToken'],

      createdAt:
          userData['createdAt'] is Timestamp
              ? (userData['createdAt'] as Timestamp).toDate()
              : DateTime.parse(userData['createdAt']),
      updatedAt:
          userData['updatedAt'] is Timestamp
              ? (userData['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(userData['updatedAt']),
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == userData['status'],
        orElse: () => UserStatus.active,
      ),
      videoCount: userStats['videoCount'] ?? 0,
      chatCount: userStats['chatCount'] ?? 0,
      totalStorageUsed: (userStats['totalStorageUsed'] ?? 0.0).toDouble(),
      bannedBy: List<String>.from(userData['bannedBy'] ?? []),
      bannedDate:
          userData['bannedDate'] != null
              ? (userData['bannedDate'] is Timestamp
                  ? (userData['bannedDate'] as Timestamp).toDate()
                  : DateTime.parse(userData['bannedDate']))
              : null,
      banReason: userData['banReason'],
      activityLogs: logs,
    );
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get statusDisplayName {
    switch (status) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.banned:
        return 'BANNED';
      case UserStatus.suspended:
        return 'SUSPENDED';
      case UserStatus.pending:
        return 'PENDING';
    }
  }

  Color get statusColor {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.banned:
        return Colors.red;
      case UserStatus.suspended:
        return Colors.orange;
      case UserStatus.pending:
        return Colors.blue;
    }
  }

  bool get isBanned => status == UserStatus.banned;
  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
}

// User Status Enum
enum UserStatus { active, banned, suspended, pending }

// Activity Log Model
class ActivityLogModel {
  final String id;
  final String userId;
  final String action;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final Map<String, dynamic>? metadata;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.type,
    this.metadata,
  });

  factory ActivityLogModel.fromFirestore(Map<String, dynamic> data) {
    return ActivityLogModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      timestamp:
          data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.parse(data['timestamp']),
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ActivityType.general,
      ),
      metadata: data['metadata'],
    );
  }

  IconData get icon {
    switch (type) {
      case ActivityType.login:
        return Icons.login;
      case ActivityType.videoUpload:
        return Icons.video_call;
      case ActivityType.profileUpdate:
        return Icons.person;
      case ActivityType.chatMessage:
        return Icons.chat;
      case ActivityType.banned:
        return Icons.block;
      case ActivityType.unbanned:
        return Icons.check_circle;
      case ActivityType.suspended:
        return Icons.pause_circle;
      case ActivityType.general:
        return Icons.info;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
}

// Activity Type Enum
enum ActivityType {
  login,
  videoUpload,
  profileUpdate,
  chatMessage,
  banned,
  unbanned,
  suspended,
  general,
}

// Users Management Controller
class UsersManagmentController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable data
  final RxList<UserManagementModel> allUsers = <UserManagementModel>[].obs;
  final RxList<UserManagementModel> filteredUsers = <UserManagementModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingProfile = false.obs;

  // Filters
  final RxString selectedUserType = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString sortBy = 'recent'.obs;

  // Current admin
  final Rx<User?> currentAdmin = Rx<User?>(null);

  // Real-time listener
  StreamSubscription<QuerySnapshot>? _usersListener;

  @override
  void onInit() {
    super.onInit();
    _initializeUserManagement();

    // Listen to search query changes
    debounce<String>(
      searchQuery,
      (_) => _filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _usersListener?.cancel();
    super.onClose();
  }

  // Initialize user management
  Future<void> _initializeUserManagement() async {
    try {
      isLoading.value = true;

      // Check admin authentication
      currentAdmin.value = _auth.currentUser;
      if (currentAdmin.value == null) {
        Get.offAllNamed(Routes.AUTHENTCATION);
        return;
      }

      // // Verify admin privileges
      // final adminDoc =
      //     await _firestore
      //         .collection('users')
      //         .doc(currentAdmin.value!.uid)
      //         .get();

      // if (!adminDoc.exists ||
      //     adminDoc.data()?['userType'] != 'UserType.business') {
      //   _showErrorSnackbar('Access Denied', 'Admin privileges required');
      //   Get.back();
      //   return;
      // }

      // Start real-time user listener
      _startUsersListener();
    } catch (e) {
      _showErrorSnackbar('Initialization Error', 'Failed to initialize: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start real-time users listener
  void _startUsersListener() {
    _usersListener = _firestore.collection('users').snapshots().listen((
      snapshot,
    ) async {
      await _processUsersSnapshot(snapshot);
    });
  }

  // Process users snapshot and load additional data
  Future<void> _processUsersSnapshot(QuerySnapshot snapshot) async {
    try {
      List<UserManagementModel> users = [];

      for (var doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        // Skip current admin
        if (userData['uid'] == currentAdmin.value?.uid) continue;

        // Get user statistics
        final userStats = await _getUserStatistics(userData['uid']);

        // Get recent activity logs
        final activityLogs = await _getUserActivityLogs(userData['uid']);

        // Create user model
        final user = UserManagementModel.fromFirestore(
          userData,
          userStats,
          activityLogs,
        );

        users.add(user);
      }

      allUsers.value = users;
      _filterUsers();
    } catch (e) {
      print('Error processing users snapshot: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> _getUserStatistics(String userId) async {
    try {
      // Get video count
      final videosQuery =
          await _firestore
              .collection('videos')
              .where('userId', isEqualTo: userId)
              .get();

      // Get chat count
      final chatQuery =
          await _firestore
              .collection('chat_rooms')
              .where('participants', arrayContains: userId)
              .get();

      // // Get user stats document
      // final userStatsDoc =
      //     await _firestore.collection('user_stats').doc(userId).get();

      double totalStorage = 0;
      for (var video in videosQuery.docs) {
        final data = video.data();
        totalStorage += (data['fileSize'] ?? 0).toDouble();
      }

      return {
        'videoCount': videosQuery.docs.length,
        'chatCount': chatQuery.docs.length,
        'totalStorageUsed': totalStorage / (1024 * 1024), // Convert to MB
      };
    } catch (e) {
      print('Error getting user statistics for $userId: $e');
      return {'videoCount': 0, 'chatCount': 0, 'totalStorageUsed': 0.0};
    }
  }

  // Get user activity logs
  Future<List<ActivityLogModel>> _getUserActivityLogs(String userId) async {
    try {
      final logsQuery =
          await _firestore
              .collection('activity_logs')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .limit(10)
              .get();

      return logsQuery.docs
          .map((doc) => ActivityLogModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting activity logs for $userId: $e');
      return [];
    }
  }

  // Filter users based on search and filters
  void _filterUsers() {
    List<UserManagementModel> filtered = List.from(allUsers);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered.where((user) {
            return user.fullName.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
          }).toList();
    }

    // Apply user type filter
    if (selectedUserType.value != 'all') {
      filtered =
          filtered.where((user) {
            return user.userType.toString() == selectedUserType.value;
          }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'all') {
      filtered =
          filtered.where((user) {
            return user.status.toString() == selectedStatus.value;
          }).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'email':
        filtered.sort((a, b) => a.email.compareTo(b.email));
        break;
      case 'videos':
        filtered.sort((a, b) => b.videoCount.compareTo(a.videoCount));
        break;
    }

    filteredUsers.value = filtered;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update filters
  void updateUserTypeFilter(String type) {
    selectedUserType.value = type;
    _filterUsers();
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    _filterUsers();
  }

  void updateSortBy(String sort) {
    sortBy.value = sort;
    _filterUsers();
  }

  // Navigate to user profile
  void navigateToUserProfile(UserManagementModel user) {
    Get.to(() => UserProfileScreen(user: user));
  }

  // Ban user
  Future<void> banUser(String userId, String reason) async {
    try {
      isLoadingProfile.value = true;

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.banned.toString(),
        'bannedBy': FieldValue.arrayUnion([currentAdmin.value!.uid]),
        'bannedDate': FieldValue.serverTimestamp(),
        'banReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logUserActivity(
        userId,
        'User Banned',
        'User was banned by admin: $reason',
        ActivityType.banned,
        {'bannedBy': currentAdmin.value!.uid, 'reason': reason},
      );

      _showSuccessSnackbar('User Banned', 'User has been banned successfully');
    } catch (e) {
      _showErrorSnackbar('Ban Failed', 'Failed to ban user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Unban user
  Future<void> unbanUser(String userId) async {
    try {
      isLoadingProfile.value = true;

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.active.toString(),
        'bannedBy': FieldValue.delete(),
        'bannedDate': FieldValue.delete(),
        'banReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logUserActivity(
        userId,
        'User Unbanned',
        'User was unbanned by admin',
        ActivityType.unbanned,
        {'unbannedBy': currentAdmin.value!.uid},
      );

      _showSuccessSnackbar(
        'User Unbanned',
        'User has been unbanned successfully',
      );
    } catch (e) {
      _showErrorSnackbar('Unban Failed', 'Failed to unban user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Suspend user
  Future<void> suspendUser(String userId, String reason, int days) async {
    try {
      isLoadingProfile.value = true;

      final suspendUntil = DateTime.now().add(Duration(days: days));

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.suspended.toString(),
        'suspendedBy': currentAdmin.value!.uid,
        'suspendedDate': FieldValue.serverTimestamp(),
        'suspendUntil': Timestamp.fromDate(suspendUntil),
        'suspendReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logUserActivity(
        userId,
        'User Suspended',
        'User was suspended for $days days: $reason',
        ActivityType.suspended,
        {
          'suspendedBy': currentAdmin.value!.uid,
          'reason': reason,
          'days': days,
          'suspendUntil': suspendUntil.toIso8601String(),
        },
      );

      _showSuccessSnackbar(
        'User Suspended',
        'User has been suspended for $days days',
      );
    } catch (e) {
      _showErrorSnackbar('Suspend Failed', 'Failed to suspend user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Reactivate user
  Future<void> reactivateUser(String userId) async {
    try {
      isLoadingProfile.value = true;

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.active.toString(),
        'suspendedBy': FieldValue.delete(),
        'suspendedDate': FieldValue.delete(),
        'suspendUntil': FieldValue.delete(),
        'suspendReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the action
      await _logUserActivity(
        userId,
        'User Reactivated',
        'User was reactivated by admin',
        ActivityType.general,
        {'reactivatedBy': currentAdmin.value!.uid},
      );

      _showSuccessSnackbar(
        'User Reactivated',
        'User has been reactivated successfully',
      );
    } catch (e) {
      _showErrorSnackbar('Reactivate Failed', 'Failed to reactivate user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      isLoadingProfile.value = true;

      // Delete user data in batches
      await _deleteUserData(userId);

      _showSuccessSnackbar(
        'User Deleted',
        'User account has been permanently deleted',
      );
      Get.back(); // Go back to users list
    } catch (e) {
      _showErrorSnackbar('Delete Failed', 'Failed to delete user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // Delete all user data
  Future<void> _deleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete user document
    batch.delete(_firestore.collection('users').doc(userId));

    // Delete user stats
    batch.delete(_firestore.collection('user_stats').doc(userId));

    // Delete user videos
    final videosQuery =
        await _firestore
            .collection('videos')
            .where('userId', isEqualTo: userId)
            .get();

    for (var doc in videosQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete user chat rooms
    final chatQuery =
        await _firestore
            .collection('chat_rooms')
            .where('participants', arrayContains: userId)
            .get();

    for (var doc in chatQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete activity logs
    final logsQuery =
        await _firestore
            .collection('activity_logs')
            .where('userId', isEqualTo: userId)
            .get();

    for (var doc in logsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Log user activity
  Future<void> _logUserActivity(
    String userId,
    String action,
    String description,
    ActivityType type,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      await _firestore.collection('activity_logs').add({
        'id': _firestore.collection('activity_logs').doc().id,
        'userId': userId,
        'action': action,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type.toString(),
        'metadata': metadata,
        'adminId': currentAdmin.value!.uid,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Refresh users data
  Future<void> refreshUsers() async {
    try {
      isLoading.value = true;
      // The real-time listener will automatically refresh the data
      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccessSnackbar('Refreshed', 'Users data has been refreshed');
    } catch (e) {
      _showErrorSnackbar('Refresh Failed', 'Failed to refresh users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Show ban confirmation dialog
  void showBanDialog(UserManagementModel user) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Ban ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ban this user?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Ban Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (reasonController.text.isNotEmpty) {
                await banUser(user.uid, reasonController.text);
                Get.back();
              } else {
                _showErrorSnackbar(
                  'Invalid Input',
                  'Please provide a ban reason',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Ban User',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Show suspend confirmation dialog
  void showSuspendDialog(UserManagementModel user) {
    final reasonController = TextEditingController();
    final RxInt selectedDays = 7.obs;

    Get.dialog(
      AlertDialog(
        title: Text('Suspend ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How long should this user be suspended?'),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<int>(
                value: selectedDays.value,
                decoration: const InputDecoration(
                  labelText: 'Suspension Duration',
                  border: OutlineInputBorder(),
                ),
                items:
                    [1, 3, 7, 14, 30].map((days) {
                      return DropdownMenuItem(
                        value: days,
                        child: Text('$days day${days > 1 ? 's' : ''}'),
                      );
                    }).toList(),
                onChanged: (value) => selectedDays.value = value ?? 7,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Suspension Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (reasonController.text.isNotEmpty) {
                await suspendUser(
                  user.uid,
                  reasonController.text,
                  selectedDays.value,
                );
                Get.back();
              } else {
                _showErrorSnackbar(
                  'Invalid Input',
                  'Please provide a suspension reason',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Suspend User',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
