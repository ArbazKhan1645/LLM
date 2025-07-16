import 'package:get/get.dart';

import '../controllers/users_managment_controller.dart';

class UsersManagmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersManagmentController>(
      () => UsersManagmentController(),
    );
  }
}
