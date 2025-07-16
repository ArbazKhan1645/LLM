import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';

final db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class AuthRepo {
  Stream<UserModel?> watchUser() {
    return db
        .collection("users")
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .map((e) {
          if (e.docs.isNotEmpty) {
            return UserModel.fromJson(e.docs.first.data());
          } else {
            return null;
          }
        });
  }

  User? get currentUser {
    return auth.currentUser;
  }

  bool get isLoggedIn {
    // Check if the user is logged in
    return currentUser != null;
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      if (kDebugMode) {
        print('User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  Future forgotPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (err) {
      throw Exception(err.message.toString());
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  // Future signInWithGoogle(String password) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;

  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );

  //     // Once signed in, return the UserCredential
  //     await auth.signInWithCredential(credential).then((value) async {
  //       await db.collection('customers').add(CustomerModel(
  //               email: value.user!.email,
  //               password: '',
  //               fullName: value.additionalUserInfo!.username,
  //               phoneNumber: value.user!.phoneNumber,
  //               userId: value.user!.uid,
  //               profilePicture: value.user!.photoURL)
  //           .toMap());
  //       print(value.user!.email);
  //       Get.snackbar(
  //           backgroundColor: CColors.greenColor,
  //           colorText: Colors.white,
  //           'Login',
  //           'Login Successfully');
  //     });
  //   } catch (e) {
  //     print("Error google sign in: $e");
  //   } // Trigger the authentication flow
  // }
}
