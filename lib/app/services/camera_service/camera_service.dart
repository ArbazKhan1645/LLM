// services/camera_service.dart
import 'package:camera/camera.dart';

import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  CameraController? get cameraController => _cameraController;

  Future<void> initializeCamera() async {
    // Request permissions
    print('object');
    await _requestPermissions();
    print('object2');

    // Get available cameras
    _cameras = await availableCameras();

    print('object3 ${_cameras.length}');

    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.startVideoRecording();
      } catch (e) {
        throw Exception('Failed to start recording: $e');
      }
    }
  }

  Future<String> stopRecording() async {
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo) {
      try {
        final videoFile = await _cameraController!.stopVideoRecording();
        return videoFile.path;
      } catch (e) {
        throw Exception('Failed to stop recording: $e');
      }
    }
    return '';
  }

  void dispose() {
    _cameraController?.dispose();
  }
}
