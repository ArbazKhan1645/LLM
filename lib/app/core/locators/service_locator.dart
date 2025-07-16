// ignore_for_file: depend_on_referenced_packages, avoid_print, non_constant_identifier_names

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/core/utils/constants/string.dart';
import 'package:shopify_flutter/shopify_flutter.dart';

import 'package:llm_video_shopify/app/services/chat_service/chat_service.dart';
import 'package:llm_video_shopify/app/services/current_user_service/current_user_service.dart';

Future<void> initDependencies() async {
  await _initAppServices();
}

Future<void> _initAppServices() async {
  final ai_chat_service = AIChatService(
    apiKey:
        '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',
    baseUrl: 'https://api.openai.com/v1',
    systemPrompt: CString.ai_chat_prompt,
  );

  await Get.putAsync(() => ai_chat_service.init());
  await Get.putAsync(() => UserService().init());
  await initializeStore();
}

initializeStore() {
  ShopifyConfig.setConfig(
    storefrontAccessToken: '5db627163c5695a1805ba4c8b3d15eda',
    storeUrl: 'pitchdifferent.net',
    storefrontApiVersion: '2024-07',
    cachePolicy: CachePolicy.cacheAndNetwork,
    language: 'en',
  );
}
