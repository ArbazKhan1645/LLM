// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/orders.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';

// Enhanced Profile Controller with Firebase Integration
class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user data from Firebase
  final Rx<User?> currentFirebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUserModel = Rx<UserModel?>(null);

  // Observable user data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString businessName = ''.obs;
  final RxString businessLink = ''.obs;
  final RxString businessAddress = ''.obs;
  final RxString professionalStatus = ''.obs;
  final RxString industry = ''.obs;
  final Rx<UserType> userType = UserType.user.obs;

  // Professional status and industry options
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

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessLinkController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // UI state
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingPassword = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isUploadingImage = false.obs;

  // Selected values
  final RxString selectedProfessionalStatus = ''.obs;
  final RxString selectedIndustry = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    // nameController.dispose();
    // emailController.dispose();
    // phoneController.dispose();
    // businessNameController.dispose();
    // businessLinkController.dispose();
    // businessAddressController.dispose();
    // currentPasswordController.dispose();
    // newPasswordController.dispose();
    // confirmPasswordController.dispose();
  }

  // Initialize user data from Firebase
  void _initializeUserData() {
    _auth.authStateChanges().listen((User? user) {
      currentFirebaseUser.value = user;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _clearUserData();
        Get.offAllNamed(Routes.AUTHENTCATION);
      }
    });
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      isLoading.value = true;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final userData = doc.data()!;

        print(userData);
        currentUserModel.value = UserModel.fromJson(userData);

        // Update observable values
        userName.value = userData['fullName'] ?? '';
        userEmail.value = userData['email'] ?? '';
        userPhone.value = userData['phoneNumber'] ?? '';
        userAvatar.value = userData['profileImageUrl'] ?? '';
        businessName.value = userData['businessName'] ?? '';
        businessLink.value = userData['businessLink'] ?? '';
        businessAddress.value = userData['businessAddress'] ?? '';
        professionalStatus.value = userData['professionalStatus'] ?? '';
        industry.value = userData['industry'] ?? '';
        userType.value = UserType.values.firstWhere(
          (e) => e.toString() == userData['userType'],
          orElse: () => UserType.user,
        );

        // Update form controllers
        _updateFormControllers();

        // Update selected dropdown values
        selectedProfessionalStatus.value = professionalStatus.value;
        selectedIndustry.value = industry.value;
      }
    } catch (e) {
      _showErrorSnackbar('Load Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update form controllers with current data
  void _updateFormControllers() {
    nameController.text = userName.value;
    emailController.text = userEmail.value;
    phoneController.text = userPhone.value;
    businessNameController.text = businessName.value;
    businessLinkController.text = businessLink.value;
    businessAddressController.text = businessAddress.value;
  }

  // Clear user data
  void _clearUserData() {
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    userAvatar.value = '';
    businessName.value = '';
    businessLink.value = '';
    businessAddress.value = '';
    professionalStatus.value = '';
    industry.value = '';
    userType.value = UserType.user;
    currentUserModel.value = null;

    // Clear form controllers
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    businessNameController.clear();
    businessLinkController.clear();
    businessAddressController.clear();
  }

  // Toggle edit mode
  void toggleEdit() {
    if (isEditing.value) {
      // Save changes
      _saveProfile();
    } else {
      // Enter edit mode
      _updateFormControllers();
    }
    isEditing.value = !isEditing.value;
    HapticFeedback.lightImpact();
  }

  // Save profile changes to Firestore
  Future<void> _saveProfile() async {
    if (currentFirebaseUser.value == null) return;

    // Validate input
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Validation Error', 'Name cannot be empty');
      return;
    }

    if (emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim())) {
      _showErrorSnackbar('Validation Error', 'Please enter a valid email');
      return;
    }

    // Validate business fields if business user
    if (userType.value == UserType.business) {
      if (businessNameController.text.trim().isEmpty ||
          businessLinkController.text.trim().isEmpty ||
          businessAddressController.text.trim().isEmpty) {
        _showErrorSnackbar(
          'Validation Error',
          'Please fill all business details',
        );
        return;
      }

      if (!GetUtils.isURL(businessLinkController.text.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid business URL',
        );
        return;
      }
    }

    isLoading.value = true;

    try {
      // Update Firebase Auth email if changed
      if (emailController.text.trim() != userEmail.value) {
        await currentFirebaseUser.value!.updateEmail(
          emailController.text.trim(),
        );
      }

      // Update display name if changed
      if (nameController.text.trim() != userName.value) {
        await currentFirebaseUser.value!.updateDisplayName(
          nameController.text.trim(),
        );
      }

      // Update user document in Firestore
      final updatedUserData = {
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'businessName':
            userType.value == UserType.business
                ? businessNameController.text.trim()
                : null,
        'businessLink':
            userType.value == UserType.business
                ? businessLinkController.text.trim()
                : null,
        'businessAddress':
            userType.value == UserType.business
                ? businessAddressController.text.trim()
                : null,
        'professionalStatus':
            selectedProfessionalStatus.value.isNotEmpty
                ? selectedProfessionalStatus.value
                : null,
        'industry':
            selectedIndustry.value.isNotEmpty ? selectedIndustry.value : null,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(currentFirebaseUser.value!.uid)
          .update(updatedUserData);

      // Update local observable values
      userName.value = nameController.text.trim();
      userEmail.value = emailController.text.trim();
      userPhone.value = phoneController.text.trim();
      businessName.value = businessNameController.text.trim();
      businessLink.value = businessLinkController.text.trim();
      businessAddress.value = businessAddressController.text.trim();
      professionalStatus.value = selectedProfessionalStatus.value;
      industry.value = selectedIndustry.value;

      _showSuccessSnackbar('Success', 'Profile updated successfully');
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            _showErrorSnackbar(
              'Authentication Required',
              'Please sign in again to update your profile',
            );
            break;
          case 'email-already-in-use':
            _showErrorSnackbar(
              'Email Error',
              'This email is already in use by another account',
            );
            break;
          case 'invalid-email':
            _showErrorSnackbar(
              'Email Error',
              'Please enter a valid email address',
            );
            break;
          default:
            _showErrorSnackbar(
              'Update Error',
              'Failed to update profile: ${e.message}',
            );
        }
      } else {
        _showErrorSnackbar('Update Error', 'Failed to update profile: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Change profile picture
  Future<void> changeProfilePicture() async {}

  // Change password
  Future<void> changePassword() async {
    if (currentFirebaseUser.value == null) return;

    // Validate passwords
    if (currentPasswordController.text.isEmpty) {
      _showErrorSnackbar(
        'Validation Error',
        'Please enter your current password',
      );
      return;
    }

    if (newPasswordController.text.length < 8) {
      _showErrorSnackbar(
        'Validation Error',
        'New password must be at least 8 characters',
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Validation Error', 'New passwords do not match');
      return;
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
    ).hasMatch(newPasswordController.text)) {
      _showErrorSnackbar(
        'Validation Error',
        'Password must contain uppercase, lowercase, and numbers',
      );
      return;
    }

    isUpdatingPassword.value = true;

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: currentFirebaseUser.value!.email!,
        password: currentPasswordController.text,
      );

      await currentFirebaseUser.value!.reauthenticateWithCredential(credential);

      // Update password
      await currentFirebaseUser.value!.updatePassword(
        newPasswordController.text,
      );

      // Clear password fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _showSuccessSnackbar('Success', 'Password updated successfully');
      Get.back(); // Close password change dialog
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            _showErrorSnackbar(
              'Authentication Error',
              'Current password is incorrect',
            );
            break;
          case 'weak-password':
            _showErrorSnackbar('Password Error', 'New password is too weak');
            break;
          case 'requires-recent-login':
            _showErrorSnackbar(
              'Authentication Required',
              'Please sign in again to change your password',
            );
            break;
          default:
            _showErrorSnackbar(
              'Password Error',
              'Failed to update password: ${e.message}',
            );
        }
      } else {
        _showErrorSnackbar('Password Error', 'Failed to update password: $e');
      }
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  // Forgot password
  Future<void> sendPasswordResetEmail() async {
    if (userEmail.value.isEmpty) {
      _showErrorSnackbar('Email Required', 'No email address found in profile');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: userEmail.value);
      _showSuccessSnackbar(
        'Email Sent',
        'Password reset email sent to ${userEmail.value}',
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _showErrorSnackbar(
              'User Error',
              'No user found with this email address',
            );
            break;
          case 'invalid-email':
            _showErrorSnackbar('Email Error', 'Invalid email address');
            break;
          default:
            _showErrorSnackbar(
              'Reset Error',
              'Failed to send reset email: ${e.message}',
            );
        }
      } else {
        _showErrorSnackbar('Reset Error', 'Failed to send reset email: $e');
      }
    }
  }

  // Show change password dialog
  void showChangePasswordDialog() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Current Password
              Obx(
                () => TextField(
                  controller: currentPasswordController,
                  obscureText: !showCurrentPassword.value,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () =>
                              showCurrentPassword.value =
                                  !showCurrentPassword.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // New Password
              Obx(
                () => TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () => showNewPassword.value = !showNewPassword.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText:
                        'At least 8 characters with uppercase, lowercase, and numbers',
                    helperMaxLines: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password
              Obx(
                () => TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed:
                          () =>
                              showConfirmPassword.value =
                                  !showConfirmPassword.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            isUpdatingPassword.value ? null : changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child:
                            isUpdatingPassword.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Password visibility toggles
  void toggleCurrentPasswordVisibility() =>
      showCurrentPassword.value = !showCurrentPassword.value;
  void toggleNewPasswordVisibility() =>
      showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPasswordVisibility() =>
      showConfirmPassword.value = !showConfirmPassword.value;

  // Logout
  void logout() {
    _showConfirmationDialog(
      'Logout',
      'Are you sure you want to logout? You will need to sign in again.',
      () async {
        try {
          await _auth.signOut();
          _clearUserData();
          Get.offAllNamed(Routes.AUTHENTCATION);
          _showSuccessSnackbar(
            'Logged Out',
            'You have been successfully logged out',
          );
        } catch (e) {
          _showErrorSnackbar('Logout Error', 'Failed to logout: $e');
        }
      },
    );
  }

  // Delete account
  void deleteAccount() {
    _showConfirmationDialog(
      'Delete Account',
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
      () async {
        try {
          isLoading.value = true;

          final uid = currentFirebaseUser.value!.uid;

          // Delete user data from Firestore
          await _firestore.collection('users').doc(uid).delete();

          // Delete user videos
          final videosQuery =
              await _firestore
                  .collection('videos')
                  .where('userId', isEqualTo: uid)
                  .get();

          final batch = _firestore.batch();
          for (var doc in videosQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();

          // Delete Firebase Auth account
          await currentFirebaseUser.value!.delete();

          _clearUserData();
          Get.offAllNamed(Routes.AUTHENTCATION);
          _showSuccessSnackbar(
            'Account Deleted',
            'Your account has been permanently deleted',
          );
        } catch (e) {
          if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
            _showErrorSnackbar(
              'Authentication Required',
              'Please sign in again to delete your account',
            );
          } else {
            _showErrorSnackbar('Delete Error', 'Failed to delete account: $e');
          }
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // Generic confirmation dialog
  void _showConfirmationDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  title.contains('Delete')
                      ? Colors.red
                      : const Color(0xFF4A90E2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              title.contains('Delete') ? 'Delete' : 'Confirm',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
    );
  }

  // Navigation methods
  void openSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void orderRouteScreen() {
    Get.to(() => OrdersPage());
  }
}
