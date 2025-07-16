// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:llm_video_shopify/app/services/camera_service/camera_service.dart';
import 'package:llm_video_shopify/app/services/chat_service/chat_service.dart';
import 'package:llm_video_shopify/app/services/storage_service/storage_service.dart';
import 'package:llm_video_shopify/main.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';

// Video Model for Firestore
class VideoModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int duration; // in seconds
  final double fileSize; // in MB
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final String status; // 'uploading', 'completed', 'failed'

  VideoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'status': status,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      fileSize: json['fileSize']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
      status: json['status'] ?? 'completed',
    );
  }
}

class VideoScriptController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services
  CameraService? _cameraService;
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Script related
  final RxString generatedScript = RxString('');
  final RxBool isGeneratingScript = RxBool(false);

  // Recording related
  final RxBool isRecording = RxBool(false);
  final RxBool isPaused = RxBool(false);
  final RxInt recordingDuration = RxInt(0);
  final RxInt actualRecordingDuration = RxInt(0); // Track actual recording time
  final RxInt countdownValue = RxInt(0);
  final RxBool showCountdown = RxBool(false);

  // Camera related
  CameraController? cameraController;
  final RxBool isCameraInitialized = RxBool(false);
  final RxBool isCameraActive = RxBool(false);

  // Video preview
  VideoPlayerController? videoPlayerController;
  final RxString recordedVideoPath = RxString('');
  final RxBool isVideoPlayerInitialized = RxBool(false);

  // Save options
  final RxBool isSaving = RxBool(false);
  final RxBool isUploading = RxBool(false);
  final RxDouble saveProgress = RxDouble(0.0);
  final RxDouble uploadProgress = RxDouble(0.0);
  final RxString uploadStatus = RxString('');

  // User and video management
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxList<VideoModel> userVideos = <VideoModel>[].obs;
  final RxBool isLoadingVideos = RxBool(false);

  // Current video being processed
  final Rx<VideoModel?> currentVideo = Rx<VideoModel?>(null);

  // Track cloud upload status and URL
  final RxBool isVideoSavedToCloud = RxBool(false);
  final RxString lastCloudUploadedVideoUrl = RxString('');
  final RxString currentVideoId = RxString('');

  // Timers and streams
  Timer? _recordingTimer;
  StreamSubscription<User?>? _authSubscription;
  // ignore: unused_field
  DateTime? _recordingStartTime;

  // State management
  bool _isDisposed = false;
  bool _isInitializing = false;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Initialize camera only when screen is ready
    _safeInitializeCamera();
  }

  // MARK: - Initialization Methods

  Future<void> _initializeController() async {
    try {
      _checkAuthState();
      generateScript();
    } catch (e) {
      print('Error initializing controller: $e');
    }
  }

  Future<void> _safeInitializeCamera() async {
    if (_isDisposed || _isInitializing) return;

    _isInitializing = true;
    try {
      await _initializeCameraService();
    } catch (e) {
      print('Error in safe camera initialization: $e');
      _showErrorSnackbar('Camera Error', 'Failed to initialize camera: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initializeCameraService() async {
    try {
      // Dispose existing camera first
      await _disposeCameraResources();

      // Initialize camera service
      _cameraService = CameraService();
      await _cameraService!.initializeCamera();

      if (_isDisposed) return; // Check if disposed during initialization

      cameraController = _cameraService!.cameraController;

      if (cameraController != null && cameraController!.value.isInitialized) {
        isCameraInitialized.value = true;
        isCameraActive.value = true;
        print('Camera initialized successfully');
      } else {
        throw Exception('Camera controller not properly initialized');
      }
    } catch (e) {
      print('Error initializing camera service: $e');
      isCameraInitialized.value = false;
      isCameraActive.value = false;
      rethrow;
    }
  }

  // MARK: - Authentication Methods

  void _checkAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (_isDisposed) return;

      currentUser.value = user;
      if (user != null) {
        loadUserVideos();
      } else {
        userVideos.clear();
        Get.offAllNamed(Routes.AUTHENTCATION);
      }
    });
  }

  bool _isUserAuthenticated() {
    if (currentUser.value == null) {
      _showErrorSnackbar(
        'Authentication Required',
        'Please sign in to continue',
      );
      Get.offAllNamed('/authentication');
      return false;
    }
    return true;
  }

  // MARK: - Script Generation Methods

  Future<void> generateScript() async {
    // if (!_isUserAuthenticated() || _isDisposed) return;

    isGeneratingScript.value = true;

    try {
      final AIChatService apiService = Get.find<AIChatService>();

      // Check if Get.arguments already contains a script
      if (Get.arguments != null) {
        generatedScript.value = Get.arguments;
      } else {
        final response = await apiService.sendMessage(
          message:
              'Generate a random piece of professional business advice to help users improve their proposals or client communications',
        );
        if (!_isDisposed) {
          generatedScript.value = response;
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar(
          'Generation Failed',
          'Failed to generate script: $e',
        );
      }
    } finally {
      if (!_isDisposed) {
        isGeneratingScript.value = false;
      }
    }
  }

  Future<void> regenerateScript() async {
    await generateScript();
  }

  // MARK: - Recording Methods

  Future<void> startCountdownAndRecord() async {
    if (!_isUserAuthenticated() || _isDisposed) return;

    showCountdown.value = true;

    for (int i = 3; i > 0; i--) {
      if (_isDisposed) return;
      countdownValue.value = i;
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!_isDisposed) {
      showCountdown.value = false;
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_isDisposed || !isCameraInitialized.value) return;

    try {
      // Ensure camera is active
      if (!isCameraActive.value) {
        await _safeInitializeCamera();
      }

      await _cameraService?.startRecording();

      if (!_isDisposed) {
        isRecording.value = true;
        _recordingStartTime = DateTime.now();
        _startRecordingTimer();
        _resetVideoSaveStatus();
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (!_isDisposed) {
        _showErrorSnackbar('Recording Error', 'Failed to start recording: $e');
      }
    }
  }

  Future<void> stopRecording() async {
    if (_isDisposed) return;

    try {
      _stopRecordingTimer();

      final path = await _cameraService?.stopRecording();

      if (!_isDisposed && path != null) {
        isRecording.value = false;
        recordedVideoPath.value = path;

        // Calculate actual duration from file
        await _calculateActualVideoDuration(path);

        // Stop camera streaming to save resources
        await _pauseCameraStream();

        await initializeVideoPlayer();
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (!_isDisposed) {
        isRecording.value = false;
        _showErrorSnackbar('Recording Error', 'Failed to stop recording: $e');
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    recordingDuration.value = 0;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !isRecording.value) {
        timer.cancel();
        return;
      }
      recordingDuration.value++;
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<void> _calculateActualVideoDuration(String videoPath) async {
    try {
      final tempController = VideoPlayerController.file(File(videoPath));
      await tempController.initialize();

      final duration = tempController.value.duration;
      actualRecordingDuration.value = duration.inSeconds;

      // Update the display duration
      recordingDuration.value = duration.inSeconds;

      await tempController.dispose();
      print('Actual video duration: ${duration.inSeconds} seconds');
    } catch (e) {
      print('Error calculating video duration: $e');
      // Fallback to timer duration
      actualRecordingDuration.value = recordingDuration.value;
    }
  }

  // MARK: - Camera Resource Management

  Future<void> _pauseCameraStream() async {
    try {
      if (cameraController != null && cameraController!.value.isInitialized) {
        // Don't dispose, just mark as inactive to stop continuous streaming
        isCameraActive.value = false;
        print('Camera stream paused to save resources');
      }
    } catch (e) {
      print('Error pausing camera stream: $e');
    }
  }

  Future<void> _resumeCameraStream() async {
    try {
      if (!isCameraActive.value && isCameraInitialized.value) {
        isCameraActive.value = true;
        print('Camera stream resumed');
      } else if (!isCameraInitialized.value) {
        await _safeInitializeCamera();
      }
    } catch (e) {
      print('Error resuming camera stream: $e');
    }
  }

  // MARK: - Video Player Methods

  Future<void> initializeVideoPlayer() async {
    if (_isDisposed || recordedVideoPath.value.isEmpty) return;

    try {
      await _disposeVideoPlayer();

      videoPlayerController = VideoPlayerController.file(
        File(recordedVideoPath.value),
      );

      await videoPlayerController!.initialize();

      if (!_isDisposed) {
        isVideoPlayerInitialized.value = true;
        print('Video player initialized successfully');
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (!_isDisposed) {
        _showErrorSnackbar('Player Error', 'Failed to initialize video player');
      }
    }
  }

  // MARK: - Save Methods

  Future<void> saveToDevice() async {
    if (!_isUserAuthenticated() ||
        recordedVideoPath.value.isEmpty ||
        _isDisposed)
      return;

    isSaving.value = true;
    try {
      await _simulateSaveProgress();
      await _storageService.saveToDevice(recordedVideoPath.value);

      if (!_isDisposed) {
        _showSuccessSnackbar('Saved Successfully', 'Video saved to device');
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Save Failed', 'Failed to save video to device: $e');
      }
    } finally {
      if (!_isDisposed) {
        isSaving.value = false;
      }
    }
  }

  Future<void> saveToCloud() async {
    if (!_isUserAuthenticated() ||
        recordedVideoPath.value.isEmpty ||
        _isDisposed)
      return;

    // Check if video is already saved to cloud
    if (isVideoSavedToCloud.value &&
        lastCloudUploadedVideoUrl.value.isNotEmpty) {
      print('Video already saved to cloud, navigating to send screen...');
      uploadStatus.value = 'Video already uploaded';
      Get.to(() => SendVideoScreen(videoUrl: lastCloudUploadedVideoUrl.value));
      return;
    }

    isSaving.value = true;
    isUploading.value = true;
    uploadStatus.value = 'Preparing upload...';

    try {
      final videoFile = File(recordedVideoPath.value);

      // Validate file
      if (!await videoFile.exists()) {
        throw Exception('Video file not found');
      }

      final fileSize = await videoFile.length();
      if (fileSize > 100 * 1024 * 1024) {
        throw Exception('Video file too large (max 100MB)');
      }

      uploadStatus.value = 'Uploading to cloud...';

      final uploadedUrl = await _uploadVideoToAPI(videoFile);

      if (uploadedUrl.startsWith('Failed') || uploadedUrl.startsWith('Error')) {
        throw Exception(uploadedUrl);
      }

      lastCloudUploadedVideoUrl.value = uploadedUrl;
      uploadStatus.value = 'Saving to database...';

      // Create video model with actual duration
      final videoId = _uuid.v4();
      currentVideoId.value = videoId;

      final videoModel = VideoModel(
        id: videoId,
        userId: currentUser.value!.uid,
        title: 'Video ${DateTime.now().toString().substring(0, 19)}',
        description:
            generatedScript.value.isNotEmpty ? generatedScript.value : null,
        videoUrl: uploadedUrl,
        duration:
            actualRecordingDuration.value > 0
                ? actualRecordingDuration.value
                : recordingDuration.value,
        fileSize: fileSize / (1024 * 1024),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'scriptGenerated': generatedScript.value.isNotEmpty,
          'deviceInfo': Platform.isAndroid ? 'Android' : 'iOS',
          'appVersion': '1.0.0',
          'actualDuration': actualRecordingDuration.value,
          'timerDuration': recordingDuration.value,
        },
        status: 'completed',
      );

      await _firestore
          .collection('videos')
          .doc(videoId)
          .set(videoModel.toJson());
      await _updateUserVideoStats();

      if (!_isDisposed) {
        currentVideo.value = videoModel;
        userVideos.insert(0, videoModel);
        isVideoSavedToCloud.value = true;
        uploadStatus.value = 'Upload completed successfully';

        Get.to(() => SendVideoScreen(videoUrl: uploadedUrl));
      }
    } catch (e) {
      print('Error saving to cloud: $e');
      if (!_isDisposed) {
        uploadStatus.value = 'Upload failed';
        _showErrorSnackbar('Cloud Save Failed', 'Failed to save to cloud: $e');
      }
    } finally {
      if (!_isDisposed) {
        isSaving.value = false;
        isUploading.value = false;
        uploadProgress.value = 0.0;
      }
    }
  }

  Future<String> _uploadVideoToAPI(File videoFile) async {
    try {
      String originalPath = videoFile.path;
      String correctedPath = originalPath;

      if (!originalPath.toLowerCase().endsWith('.mp4')) {
        correctedPath = originalPath.replaceAll(RegExp(r'\.[^.]*$'), '.mp4');
      }

      File correctedFile = videoFile;
      if (correctedPath != originalPath) {
        correctedFile = await videoFile.copy(correctedPath);
      }

      _simulateUploadProgress();
      final url = await uploadMedia([correctedFile]);

      return url;
    } catch (e) {
      throw Exception('API upload failed: $e');
    }
  }

  Future<void> _simulateUploadProgress() async {
    for (int i = 0; i <= 100; i += 5) {
      if (_isDisposed || !isUploading.value) break;
      uploadProgress.value = i / 100;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _simulateSaveProgress() async {
    for (int i = 0; i <= 100; i += 10) {
      if (_isDisposed || !isSaving.value) break;
      saveProgress.value = i / 100;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!_isDisposed) {
      saveProgress.value = 0.0;
    }
  }

  // MARK: - Video Management Methods

  Future<void> loadUserVideos() async {
    if (!_isUserAuthenticated() || _isDisposed) return;

    isLoadingVideos.value = true;
    try {
      final querySnapshot =
          await _firestore
              .collection('videos')
              .where('userId', isEqualTo: currentUser.value!.uid)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .get();

      if (!_isDisposed) {
        userVideos.value =
            querySnapshot.docs
                .map((doc) => VideoModel.fromJson(doc.data()))
                .toList();
      }
    } catch (e) {
      print('Error loading user videos: $e');
      if (!_isDisposed) {
        _showErrorSnackbar('Load Failed', 'Failed to load your videos: $e');
      }
    } finally {
      if (!_isDisposed) {
        isLoadingVideos.value = false;
      }
    }
  }

  Future<void> deleteVideo(VideoModel video) async {
    if (!_isUserAuthenticated() || _isDisposed) return;

    try {
      await _firestore.collection('videos').doc(video.id).delete();

      if (!_isDisposed) {
        userVideos.removeWhere((v) => v.id == video.id);
      }

      final userStatsRef = _firestore
          .collection('user_stats')
          .doc(currentUser.value!.uid);

      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(userStatsRef);
        if (statsDoc.exists) {
          final currentCount = statsDoc.data()?['videoCount'] ?? 0;
          transaction.update(userStatsRef, {
            'videoCount': currentCount > 0 ? currentCount - 1 : 0,
            'totalStorageUsed': FieldValue.increment(-video.fileSize),
          });
        }
      });

      if (!_isDisposed) {
        _showSuccessSnackbar(
          'Video Deleted',
          'Video removed from your account',
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        _showErrorSnackbar('Delete Failed', 'Failed to delete video: $e');
      }
    }
  }

  void discardVideo() {
    try {
      recordedVideoPath.value = '';
      recordingDuration.value = 0;
      actualRecordingDuration.value = 0;
      _disposeVideoPlayer();
      currentVideo.value = null;
      uploadProgress.value = 0.0;
      uploadStatus.value = '';
      _resetVideoSaveStatus();

      // Resume camera stream for new recording
      _resumeCameraStream();

      if (!_isDisposed) {
        Get.back();
        _showSuccessSnackbar('Video Discarded', 'Recording has been discarded');
      }
    } catch (e) {
      print('Error discarding video: $e');
    }
  }

  // MARK: - User Statistics

  Future<void> _updateUserVideoStats() async {
    try {
      final userStatsRef = _firestore
          .collection('user_stats')
          .doc(currentUser.value!.uid);

      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(userStatsRef);

        if (statsDoc.exists) {
          final currentCount = statsDoc.data()?['videoCount'] ?? 0;
          transaction.update(userStatsRef, {
            'videoCount': currentCount + 1,
            'lastVideoUpload': DateTime.now().toIso8601String(),
            'totalStorageUsed': FieldValue.increment(
              File(recordedVideoPath.value).lengthSync() / (1024 * 1024),
            ),
          });
        } else {
          transaction.set(userStatsRef, {
            'userId': currentUser.value!.uid,
            'videoCount': 1,
            'lastVideoUpload': DateTime.now().toIso8601String(),
            'totalStorageUsed':
                File(recordedVideoPath.value).lengthSync() / (1024 * 1024),
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // MARK: - Cleanup Methods

  Future<void> _cleanup() async {
    _isDisposed = true;

    _stopRecordingTimer();
    _authSubscription?.cancel();

    await _disposeCameraResources();
    await _disposeVideoPlayer();

    _cameraService = null;
  }

  Future<void> _disposeCameraResources() async {
    try {
      isCameraActive.value = false;
      isCameraInitialized.value = false;

      if (cameraController != null) {
        await cameraController!.dispose();
        cameraController = null;
      }

      _cameraService = null;
      print('Camera resources disposed');
    } catch (e) {
      print('Error disposing camera resources: $e');
    }
  }

  Future<void> _disposeVideoPlayer() async {
    try {
      if (videoPlayerController != null) {
        await videoPlayerController!.dispose();
        videoPlayerController = null;
      }
      isVideoPlayerInitialized.value = false;
      print('Video player disposed');
    } catch (e) {
      print('Error disposing video player: $e');
    }
  }

  // MARK: - Utility Methods

  void _resetVideoSaveStatus() {
    isVideoSavedToCloud.value = false;
    lastCloudUploadedVideoUrl.value = '';
    currentVideoId.value = '';
  }

  // Getters
  String get getLastUploadedVideoUrl => lastCloudUploadedVideoUrl.value;
  String get getCurrentVideoId => currentVideoId.value;
  VideoModel? get getCurrentVideoModel => currentVideo.value;
  bool get isCurrentVideoSavedToCloud => isVideoSavedToCloud.value;

  void navigateToSendScreen() {
    if (isVideoSavedToCloud.value &&
        lastCloudUploadedVideoUrl.value.isNotEmpty) {
      Get.to(() => SendVideoScreen(videoUrl: lastCloudUploadedVideoUrl.value));
    } else {
      _showErrorSnackbar('No Video', 'Please save a video to cloud first');
    }
  }

  // MARK: - UI Helper Methods

  void _showSuccessSnackbar(String title, String message) {
    if (_isDisposed) return;

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
    if (_isDisposed) return;

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

  // Format helpers
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  // MARK: - Public Methods for Manual Control

  /// Resume camera manually (useful when returning to camera view)
  Future<void> resumeCamera() async {
    await _resumeCameraStream();
  }

  /// Pause camera manually (useful when navigating away)
  Future<void> pauseCamera() async {
    await _pauseCameraStream();
  }

  /// Reinitialize camera (useful for handling camera errors)
  Future<void> reinitializeCamera() async {
    await _safeInitializeCamera();
  }
}
