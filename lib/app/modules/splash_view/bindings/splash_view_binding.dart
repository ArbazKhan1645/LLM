import 'package:get/get.dart';

import '../controllers/splash_view_controller.dart';

class SplashViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashViewController>(
      () => SplashViewController(),
    );
  }
}
