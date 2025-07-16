// views/preview_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/film_video_components.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/save_option_screen.dart';

import 'package:video_player/video_player.dart';

class PreviewScreen extends StatelessWidget {
  final VideoScriptController controller = Get.find<VideoScriptController>();

  PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Video Preview',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            controller.discardVideo();
       
          },
        ),
      ),
      body: Obx(() {
        if (!controller.isVideoPlayerInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007AFF)),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio:
                      controller.videoPlayerController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(controller.videoPlayerController!),
                      ValueListenableBuilder(
                        valueListenable: controller.videoPlayerController!,
                        builder: (context, VideoPlayerValue value, child) {
                          return IconButton(
                            onPressed: () {
                              if (value.isPlaying) {
                                controller.videoPlayerController!.pause();
                              } else {
                                controller.videoPlayerController!.play();
                              }
                            },
                            icon: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Continue',
                          onPressed: () => Get.to(() => SaveOptionsScreen()),
                          backgroundColor: const Color(0xFF007AFF),
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
