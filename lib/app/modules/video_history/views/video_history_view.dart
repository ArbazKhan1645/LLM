import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/video_history/widgets/video_history_body.dart';

import '../controllers/video_history_controller.dart';

class VideoHistoryView extends GetView<VideoHistoryController> {
  const VideoHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return VideoHistoryScreen();
  }
}
