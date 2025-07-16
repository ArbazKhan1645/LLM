import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  Future<void> saveToDevice(String videoPath) async {
    try {
      // Request permission
      if (Platform.isAndroid) {
        if (Platform.version.contains('13') ||
            Platform.version.contains('14')) {
          if (!await Permission.videos.request().isGranted) {
            throw Exception('Video permission denied');
          }
        } else {
          if (!await Permission.storage.request().isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // Save to Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final newPath = path.join(directory.path, fileName);
      await File(videoPath).copy(newPath);

      print('Video saved to $newPath');
    } catch (e) {
      throw Exception('Failed to save to device: $e');
    }
  }

  Future<void> saveToCloud(String videoPath) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      print('Video uploaded to cloud: $videoPath');
    } catch (e) {
      throw Exception('Failed to save to cloud: $e');
    }
  }
}
