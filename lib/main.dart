import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:llm_video_shopify/app/core/locators/service_locator.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:llm_video_shopify/app/services/firebase_notifications/firebase_notification_service.dart';
import 'package:llm_video_shopify/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    host: 'firestore.googleapis.com',
    sslEnabled: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseAuth.instance.authStateChanges().first;
  await FirebaseAuth.instance.currentUser?.reload();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  await initDependencies();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder:
          (_, child) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            title: 'PitchPal LLM',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              fontFamily: 'BebasNeue',
            ),
          ),
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }
}

Future<String> uploadMedia(
  List<File> files, {
  String? directory,
  int? width,
  int? height,
}) async {
  var uri = Uri.parse('https://api.tjara.com/api/media/insert');

  var request = http.MultipartRequest('POST', uri);

  request.headers.addAll({
    'X-Request-From': 'Application',
    'Accept': 'application/json',
  });

  // Add media files
  for (var file in files) {
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();

    var multipartFile = http.MultipartFile(
      'media[]',
      stream,
      length,
      filename: path.basename(file.path),
    );

    request.files.add(multipartFile);
  }

  // Add optional parameters
  if (directory != null) {
    request.fields['directory'] = directory;
  }

  if (width != null) {
    request.fields['width'] = width.toString();
  }

  if (height != null) {
    request.fields['height'] = height.toString();
  }

  // Send request and allow redirects
  var response = await request.send();

  // Handle redirect manually
  if (response.statusCode == 302 || response.statusCode == 301) {
    var redirectUrl = response.headers['location'];
    if (redirectUrl != null) {
      return await uploadMedia(
        files,
        directory: directory,
        width: width,
        height: height,
      );
    }
  }

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    var jsonData = jsonDecode(responseBody);

    return jsonData['media'][0]['optimized_media_url'];
  } else {
    return 'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}';
  }
}
