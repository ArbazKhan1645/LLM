import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/models/video_history_model/video_history_model.dart';

class VideoHistoryController extends GetxController {
  final RxInt selectedTab = 0.obs;
  final RxList<VideoHistoryItem> sentVideos = <VideoHistoryItem>[].obs;
  final RxList<VideoHistoryItem> receivedVideos = <VideoHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateSampleVideos();
  }

  void _generateSampleVideos() {
    // Generate sample sent videos
    sentVideos.addAll([
      VideoHistoryItem(
        id: '1',
        title: 'EVERYDAY MAKEUP ROUTINE',
        duration: '0:28',
        daysAgo: 3,
        fileSize: '15 MB',
        thumbnailAsset: 'assets/video_thumbnail_1.jpg',
      ),
      VideoHistoryItem(
        id: '2',
        title: 'EVERYDAY MAKEUP ROUTINE',
        duration: '0:28',
        daysAgo: 2,
        fileSize: '12 MB',
        thumbnailAsset: 'assets/video_thumbnail_2.jpg',
      ),
      VideoHistoryItem(
        id: '3',
        title: 'EVERYDAY MAKEUP ROUTINE',
        duration: '0:28',
        daysAgo: 2,
        fileSize: '18 MB',
        thumbnailAsset: 'assets/video_thumbnail_3.jpg',
      ),
      VideoHistoryItem(
        id: '4',
        title: 'EVERYDAY MAKEUP ROUTINE',
        duration: '0:28',
        daysAgo: 2,
        fileSize: '14 MB',
        thumbnailAsset: 'assets/video_thumbnail_4.jpg',
      ),
      VideoHistoryItem(
        id: '5',
        title: 'EVERYDAY MAKEUP ROUTINE',
        duration: '0:28',
        daysAgo: 3,
        fileSize: '16 MB',
        thumbnailAsset: 'assets/video_thumbnail_5.jpg',
      ),
    ]);

    // Generate sample received videos
    receivedVideos.addAll([
      VideoHistoryItem(
        id: '6',
        title: 'LUCAS BLAKE',
        subtitle: '2 DAYS AGO',
        duration: '0:28',
        status: VideoStatus.viewed,
        thumbnailAsset: 'assets/video_thumbnail_6.jpg',
      ),
      VideoHistoryItem(
        id: '7',
        title: 'LUCAS BLAKE',
        subtitle: '2 DAYS AGO',
        duration: '0:28',
        status: VideoStatus.unviewed,
        thumbnailAsset: 'assets/video_thumbnail_7.jpg',
      ),
      VideoHistoryItem(
        id: '8',
        title: 'LUCAS BLAKE',
        subtitle: '2 DAYS AGO',
        duration: '0:28',
        status: VideoStatus.viewed,
        thumbnailAsset: 'assets/video_thumbnail_8.jpg',
      ),
      VideoHistoryItem(
        id: '9',
        title: 'LUCAS BLAKE',
        subtitle: '2 DAYS AGO',
        duration: '0:28',
        status: VideoStatus.unviewed,
        thumbnailAsset: 'assets/video_thumbnail_9.jpg',
      ),
      VideoHistoryItem(
        id: '10',
        title: 'LUCAS BLAKE',
        subtitle: '2 DAYS AGO',
        duration: '0:28',
        status: VideoStatus.viewed,
        thumbnailAsset: 'assets/video_thumbnail_10.jpg',
      ),
    ]);
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void deleteVideo(String id) {
    sentVideos.removeWhere((video) => video.id == id);
    receivedVideos.removeWhere((video) => video.id == id);
    Get.snackbar(
      'Deleted',
      'Video has been deleted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void markAsViewed(String id) {
    final index = receivedVideos.indexWhere((video) => video.id == id);
    if (index != -1) {
      receivedVideos[index] = receivedVideos[index].copyWith(
        status: VideoStatus.viewed,
      );
    }
  }
}
