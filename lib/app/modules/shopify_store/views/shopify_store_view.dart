import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/auth.dart';

import '../controllers/shopify_store_controller.dart';

class ShopifyStoreView extends GetView<ShopifyStoreController> {
  const ShopifyStoreView({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthTab();
  }
}
