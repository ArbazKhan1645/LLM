import 'package:get/get.dart';

import '../controllers/video_script_controller.dart';

class VideoScriptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoScriptController>(
      () => VideoScriptController(),
    );
  }
}
