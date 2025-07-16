import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/authentcation/views/authentcation_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:llm_video_shopify/app/services/current_user_service/current_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'dart:convert';

class AuthenticationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController businessLinkController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController signInEmailController = TextEditingController();
  final TextEditingController signInPasswordController =
      TextEditingController();

  // Observables
  final RxBool isPasswordVisible = false.obs;
  final RxBool isSignInPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final Rx<UserType> selectedUserType = UserType.user.obs;
  final RxBool isSignUp = true.obs;
  final RxBool isOtpSent = false.obs;
  final RxInt otpTimer = 0.obs;
  final RxString generatedOtp = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Form keys
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  // Professional status and industry lists
  final List<String> professionalStatuses = [
    "Business Owner",
    "Freelancer",
    "Contractor",
    "Employee",
  ];

  final List<String> industries = [
    "Technology",
    "Healthcare",
    "Finance",
    "Education",
    "Retail",
    "Manufacturing",
    "Real Estate",
    "Other",
  ];

  final selectedStatus = RxnString();
  final selectedIndustry = RxnString();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
    _generateDeviceId();
  }

  // Check authentication state
  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  // Generate unique device ID
  String _generateDeviceId() {
    return _uuid.v4();
  }

  // Generate OTP
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load user data', e.toString());
    }
  }

  // Send OTP via email
  Future<void> sendOTP(String email, String otp) async {
    try {
      const String username = 'hammad1645988@gmail.com';
      const String password = 'gfha omxq fsie mheg';
      final smtpServer = gmail(username, password);
      final message =
          Message()
            ..from = Address(username, 'Arbaz Khan')
            ..recipients.add(email)
            ..subject =
                'Email Verification of LLM Pitch Pal :: ${DateTime.now()}'
            ..text = 'This is the plain text.\nThis is line 2 of the text part.'
            ..html =
                "<h1>Test</h1>\n<p>Hey! LLM Pitch Pal App , Authentication Code of Your email is $otp</p>";

      await send(message, smtpServer);
      isOtpSent.value = true;
      _startOtpTimer();
      _showSuccessSnackbar('OTP Sent', 'Verification code sent to $email');
    } on MailerException catch (e) {
      _showErrorSnackbar('OTP Failed', 'Failed to send OTP: ${e.message}');
      for (var problem in e.problems) {
        debugPrint('Problem: ${problem.code}: ${problem.msg}');
      }
    } catch (e) {
      _showErrorSnackbar('OTP Failed', 'Unexpected error: $e');
    }
  }

  // Start OTP timer
  void _startOtpTimer() {
    otpTimer.value = 300; // 5 minutes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        timer.cancel();
        isOtpSent.value = false;
        generatedOtp.value = '';
      }
    });
  }

  // Sign up with email and password
  Future<void> signUpWithEmail() async {
    if (!signUpFormKey.currentState!.validate()) return;

    if (selectedUserType.value == UserType.business) {
      if (businessNameController.text.isEmpty ||
          businessLinkController.text.isEmpty ||
          businessAddressController.text.isEmpty) {
        _showErrorSnackbar(
          'Incomplete Information',
          'Please fill all business details',
        );
        return;
      }
    }

    if (selectedStatus.value == null) {
      _showErrorSnackbar(
        'Missing Information',
        'Please select your professional status',
      );
      return;
    }

    isLoading.value = true;

    try {
      // Generate and send OTP
      final otp = _generateOTP();
      generatedOtp.value = otp;

      await sendOTP(emailController.text.trim(), otp);

      // Store user data temporarily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'temp_user_data',
        jsonEncode({
          'fullName': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'userType': selectedUserType.value.toString(),
          'businessName': businessNameController.text.trim(),
          'businessLink': businessLinkController.text.trim(),
          'businessAddress': businessAddressController.text.trim(),
          'professionalStatus': selectedStatus.value,
          'industry': selectedIndustry.value,
        }),
      );

      Get.to(() => const VerificationScreen());
    } catch (e) {
      _showErrorSnackbar('Sign Up Failed', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail() async {
    // if (!signInFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: signInEmailController.text.trim(),
        password: signInPasswordController.text,
      );

      if (credential.user != null) {
        print(credential.user?.email);
        // if (!credential.user!.emailVerified) {
        //   await credential.user!.sendEmailVerification();
        //   _showWarningSnackbar(
        //     'Email Not Verified',
        //     'Please check your email for verification link',
        //   );
        //   await _auth.signOut();
        //   return;
        // }

        if (signInEmailController.text == 'admin@admin.com') {
        } else {}
        print(credential.user?.email);

        await _loadUserData(credential.user?.uid ?? '');
        print(credential.user?.email);

        if (rememberMe.value) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', true);
          await prefs.setString(
            'user_email',
            signInEmailController.text.trim(),
          );
        }
        print(credential.user?.email);

        _navigateBasedOnUserType();
        _showSuccessSnackbar('Welcome Back!', 'Successfully signed in');
      }
    } catch (e) {
      _showErrorSnackbar('Sign In Failed', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP and complete registration
  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      _showErrorSnackbar('Invalid OTP', 'Please enter a valid 6-digit OTP');
      return;
    }

    if (otpController.text != generatedOtp.value) {
      _showErrorSnackbar('Invalid OTP', 'The OTP you entered is incorrect');
      return;
    }

    if (otpTimer.value <= 0) {
      _showErrorSnackbar(
        'OTP Expired',
        'The OTP has expired. Please request a new one',
      );
      return;
    }

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final tempUserData = prefs.getString('temp_user_data');

      if (tempUserData == null) {
        throw Exception('User data not found. Please try again.');
      }

      final userData = jsonDecode(tempUserData);

      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(userData['fullName']);
        await credential.user!.sendEmailVerification();

        // Create user document in Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: userData['email'],
          fullName: userData['fullName'],
          userType: UserType.values.firstWhere(
            (e) => e.toString() == userData['userType'],
          ),
          businessName:
              userData['businessName']?.isEmpty == true
                  ? null
                  : userData['businessName'],
          businessLink:
              userData['businessLink']?.isEmpty == true
                  ? null
                  : userData['businessLink'],
          businessAddress:
              userData['businessAddress']?.isEmpty == true
                  ? null
                  : userData['businessAddress'],
          professionalStatus: userData['professionalStatus'],
          industry: userData['industry'],
          isEmailVerified: false,
          isProfileComplete: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deviceId: _generateDeviceId(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toJson());
        final userService = Get.find<UserService>();

        // Wait for UserService to complete initialization
        await userService.init();

        // Clean up temporary data
        await prefs.remove('temp_user_data');

        currentUser.value = userModel;
        _navigateBasedOnUserType();
        _showSuccessSnackbar(
          'Account Created!',
          'Please verify your email to complete setup',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Verification Failed', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (isOtpSent.value && otpTimer.value > 240) {
      // Allow resend only after 1 minute
      _showWarningSnackbar(
        'Please Wait',
        'You can request a new OTP in ${otpTimer.value - 240} seconds',
      );
      return;
    }

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final tempUserData = prefs.getString('temp_user_data');

      if (tempUserData != null) {
        final userData = jsonDecode(tempUserData);
        final otp = _generateOTP();
        generatedOtp.value = otp;

        await sendOTP(userData['email'], otp);
      }
    } catch (e) {
      _showErrorSnackbar('Resend Failed', 'Failed to resend OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('user_email');
      currentUser.value = null;
      Get.offAllNamed('/authentication');
      _showSuccessSnackbar('Signed Out', 'Successfully signed out');
    } catch (e) {
      _showErrorSnackbar('Sign Out Failed', 'Failed to sign out: $e');
    }
  }

  // Navigate based on user type
  void _navigateBasedOnUserType() {
    if (currentUser.value?.email == 'admin@admin.com') {
      Get.offAllNamed(Routes.ADMIN_DASHBOARD);
    } else {
      Get.offAllNamed('/dashboard');
    }
  }

  // Error message helper
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled. Please contact support.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'requires-recent-login':
          return 'Please sign in again to continue.';
        default:
          return error.message ?? 'An unexpected error occurred.';
      }
    }
    return error.toString();
  }

  // Snackbar helpers
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Toggle methods
  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;
  void toggleSignInPasswordVisibility() =>
      isSignInPasswordVisible.value = !isSignInPasswordVisible.value;
  void toggleRememberMe() => rememberMe.value = !rememberMe.value;
  void selectUserType(UserType type) => selectedUserType.value = type;

  // Navigation methods
  void navigateToSignIn() => isSignUp.value = false;
  void navigateToSignUp() => isSignUp.value = true;
  void navigateToVerification() => Get.to(() => const VerificationScreen());

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateBusinessName(String? value) {
    if (selectedUserType.value == UserType.business) {
      if (value == null || value.isEmpty) return 'Business name is required';
      if (value.length < 2)
        return 'Business name must be at least 2 characters';
    }
    return null;
  }

  String? validateBusinessLink(String? value) {
    if (selectedUserType.value == UserType.business) {
      if (value == null || value.isEmpty) return 'Business link is required';
      if (!GetUtils.isURL(value)) return 'Enter a valid URL';
    }
    return null;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
