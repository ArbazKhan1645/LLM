import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/ganerate_script_screen.dart';

import '../controllers/video_script_controller.dart';

class VideoScriptView extends GetView<VideoScriptController> {
  const VideoScriptView({super.key});
  @override
  Widget build(BuildContext context) {
    return GenerateScriptScreen();
  }
}
