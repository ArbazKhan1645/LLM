// ignore_for_file: unused_field, avoid_print, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:llm_video_shopify/app/data/auth_repo.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';

import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  // Reactive variables
  var user = Rx<UserModel?>(null);
  var isLoading = true.obs;
  var isAuthenticated = false.obs;

  // Streams and subscriptions
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authRepo = AuthRepo();

  // State variables
  String? userId;
  bool _isOnline = true;
  File? profilePicture;
  File? backPicture;
  SharedPreferences? prefs;

  // Completer to ensure initialization is complete
  Completer<void>? _initCompleter;

  @override
  Future<void> onInit() async {
    super.onInit();
    await init();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  Future<UserService> init() async {
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      await _initCompleter!.future;
      return this;
    }

    _initCompleter = Completer<void>();

    try {
      // Initialize SharedPreferences
      prefs = await SharedPreferences.getInstance();

      // Setup connectivity monitoring
      await _setupConnectivityListener();

      // Setup auth state listener
      _setupAuthStateListener();

      // Check initial auth state
      await _checkInitialAuthState();

      _initCompleter!.complete();
    } catch (e) {
      print('UserService initialization error: $e');
      _initCompleter!.completeError(e);
      rethrow;
    }

    return this;
  }

  Future<void> _setupConnectivityListener() async {
    // Check initial connectivity
    final initialConnectivity = await Connectivity().checkConnectivity();
    _isOnline = !initialConnectivity.contains(ConnectivityResult.none);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);

      print('Connectivity changed: $_isOnline');

      // If we just came back online and have a user, refresh the user data
      if (!wasOnline && _isOnline && userId != null) {
        _listenToUserDetails();
      }
    });
  }

  void _setupAuthStateListener() {
    _authSubscription = _auth.authStateChanges().listen(
      (User? firebaseUser) async {
        print('Auth state changed: ${firebaseUser?.uid}');

        if (firebaseUser != null) {
          await _handleUserSignedIn(firebaseUser);
        } else {
          await _handleUserSignedOut();
        }
      },
      onError: (error) {
        print('Auth state listener error: $error');
        isLoading.value = false;
      },
    );
  }

  Future<void> _checkInitialAuthState() async {
    isLoading.value = true;

    try {
      final currentUser = _auth.currentUser;
      print('Initial auth check - Current user: ${currentUser?.uid}');

      if (currentUser != null) {
        await _handleUserSignedIn(currentUser);
      } else {
        await _handleUserSignedOut();
      }
    } catch (e) {
      print('Initial auth check error: $e');
      await _handleUserSignedOut();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleUserSignedIn(User firebaseUser) async {
    try {
      userId = firebaseUser.uid;
      isAuthenticated.value = true;

      if (_isOnline) {
        await _listenToUserDetails();
      } else {
        // If offline, try to load cached user data
        await _loadCachedUserData();
      }
    } catch (e) {
      print('Error handling user sign in: $e');
      await _handleUserSignedOut();
    }
  }

  Future<void> _handleUserSignedOut() async {
    isAuthenticated.value = false;
    _clearUserData();
    isLoading.value = false;
  }

  Future<void> _listenToUserDetails() async {
    if (userId == null || !_isOnline) return;

    try {
      // Cancel existing subscription
      await _userSubscription?.cancel();

      print('Setting up user stream for: $userId');

      final userStream = _authRepo.watchUser();
      _userSubscription = userStream.listen(
        (UserModel? userModel) async {
          print('User data received: ${userModel?.uid}');

          if (userModel != null) {
            user.value = userModel;
            await _cacheUserData(userModel);
          } else {
            print('User data is null, signing out');
            // await logout();
          }

          isLoading.value = false;
        },
        onError: (error) {
          print('User stream error: $error');
          isLoading.value = false;
          // Don't logout on stream error, might be temporary
        },
      );
    } catch (e) {
      print('Error setting up user stream: $e');
      isLoading.value = false;
    }
  }

  Future<void> _loadCachedUserData() async {
    try {
      if (prefs == null) return;

      final cachedUserJson = prefs!.getString('cached_user_$userId');
      if (cachedUserJson != null) {
        // Assuming UserModel has fromJson method
        user.value = UserModel.fromJson(json.decode(cachedUserJson));
        print('Loaded cached user data');
      }
    } catch (e) {
      print('Error loading cached user data: $e');
    }
  }

  Future<void> _cacheUserData(UserModel userModel) async {
    try {
      if (prefs == null) return;

      // Assuming UserModel has toJson method
      await prefs!.setString(
        'cached_user_$userId',
        json.encode(userModel.toJson()),
      );
      print('Cached user data');
    } catch (e) {
      print('Error caching user data: $e');
    }
  }

  void _clearUserData() {
    user.value = null;
    userId = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    profilePicture = null;
    backPicture = null;
  }

  void _cleanup() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    _connectivitySubscription?.cancel();
  }

  // Public getters
  UserModel? get currentUserModel => user.value;
  bool get hasUser => user.value != null;
  bool get isUserLoading => isLoading.value;

  // Public methods
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Clear cached data
      if (prefs != null && userId != null) {
        await prefs!.remove('cached_user_$userId');
      }

      // Sign out from Firebase
      await _authRepo.signOut();

      // Navigate to authentication screen
      Get.offAllNamed(Routes.AUTHENTCATION);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserData() async {
    if (userId != null && _isOnline) {
      await _listenToUserDetails();
    }
  }

  Future<void> setProfilePicture(String pictureUrl) async {
    try {
      profilePicture = await downloadAndSaveImage(pictureUrl, 'User-Profile');
    } catch (e) {
      print('Error downloading profile picture: $e');
    }
  }
}

// Utility functions
Future<File> downloadAndSaveImage(String imageUrl, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = join(directory.path, fileName);
  final file = File(filePath);
  final response = await http.get(Uri.parse(imageUrl));
  await file.writeAsBytes(response.bodyBytes);
  return file;
}

Future<File?> returnImage(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = join(directory.path, fileName);
  final file = File(filePath);
  if (await file.exists()) {
    return file;
  }
  return null;
}

Future<void> deleteImage(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = join(directory.path, fileName);
  final file = File(filePath);

  if (await file.exists()) {
    print('Image deleted');
    await file.delete();
  } else {
    throw Exception('File not found');
  }
}
