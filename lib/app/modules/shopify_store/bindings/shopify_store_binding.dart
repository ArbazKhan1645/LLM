import 'package:get/get.dart';

import '../controllers/shopify_store_controller.dart';

class ShopifyStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopifyStoreController>(
      () => ShopifyStoreController(),
    );
  }
}
