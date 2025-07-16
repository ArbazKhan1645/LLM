import 'package:get/get.dart';

import '../controllers/reported_list_controller.dart';

class ReportedListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportedListController>(
      () => ReportedListController(),
    );
  }
}
