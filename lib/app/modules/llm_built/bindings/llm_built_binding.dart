import 'package:get/get.dart';

import '../controllers/llm_built_controller.dart';

class LlmBuiltBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LlmBuiltController>(
      () => LlmBuiltController(),
    );
  }
}
