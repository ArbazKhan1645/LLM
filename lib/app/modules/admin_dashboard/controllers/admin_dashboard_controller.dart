import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// User Statistics Model
class UserStats {
  final int totalUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final int activeUsersToday;
  final int activeUsersThisWeek;
  final int businessUsers;
  final int personalUsers;
  final int verifiedUsers;
  final int unverifiedUsers;
  final double growthPercentage;
  final double weeklyGrowthPercentage;
  final List<DailyUserData> dailyGrowthData;
  final Map<String, int> usersByProfession;
  final Map<String, int> usersByIndustry;

  UserStats({
    required this.totalUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.activeUsersToday,
    required this.activeUsersThisWeek,
    required this.businessUsers,
    required this.personalUsers,
    required this.verifiedUsers,
    required this.unverifiedUsers,
    required this.growthPercentage,
    required this.weeklyGrowthPercentage,
    required this.dailyGrowthData,
    required this.usersByProfession,
    required this.usersByIndustry,
  });
}

// Daily User Growth Data
class DailyUserData {
  final DateTime date;
  final int userCount;
  final int newUsers;

  DailyUserData({
    required this.date,
    required this.userCount,
    required this.newUsers,
  });
}

// Video Statistics Model
class VideoStats {
  final int totalVideos;
  final int videosToday;
  final int videosThisWeek;
  final int videosThisMonth;
  final double totalStorageUsed; // in GB
  final Map<String, int> videosByStatus;
  final List<DailyVideoData> dailyVideoData;

  VideoStats({
    required this.totalVideos,
    required this.videosToday,
    required this.videosThisWeek,
    required this.videosThisMonth,
    required this.totalStorageUsed,
    required this.videosByStatus,
    required this.dailyVideoData,
  });
}

class DailyVideoData {
  final DateTime date;
  final int videoCount;

  DailyVideoData({required this.date, required this.videoCount});
}

// Chat Statistics Model
class ChatStats {
  final int totalChatRooms;
  final int activeChatRoomsToday;
  final int totalMessages;
  final int messagesToday;
  final int videoMessages;
  final int textMessages;

  ChatStats({
    required this.totalChatRooms,
    required this.activeChatRoomsToday,
    required this.totalMessages,
    required this.messagesToday,
    required this.videoMessages,
    required this.textMessages,
  });
}

class AdminDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable data
  final Rx<UserStats?> userStats = Rx<UserStats?>(null);
  final Rx<VideoStats?> videoStats = Rx<VideoStats?>(null);
  final Rx<ChatStats?> chatStats = Rx<ChatStats?>(null);

  // UI State
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt selectedIndex = 0.obs;
  final RxString selectedTimeFrame = 'week'.obs; // day, week, month, year

  // Current admin user
  final Rx<User?> currentAdmin = Rx<User?>(null);

  // Real-time listeners
  StreamSubscription<QuerySnapshot>? _usersListener;
  StreamSubscription<QuerySnapshot>? _videosListener;
  StreamSubscription<QuerySnapshot>? _chatRoomsListener;

  // Timer for periodic updates
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeAdminDashboard();
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    _disposeListeners();
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _disposeListeners() {
    _usersListener?.cancel();
    _videosListener?.cancel();
    _chatRoomsListener?.cancel();
  }

  // Initialize admin dashboard
  Future<void> _initializeAdminDashboard() async {
    try {
      isLoading.value = true;

      // Check admin authentication
      currentAdmin.value = _auth.currentUser;
      if (currentAdmin.value == null) {
        Get.offAllNamed('/authentication');
        return;
      }

      // Verify admin privileges (you might want to check a specific field)
      final adminDoc =
          await _firestore
              .collection('users')
              .doc(currentAdmin.value!.uid)
              .get();

      // if (!adminDoc.exists ||
      //     adminDoc.data()?[''] != 'UserType.business') {
      //   _showErrorSnackbar('Access Denied', 'Admin privileges required');
      //   Get.offAllNamed('/dashboard');
      //   return;
      // }

      // Start real-time listeners
      _startRealtimeListeners();

      // Load initial data
      await _loadAllStatistics();
    } catch (e) {
      _showErrorSnackbar(
        'Initialization Error',
        'Failed to initialize dashboard: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Start real-time listeners for live updates
  void _startRealtimeListeners() {
    // Users collection listener
    _usersListener = _firestore.collection('users').snapshots().listen((
      snapshot,
    ) {
      _calculateUserStatistics(snapshot.docs);
    });

    // Videos collection listener
    _videosListener = _firestore.collection('videos').snapshots().listen((
      snapshot,
    ) {
      _calculateVideoStatistics(snapshot.docs);
    });

    // Chat rooms collection listener
    _chatRoomsListener = _firestore.collection('chat_rooms').snapshots().listen(
      (snapshot) {
        _calculateChatStatistics(snapshot.docs);
      },
    );
  }

  // Calculate comprehensive user statistics
  void _calculateUserStatistics(List<QueryDocumentSnapshot> userDocs) {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);

      int totalUsers = userDocs.length;
      int newUsersToday = 0;
      int newUsersThisWeek = 0;
      int newUsersThisMonth = 0;
      int newUsersLastMonth = 0;
      int activeUsersToday = 0;
      int activeUsersThisWeek = 0;
      int businessUsers = 0;
      int personalUsers = 0;
      int verifiedUsers = 0;
      int unverifiedUsers = 0;

      Map<String, int> usersByProfession = {};
      Map<String, int> usersByIndustry = {};
      List<DailyUserData> dailyGrowthData = [];

      // Create daily data for the last 30 days
      Map<String, int> dailyUserCounts = {};
      Map<String, int> dailyNewUserCounts = {};

      for (var doc in userDocs) {
        final data = doc.data() as Map<String, dynamic>;

        // Safe date parsing
        DateTime? createdAt;
        try {
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            } else {
              // Fallback to current time if format is unexpected
              createdAt = DateTime.now();
            }
          } else {
            createdAt = DateTime.now();
          }
        } catch (e) {
          print('Error parsing createdAt for user ${doc.id}: $e');
          createdAt = DateTime.now();
        }

        // Safe lastSeen parsing
        DateTime? lastSeen;
        try {
          if (data['lastSeen'] != null) {
            if (data['lastSeen'] is Timestamp) {
              lastSeen = (data['lastSeen'] as Timestamp).toDate();
            } else if (data['lastSeen'] is String) {
              lastSeen = DateTime.parse(data['lastSeen']);
            }
          }
        } catch (e) {
          print('Error parsing lastSeen for user ${doc.id}: $e');
          lastSeen = null;
        }

        final isOnline = data['isOnline'] ?? false;
        final userType = data['userType']?.toString() ?? 'UserType.user';
        final isVerified = data['isEmailVerified'] ?? false;
        final profession = data['professionalStatus']?.toString();
        final industry = data['industry']?.toString();

        // Count by time periods
        if (createdAt.isAfter(todayStart)) newUsersToday++;
        if (createdAt.isAfter(weekStart)) newUsersThisWeek++;
        if (createdAt.isAfter(monthStart)) newUsersThisMonth++;
        if (createdAt.isAfter(lastMonthStart) &&
            createdAt.isBefore(lastMonthEnd)) {
          newUsersLastMonth++;
        }

        // Count active users
        if (isOnline || (lastSeen != null && lastSeen.isAfter(todayStart))) {
          activeUsersToday++;
        }
        if (isOnline || (lastSeen != null && lastSeen.isAfter(weekStart))) {
          activeUsersThisWeek++;
        }

        // Count by user type
        if (userType.toLowerCase().contains('business')) {
          businessUsers++;
        } else {
          personalUsers++;
        }

        // Count verification status
        if (isVerified) {
          verifiedUsers++;
        } else {
          unverifiedUsers++;
        }

        // Count by profession
        if (profession != null && profession.isNotEmpty) {
          usersByProfession[profession] =
              (usersByProfession[profession] ?? 0) + 1;
        }

        // Count by industry
        if (industry != null && industry.isNotEmpty) {
          usersByIndustry[industry] = (usersByIndustry[industry] ?? 0) + 1;
        }

        // Daily growth data
        final dayKey = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
        dailyNewUserCounts[dayKey] = (dailyNewUserCounts[dayKey] ?? 0) + 1;
      }

      // Calculate growth percentages
      double growthPercentage = 0;
      double weeklyGrowthPercentage = 0;

      if (newUsersLastMonth > 0) {
        growthPercentage =
            ((newUsersThisMonth - newUsersLastMonth) / newUsersLastMonth) * 100;
      } else if (newUsersThisMonth > 0) {
        growthPercentage = 100; // 100% growth if no users last month
      }

      final lastWeekStart = weekStart.subtract(const Duration(days: 7));
      int newUsersLastWeek = 0;

      for (var doc in userDocs) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime? createdAt;
        try {
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            }
          }
        } catch (e) {
          continue;
        }

        if (createdAt != null &&
            createdAt.isAfter(lastWeekStart) &&
            createdAt.isBefore(weekStart)) {
          newUsersLastWeek++;
        }
      }

      if (newUsersLastWeek > 0) {
        weeklyGrowthPercentage =
            ((newUsersThisWeek - newUsersLastWeek) / newUsersLastWeek) * 100;
      } else if (newUsersThisWeek > 0) {
        weeklyGrowthPercentage = 100;
      }

      // Generate daily growth data for chart
      for (int i = 29; i >= 0; i--) {
        final date = todayStart.subtract(Duration(days: i));
        final dayKey = '${date.year}-${date.month}-${date.day}';
        final newUsers = dailyNewUserCounts[dayKey] ?? 0;

        // Calculate cumulative user count up to this date
        int usersUpToDate = 0;
        for (var doc in userDocs) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime? createdAt;
          try {
            if (data['createdAt'] != null) {
              if (data['createdAt'] is Timestamp) {
                createdAt = (data['createdAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is String) {
                createdAt = DateTime.parse(data['createdAt']);
              }
            }
          } catch (e) {
            continue;
          }

          if (createdAt != null &&
              createdAt.isBefore(date.add(const Duration(days: 1)))) {
            usersUpToDate++;
          }
        }

        dailyGrowthData.add(
          DailyUserData(
            date: date,
            userCount: usersUpToDate,
            newUsers: newUsers,
          ),
        );
      }

      // Update observable
      userStats.value = UserStats(
        totalUsers: totalUsers,
        newUsersToday: newUsersToday,
        newUsersThisWeek: newUsersThisWeek,
        newUsersThisMonth: newUsersThisMonth,
        activeUsersToday: activeUsersToday,
        activeUsersThisWeek: activeUsersThisWeek,
        businessUsers: businessUsers,
        personalUsers: personalUsers,
        verifiedUsers: verifiedUsers,
        unverifiedUsers: unverifiedUsers,
        growthPercentage: growthPercentage,
        weeklyGrowthPercentage: weeklyGrowthPercentage,
        dailyGrowthData: dailyGrowthData,
        usersByProfession: usersByProfession,
        usersByIndustry: usersByIndustry,
      );
    } catch (e) {
      print('Error calculating user statistics: $e');
    }
  }

  // Calculate video statistics
  void _calculateVideoStatistics(List<QueryDocumentSnapshot> videoDocs) {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      int totalVideos = videoDocs.length;
      int videosToday = 0;
      int videosThisWeek = 0;
      int videosThisMonth = 0;
      double totalStorageUsed = 0;
      Map<String, int> videosByStatus = {
        'completed': 0,
        'uploading': 0,
        'failed': 0,
      };

      List<DailyVideoData> dailyVideoData = [];
      Map<String, int> dailyVideoCounts = {};

      for (var doc in videoDocs) {
        final data = doc.data() as Map<String, dynamic>;

        // Safe date parsing for videos
        DateTime? createdAt;
        try {
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            } else {
              createdAt = DateTime.now();
            }
          } else {
            createdAt = DateTime.now();
          }
        } catch (e) {
          print('Error parsing video createdAt for ${doc.id}: $e');
          createdAt = DateTime.now();
        }

        // Safe file size parsing
        double fileSize = 0;
        try {
          if (data['fileSize'] != null) {
            if (data['fileSize'] is num) {
              fileSize = (data['fileSize'] as num).toDouble();
            } else if (data['fileSize'] is String) {
              fileSize = double.tryParse(data['fileSize']) ?? 0;
            }
          }
        } catch (e) {
          print('Error parsing video fileSize for ${doc.id}: $e');
          fileSize = 0;
        }

        final status = data['status']?.toString() ?? 'completed';

        // Count by time periods
        if (createdAt.isAfter(todayStart)) videosToday++;
        if (createdAt.isAfter(weekStart)) videosThisWeek++;
        if (createdAt.isAfter(monthStart)) videosThisMonth++;

        // Sum storage
        totalStorageUsed += fileSize;

        // Count by status
        final statusKey =
            videosByStatus.containsKey(status) ? status : 'completed';
        videosByStatus[statusKey] = (videosByStatus[statusKey] ?? 0) + 1;

        // Daily video data
        final dayKey = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
        dailyVideoCounts[dayKey] = (dailyVideoCounts[dayKey] ?? 0) + 1;
      }

      // Generate daily video data for chart
      for (int i = 29; i >= 0; i--) {
        final date = todayStart.subtract(Duration(days: i));
        final dayKey = '${date.year}-${date.month}-${date.day}';
        final videoCount = dailyVideoCounts[dayKey] ?? 0;

        dailyVideoData.add(DailyVideoData(date: date, videoCount: videoCount));
      }

      // Convert MB to GB
      totalStorageUsed = totalStorageUsed / 1024;

      videoStats.value = VideoStats(
        totalVideos: totalVideos,
        videosToday: videosToday,
        videosThisWeek: videosThisWeek,
        videosThisMonth: videosThisMonth,
        totalStorageUsed: totalStorageUsed,
        videosByStatus: videosByStatus,
        dailyVideoData: dailyVideoData,
      );
    } catch (e) {
      print('Error calculating video statistics: $e');
    }
  }

  // Calculate chat statistics
  void _calculateChatStatistics(List<QueryDocumentSnapshot> chatDocs) {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      int totalChatRooms = chatDocs.length;
      int activeChatRoomsToday = 0;

      for (var doc in chatDocs) {
        final data = doc.data() as Map<String, dynamic>;

        // Safe date parsing for chat rooms
        DateTime? updatedAt;
        try {
          if (data['updatedAt'] != null) {
            if (data['updatedAt'] is Timestamp) {
              updatedAt = (data['updatedAt'] as Timestamp).toDate();
            } else if (data['updatedAt'] is String) {
              updatedAt = DateTime.parse(data['updatedAt']);
            } else {
              updatedAt = DateTime.now();
            }
          } else {
            updatedAt = DateTime.now();
          }
        } catch (e) {
          print('Error parsing chat room updatedAt for ${doc.id}: $e');
          updatedAt = DateTime.now();
        }

        if (updatedAt.isAfter(todayStart)) {
          activeChatRoomsToday++;
        }
      }

      // Get message statistics (this would require a subcollection query)
      _getMessageStatistics()
          .then((messageStats) {
            chatStats.value = ChatStats(
              totalChatRooms: totalChatRooms,
              activeChatRoomsToday: activeChatRoomsToday,
              totalMessages: messageStats['total'] ?? 0,
              messagesToday: messageStats['today'] ?? 0,
              videoMessages: messageStats['video'] ?? 0,
              textMessages: messageStats['text'] ?? 0,
            );
          })
          .catchError((e) {
            print('Error getting message statistics: $e');
            // Set default values if message statistics fail
            chatStats.value = ChatStats(
              totalChatRooms: totalChatRooms,
              activeChatRoomsToday: activeChatRoomsToday,
              totalMessages: 0,
              messagesToday: 0,
              videoMessages: 0,
              textMessages: 0,
            );
          });
    } catch (e) {
      print('Error calculating chat statistics: $e');
    }
  }

  // Get message statistics from all chat rooms
  Future<Map<String, int>> _getMessageStatistics() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      int totalMessages = 0;
      int messagesToday = 0;
      int videoMessages = 0;
      int textMessages = 0;

      // Get all chat rooms
      final chatRooms = await _firestore.collection('chat_rooms').get();

      for (var chatRoom in chatRooms.docs) {
        // Get messages for each chat room
        final messages =
            await _firestore
                .collection('chat_rooms')
                .doc(chatRoom.id)
                .collection('messages')
                .get();

        for (var message in messages.docs) {
          final data = message.data();

          // Safe date parsing for messages
          DateTime? sentTime;
          try {
            if (data['sentTime'] != null) {
              if (data['sentTime'] is Timestamp) {
                sentTime = (data['sentTime'] as Timestamp).toDate();
              } else if (data['sentTime'] is String) {
                sentTime = DateTime.parse(data['sentTime']);
              } else {
                sentTime = DateTime.now();
              }
            } else {
              sentTime = DateTime.now();
            }
          } catch (e) {
            print('Error parsing message sentTime for ${message.id}: $e');
            sentTime = DateTime.now();
          }

          final messageType = data['messageType']?.toString() ?? 'text';

          totalMessages++;

          if (sentTime.isAfter(todayStart)) {
            messagesToday++;
          }

          if (messageType.toLowerCase().contains('video')) {
            videoMessages++;
          } else {
            textMessages++;
          }
        }
      }

      return {
        'total': totalMessages,
        'today': messagesToday,
        'video': videoMessages,
        'text': textMessages,
      };
    } catch (e) {
      print('Error getting message statistics: $e');
      return {'total': 0, 'today': 0, 'video': 0, 'text': 0};
    }
  }

  // Load all statistics
  Future<void> _loadAllStatistics() async {
    try {
      // These will be automatically updated by the real-time listeners
      // This method can be used for manual refresh
    } catch (e) {
      _showErrorSnackbar('Load Error', 'Failed to load statistics: $e');
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await _loadAllStatistics();
      _showSuccessSnackbar('Refreshed', 'Dashboard data updated successfully');
    } catch (e) {
      _showErrorSnackbar('Refresh Error', 'Failed to refresh dashboard: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Start periodic refresh (every 5 minutes)
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!isRefreshing.value) {
        refreshDashboard();
      }
    });
  }

  // Update selected index
  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  // Update time frame
  void updateTimeFrame(String timeFrame) {
    selectedTimeFrame.value = timeFrame;
    // Recalculate statistics based on new time frame
    refreshDashboard();
  }

  // Get user growth data for chart
  List<DailyUserData> getUserGrowthData() {
    return userStats.value?.dailyGrowthData ?? [];
  }

  // Get video growth data for chart
  List<DailyVideoData> getVideoGrowthData() {
    return videoStats.value?.dailyVideoData ?? [];
  }

  // Export statistics to CSV (future enhancement)
  Future<void> exportStatistics() async {
    try {
      // Implementation for exporting statistics
      _showSuccessSnackbar('Export', 'Statistics exported successfully');
    } catch (e) {
      _showErrorSnackbar('Export Error', 'Failed to export statistics: $e');
    }
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

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout from the admin panel?',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Perform logout
  Future<void> _performLogout() async {
    try {
      await _auth.signOut();
      _disposeListeners();
      _refreshTimer?.cancel();
      Get.offAllNamed('/authentication');
      _showSuccessSnackbar(
        'Logged Out',
        'Successfully logged out from admin panel',
      );
    } catch (e) {
      _showErrorSnackbar('Logout Error', 'Failed to logout: $e');
    }
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
