import 'package:get/get.dart';

import '../controllers/authentcation_controller.dart';

class AuthentcationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthenticationController>(
      () => AuthenticationController(),
    );
  }
}
