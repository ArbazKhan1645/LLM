import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:llm_video_shopify/app/services/current_user_service/current_user_service.dart';
import 'package:shopify_flutter/shopify_flutter.dart';

class AuthTab extends StatefulWidget {
  const AuthTab({super.key});

  @override
  State<AuthTab> createState() => _AuthTabState();
}

class _AuthTabState extends State<AuthTab> {
  final shopifyAuth = ShopifyAuth.instance;
  ShopifyUser? shopifyUser;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    try {
      final isTokenExpired = await shopifyAuth.isAccessTokenExpired;
      log('isTokenExpired: $isTokenExpired');
      if (isTokenExpired) {
        setState(() => shopifyUser = null);
        final accessToken = await shopifyAuth.currentCustomerAccessToken;
        if (accessToken != null) {
          final user = await shopifyAuth.currentUser();
          setState(() => shopifyUser = user);
          log('shopifyUser after token refresh: $shopifyUser');
        } else {
          log('Token Expired. Login Again.');
        }
      } else {
        final user = await shopifyAuth.currentUser();
        setState(() => shopifyUser = user);
        log('shopifyUser: $shopifyUser');
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint(e.toString());
    }
  }

  Future<void> _login() async {
    try {
      await shopifyAuth.signInWithEmailAndPassword(
        email: 'shahlili1645@gmail.com',
        password: '4Sve75WQtjHHFdB',
      );
      _checkIfLoggedIn();
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
    }
  }

  Future<void> _register() async {
    try {
      final createdUser = await shopifyAuth.createUserWithEmailAndPassword(
        email: 'shahlili1645@gmail.com',
        password: '4Sve75WQtjHHFdB',
        firstName: UserService.to.user.value?.fullName ?? '-',
        lastName: '-',
        acceptsMarketing: true,
      );
      setState(() {
        shopifyUser = createdUser;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
    }
  }

  Future<void> _signout() async {
    try {
      await shopifyAuth.signOutCurrentUser();

      _checkIfLoggedIn();
    } catch (e) {
      if (!mounted) return;

      debugPrint(e.toString());
    }
  }

  Future<void> _deleteAccount() async {
    if (shopifyUser == null || shopifyUser!.id == null) return;
    try {
      await shopifyAuth.deleteCustomer(userId: '${shopifyUser?.id}');
      setState(() {
        shopifyUser = null;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('shopifyUser: ${shopifyUser?.email}'),
            if (shopifyUser == null)
              ElevatedButton(
                onPressed: () => _login(),
                child: const Text('Sign In'),
              )
            else ...[
              ElevatedButton(
                onPressed: () => _signout(),
                child: const Text('Sign Out'),
              ),
              ElevatedButton(
                onPressed: () => _deleteAccount(),
                child: const Text('Delete Account'),
              ),
            ],
            if (shopifyUser == null) ...[
              const Divider(),
              ElevatedButton(
                onPressed: () => _register(),
                child: const Text('Sign Up'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
