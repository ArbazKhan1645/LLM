// views/recording_screen.dart
// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/film_video_components.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/preview_screen.dart';

class RecordingScreen extends StatelessWidget {
  final VideoScriptController controller = Get.find<VideoScriptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (!controller.isCameraInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF007AFF)),
            );
          }

          return Stack(
            children: [
              // Camera Preview
              Positioned.fill(
                child: CameraPreview(controller.cameraController!),
              ),

              // Countdown Overlay
              if (controller.showCountdown.value)
                CountdownOverlay(
                  countdownValue: controller.countdownValue.value,
                ),

              // Script Overlay
              if (controller.isRecording.value)
                ScriptOverlay(script: controller.generatedScript.value),

              // Recording Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RecordingControls(
                  isRecording: controller.isRecording.value,
                  recordingDuration: controller.recordingDuration.value,
                  onStartRecording: controller.startCountdownAndRecord,
                  onStopRecording: () async {
                    await controller.stopRecording();
                    Get.to(() => PreviewScreen());
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
