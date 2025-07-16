// ignore_for_file: avoid_print

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/check_out.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import 'package:llm_video_shopify/app/services/current_user_service/current_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopify_flutter/models/src/cart/inputs/attribute_input/attribute_input.dart';
import 'package:shopify_flutter/shopify_flutter.dart';

class ShopifyStoreController extends GetxController {
  static ShopifyStoreController get instance => Get.find();

  // Authentication
  final shopifyAuth = ShopifyAuth.instance;
  var shopifyUser = Rx<ShopifyUser?>(null);
  var isAuthenticated = false.obs;
  var isAuthenticating = false.obs;

  // Products
  var products = <Product>[].obs;
  var isLoadingProducts = false.obs;
  var selectedProduct = Rx<Product?>(null);
  var selectedVariant = Rx<ProductVariant?>(null);

  // Cart
  var cart = Rx<Cart?>(null);
  var cartItemCount = 0.obs;
  var isLoading = false.obs;
  var userId = ''.obs;

  // Orders
  var orders = <Order>[].obs;
  var isLoadingOrders = false.obs;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static credentials for Shopify authentication
  static const String _staticPassword = '4Sve75WQtjHHFdB';

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // AUTHENTICATION METHODS
  Future<void> _initializeApp() async {
    try {
      await _initializeShopifyAuth();
      await _initializeUser();
    } catch (e) {
      log('❌ Error initializing app: $e');
      showErrorSnackbar('Failed to initialize app', e.toString());
    }
  }

  Future<void> _initializeShopifyAuth() async {
    try {
      isAuthenticating.value = true;

      await FirebaseAuth.instance.currentUser?.reload();

      // Get Firebase user email
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.email == null) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Login Required'),
            content: const Text(
              'Your session has expired or no user is logged in. Please log out and sign in again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back(); // Close the dialog
                  await FirebaseAuth.instance.signOut();
                  // Optional: Navigate to login screen
                  Get.offAllNamed(Routes.AUTHENTCATION);
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        throw Exception('No Firebase user found');
      }

      final email = firebaseUser!.email!;

      // Check if already logged in to Shopify
      final isTokenExpired = await shopifyAuth.isAccessTokenExpired;

      if (!isTokenExpired) {
        // Token is valid, get current user
        final user = await shopifyAuth.currentUser();
        if (user != null) {
          shopifyUser.value = user;
          isAuthenticated.value = true;

          // Save access token to Firestore
          await _saveAccessTokenToFirestore();

          log('✅ Already authenticated with Shopify');
          return;
        }
      }

      // Try to sign in with existing credentials
      try {
        await shopifyAuth.signInWithEmailAndPassword(
          email: email,
          password: _staticPassword,
        );

        final user = await shopifyAuth.currentUser();
        shopifyUser.value = user;
        isAuthenticated.value = true;

        // Save access token to Firestore after successful sign in
        await _saveAccessTokenToFirestore();

        log('✅ Successfully signed in to Shopify');
      } catch (signInError) {
        log('Sign in failed, attempting to create account: $signInError');

        // If sign in fails, try to create account
        try {
          final createdUser = await shopifyAuth.createUserWithEmailAndPassword(
            email: email,
            password: _staticPassword,
            firstName: UserService.to.user.value?.fullName ?? 'User',
            lastName: '',
            acceptsMarketing: true,
          );

          shopifyUser.value = createdUser;
          isAuthenticated.value = true;

          // Save access token to Firestore after successful account creation
          await _saveAccessTokenToFirestore();

          log('✅ Successfully created and signed in to Shopify');
        } catch (createError) {
          log('❌ Failed to create Shopify account: $createError');
          throw Exception('Failed to authenticate with Shopify: $createError');
        }
      }
    } catch (e) {
      log('❌ Shopify authentication error: $e');
      isAuthenticated.value = false;
      shopifyUser.value = null;
      rethrow;
    } finally {
      isAuthenticating.value = false;
    }
  }

  /// Save Shopify access token to Firestore
  Future<void> _saveAccessTokenToFirestore() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.uid == null) {
        log('❌ No Firebase user found, cannot save access token');
        return;
      }

      final accessToken = await shopifyAuth.currentCustomerAccessToken;
      if (accessToken == null || accessToken.isEmpty) {
        log('❌ No access token available to save');
        return;
      }

      final userDocRef = _firestore.collection('users').doc(firebaseUser!.uid);

      // Update the user document with the Shopify access token
      await userDocRef.update({
        'shopifyAccessToken': accessToken,
        'shopifyAccessTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      log(
        '✅ Shopify access token saved to Firestore for user: ${firebaseUser.uid}',
      );
    } catch (e) {
      log('❌ Error saving access token to Firestore: $e');

      // If update fails, try to set the document (in case it doesn't exist)
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser?.uid != null) {
          final accessToken = await shopifyAuth.currentCustomerAccessToken;
          if (accessToken != null && accessToken.isNotEmpty) {
            await _firestore.collection('users').doc(firebaseUser!.uid).set({
              'shopifyAccessToken': accessToken,
              'shopifyAccessTokenUpdatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            log(
              '✅ Shopify access token set to Firestore for user: ${firebaseUser.uid}',
            );
          }
        }
      } catch (setError) {
        log('❌ Error setting access token to Firestore: $setError');
      }
    }
  }

  /// Retrieve Shopify access token from Firestore
  Future<String?> _getAccessTokenFromFirestore() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.uid == null) {
        log('❌ No Firebase user found, cannot retrieve access token');
        return null;
      }

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        final accessToken = data?['shopifyAccessToken'] as String?;

        if (accessToken != null && accessToken.isNotEmpty) {
          log('✅ Retrieved Shopify access token from Firestore');
          return accessToken;
        }
      }

      log('⚠️ No access token found in Firestore');
      return null;
    } catch (e) {
      log('❌ Error retrieving access token from Firestore: $e');
      return null;
    }
  }

  /// Clear Shopify access token from Firestore
  Future<void> _clearAccessTokenFromFirestore() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.uid == null) {
        log('❌ No Firebase user found, cannot clear access token');
        return;
      }

      final userDocRef = _firestore.collection('users').doc(firebaseUser!.uid);

      // Remove the Shopify access token fields
      await userDocRef.update({
        'shopifyAccessToken': FieldValue.delete(),
        'shopifyAccessTokenUpdatedAt': FieldValue.delete(),
      });

      log(
        '✅ Shopify access token cleared from Firestore for user: ${firebaseUser.uid}',
      );
    } catch (e) {
      log('❌ Error clearing access token from Firestore: $e');
    }
  }

  Future<void> _initializeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser?.uid == null) {
        throw Exception('No Firebase user found');
      }

      // Generate user ID based on Firebase UID
      final generatedUserId = 'shopify_user_${firebaseUser!.uid}';
      userId.value = generatedUserId;

      // Save user ID for consistency
      await prefs.setString('shopify_user_id', generatedUserId);

      // Load existing cart for this user
      await loadUserCart();
    } catch (e) {
      log('❌ Error initializing user: $e');
      throw Exception('Failed to initialize user: $e');
    }
  }

  // CART METHODS
  Future<void> loadUserCart() async {
    try {
      if (userId.value.isEmpty) {
        throw Exception('User ID is empty');
      }

      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'cart_${userId.value}';
      final savedCartId = prefs.getString(cartKey);

      if (savedCartId != null && savedCartId.isNotEmpty) {
        try {
          final existingCart = await ShopifyCart.instance.getCartById(
            savedCartId,
          );

          if (existingCart != null) {
            cart.value = existingCart;
            cartItemCount.value = existingCart.lines.length;
            log(
              '✅ Loaded existing cart with ${existingCart.lines.length} items',
            );
            return;
          }
        } catch (e) {
          log('❌ Failed to load existing cart: $e');
        }
      }

      // Create new cart if none exists or loading failed
      await _createNewCart();
    } catch (e) {
      log('❌ Error loading user cart: $e');
      await _createNewCart();
    }
  }

  Future<void> _createNewCart() async {
    try {
      isLoading.value = true;

      if (!isAuthenticated.value) {
        throw Exception('User not authenticated');
      }

      final accessToken = await shopifyAuth.currentCustomerAccessToken;
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser?.email == null) {
        throw Exception('No Firebase user email found');
      }

      final newCart = await ShopifyCart.instance.createCart(
        CartInput(
          lines: [],
          buyerIdentity: CartBuyerIdentityInput(
            customerAccessToken: accessToken,
            email: firebaseUser!.email!,
            countryCode: 'US',
            deliveryAddressPreferences: [],
          ),
          attributes: [
            AttributeInput(key: 'user_id', value: userId.value),
            AttributeInput(
              key: 'created_at',
              value: DateTime.now().toIso8601String(),
            ),
          ],
          discountCodes: [],
          note: 'Cart for user: ${userId.value}',
        ),
      );

      cart.value = newCart;
      cartItemCount.value = 0;

      // Save cart ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_${userId.value}', newCart.id);

      log('✅ Created new cart: ${newCart.id}');
    } catch (e) {
      log('❌ Error creating cart: $e');
      showErrorSnackbar('Failed to create cart', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(
    Product product, {
    ProductVariant? variant,
    int quantity = 1,
  }) async {
    try {
      if (!isAuthenticated.value) {
        showErrorSnackbar('Authentication required', 'Please log in first');
        return;
      }

      isLoading.value = true;

      // Ensure cart exists
      if (cart.value == null) {
        await _createNewCart();
      }

      if (cart.value == null) {
        throw Exception('Failed to create cart');
      }

      // Use provided variant or first available variant
      ProductVariant? selectedVariant = variant;
      if (selectedVariant == null && product.productVariants.isNotEmpty) {
        selectedVariant = product.productVariants.first;
      }

      if (selectedVariant == null) {
        throw Exception('No product variant available');
      }

      // Check if item already exists in cart
      final existingLineIndex = cart.value!.lines.indexWhere(
        (line) => line.merchandise?.id == selectedVariant!.id,
      );

      if (existingLineIndex != -1) {
        // Update existing item quantity
        final existingLine = cart.value!.lines[existingLineIndex];
        await updateQuantity(
          existingLine.id ?? '',
          (existingLine.quantity ?? 0) + quantity,
        );
      } else {
        // Add new item to cart
        final updatedCart = await ShopifyCart.instance.addLineItemsToCart(
          cartId: cart.value!.id,
          cartLineInputs: [
            CartLineUpdateInput(
              merchandiseId: selectedVariant.id,
              quantity: quantity,
              attributes: [
                AttributeInput(key: 'product_title', value: product.title),
                AttributeInput(
                  key: 'variant_title',
                  value: selectedVariant.title,
                ),
              ],
            ),
          ],
        );

        cart.value = updatedCart;
        cartItemCount.value = updatedCart.lines.length;
      }

      _showSuccessSnackbar(
        'Added to cart',
        '${product.title}${variant != null ? ' (${variant.title})' : ''} added to cart',
      );
    } catch (e) {
      log('❌ Error adding to cart: $e');
      showErrorSnackbar('Failed to add to cart', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItem(String lineItemId) async {
    try {
      if (cart.value == null) {
        throw Exception('Cart is empty');
      }

      isLoading.value = true;

      final updatedCart = await ShopifyCart.instance.removeLineItemsFromCart(
        cartId: cart.value!.id,
        lineIds: [lineItemId],
      );

      cart.value = updatedCart;
      cartItemCount.value = updatedCart.lines.length;

      _showSuccessSnackbar('Item removed', 'Item removed from cart');
      log('✅ Removed item from cart. Total items: ${cartItemCount.value}');
    } catch (e) {
      log('❌ Error removing item: $e');
      showErrorSnackbar('Failed to remove item', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(String lineItemId, int newQuantity) async {
    try {
      if (cart.value == null) {
        throw Exception('Cart is empty');
      }

      if (newQuantity <= 0) {
        await removeItem(lineItemId);
        return;
      }

      isLoading.value = true;

      final line = cart.value!.lines.firstWhere(
        (l) => l.id == lineItemId,
        orElse: () => throw Exception('Line item not found'),
      );

      final updatedCart = await ShopifyCart.instance.updateLineItemsInCart(
        cartId: cart.value!.id,
        cartLineInputs: [
          CartLineUpdateInput(
            merchandiseId: line.merchandise?.id ?? '',
            quantity: newQuantity,
            id: line.id,
            attributes:
                line.attributes
                    ?.map(
                      (attr) => AttributeInput(
                        key: attr?.key ?? '',
                        value: attr?.value ?? '',
                      ),
                    )
                    .toList() ??
                [],
          ),
        ],
      );

      cart.value = updatedCart;
      cartItemCount.value = updatedCart.lines.length;

      log(
        '✅ Updated quantity to $newQuantity. Total items: ${cartItemCount.value}',
      );
    } catch (e) {
      log('❌ Error updating quantity: $e');
      showErrorSnackbar('Failed to update quantity', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkout() async {
    try {
      if (cart.value == null || cart.value!.lines.isEmpty) {
        showErrorSnackbar('Empty cart', 'Please add items to cart first');
        return;
      }

      isLoading.value = true;

      final checkoutUrl = cart.value?.checkoutUrl;

      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        Get.to(() => WebViewCheckout(checkoutUrl: checkoutUrl));
        log('✅ Navigating to checkout: $checkoutUrl');
      } else {
        throw Exception('No checkout URL available');
      }
    } catch (e) {
      log('❌ Error during checkout: $e');
      showErrorSnackbar('Checkout failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      if (userId.value.isEmpty) {
        throw Exception('User ID is empty');
      }

      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_${userId.value}');

      cart.value = null;
      cartItemCount.value = 0;

      await _createNewCart();

      _showSuccessSnackbar('Cart cleared', 'Starting with a fresh cart');
      log('✅ Cart cleared successfully');
    } catch (e) {
      log('❌ Error clearing cart: $e');
      showErrorSnackbar('Failed to clear cart', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // PRODUCT METHODS
  Future<void> fetchProducts() async {
    try {
      isLoadingProducts.value = true;

      final fetchedProducts = await ShopifyStore.instance.getAllProducts();

      if (fetchedProducts != null && fetchedProducts.isNotEmpty) {
        products.value = fetchedProducts;
        log('✅ Fetched ${fetchedProducts.length} products');
      } else {
        products.value = [];
        log('⚠️ No products found');
      }
    } catch (e) {
      log('❌ Error fetching products: $e');
      showErrorSnackbar('Failed to load products', e.toString());
      products.value = [];
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<Product?> getProductDetails(String productId) async {
    try {
      final productDetails = await ShopifyStore.instance.getProductsByIds([
        productId,
      ]);

      if (productDetails != null && productDetails.isNotEmpty) {
        return productDetails.first;
      }

      return null;
    } catch (e) {
      log('❌ Error fetching product details: $e');
      return null;
    }
  }

  void selectProduct(Product product) {
    selectedProduct.value = product;
    selectedVariant.value =
        product.productVariants.isNotEmpty
            ? product.productVariants.first
            : null;
  }

  void selectVariant(ProductVariant variant) {
    selectedVariant.value = variant;
  }

  // ORDER METHODS
  Future<void> fetchOrders() async {
    try {
      if (!isAuthenticated.value) {
        showErrorSnackbar('Authentication required', 'Please log in first');
        return;
      }

      isLoadingOrders.value = true;

      final accessToken = await shopifyAuth.currentCustomerAccessToken;

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      final fetchedOrders = await ShopifyOrder.instance.getAllOrders(
        accessToken,
      );

      if (fetchedOrders != null) {
        orders.value = fetchedOrders;
        log('✅ Fetched ${fetchedOrders.length} orders');
      } else {
        orders.value = [];
        log('⚠️ No orders found');
      }
    } catch (e) {
      log('❌ Error fetching orders: $e');
      showErrorSnackbar('Failed to load orders', e.toString());
      orders.value = [];
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // UTILITY METHODS
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  // REFRESH METHODS
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProducts(),
      loadUserCart(),
      if (isAuthenticated.value) fetchOrders(),
    ]);
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      // Clear access token from Firestore before signing out
      await _clearAccessTokenFromFirestore();

      await shopifyAuth.signOutCurrentUser();

      // Clear all data
      shopifyUser.value = null;
      isAuthenticated.value = false;
      cart.value = null;
      cartItemCount.value = 0;
      orders.value = [];

      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_${userId.value}');
      await prefs.remove('shopify_user_id');

      _showSuccessSnackbar('Signed out', 'Successfully signed out');
      log('✅ Successfully signed out');
    } catch (e) {
      log('❌ Error signing out: $e');
      showErrorSnackbar('Sign out failed', e.toString());
    }
  }

  // PUBLIC METHOD TO MANUALLY REFRESH ACCESS TOKEN
  Future<void> refreshAccessToken() async {
    try {
      if (!isAuthenticated.value) {
        log('⚠️ User not authenticated, cannot refresh access token');
        return;
      }

      await _saveAccessTokenToFirestore();
      log('✅ Access token refreshed and saved to Firestore');
    } catch (e) {
      log('❌ Error refreshing access token: $e');
    }
  }
}
