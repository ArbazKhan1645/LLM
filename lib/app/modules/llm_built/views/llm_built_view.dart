import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/llm_built/widgets/chatbot_body.dart';

import '../controllers/llm_built_controller.dart';

class LlmBuiltView extends GetView<LlmBuiltController> {
  const LlmBuiltView({super.key});
  @override
  Widget build(BuildContext context) {
    return ChatbotView();
  }
}
