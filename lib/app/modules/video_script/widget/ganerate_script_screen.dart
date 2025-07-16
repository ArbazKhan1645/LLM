// views/generate_script_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/film_video_components.dart';
import 'recording_screen.dart';

class GenerateScriptScreen extends StatelessWidget {
  final VideoScriptController controller = Get.find<VideoScriptController>();

  GenerateScriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Generate Script',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'YOUR GENERATED SCRIPT',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // Script Editor
              Expanded(
                child: Obx(
                  () => ScriptEditor(
                    script: controller.generatedScript.value,
                    isLoading: controller.isGeneratingScript.value,
                    onScriptChanged: (newScript) {
                      controller.generatedScript.value = newScript;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        text: 'Regenerate Script',
                        onPressed:
                            controller.isGeneratingScript.value
                                ? null
                                : controller.regenerateScript,
                        isLoading: controller.isGeneratingScript.value,
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.grey.shade400,
                        textColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Obx(() {
                return CustomButton(
                  text: 'Proceed to Recording',
                  onPressed:
                      controller.generatedScript.value.isEmpty
                          ? controller.generateScript
                          : () => Get.to(() => RecordingScreen()),
                  backgroundColor: const Color(0xFF36B4E6),
                  textColor: Colors.white,
                  isLoading:
                      controller.generatedScript.value.isEmpty &&
                      controller.isGeneratingScript.value,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
