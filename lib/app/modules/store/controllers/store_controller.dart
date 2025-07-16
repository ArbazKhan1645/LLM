import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreController extends GetxController {
  // Search and filtering
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Products management
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;

  // UI state
  final RxString selectedCategory = 'ALL PRODUCTS'.obs;
  final RxList<String> categories =
      <String>[
        'ALL PRODUCTS',
        'CLOTHING',
        'ACCESSORIES',
        'ELECTRONICS',
        'HOME & GARDEN',
      ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeProducts();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterProducts();
    });
  }

  void _initializeProducts() async {
    isLoading.value = true;

    // // Simulate API call
    // await Future.delayed(const Duration(milliseconds: 800));

    allProducts.addAll([
      Product(
        id: '1',
        name: 'WHITE HOODIE BLACK HEART PRINT',
        price: 3.54,
        originalPrice: 5.89,
        rating: 4.2,
        reviews: 128,
        imageUrl: 'assets/images/pro1.png',
        category: 'CLOTHING',
        isOnSale: true,
      ),
      Product(
        id: '2',
        name: 'JEWELLERY ORGANIZER BOX',
        price: 2.11,
        originalPrice: 3.50,
        rating: 4.7,
        reviews: 89,
        imageUrl: 'assets/images/pro2.png',
        category: 'ACCESSORIES',
        isOnSale: true,
      ),
      Product(
        id: '3',
        name: 'ELECTRIC CABLE MASSAGER',
        price: 3.14,
        originalPrice: 4.99,
        rating: 4.5,
        reviews: 156,
        imageUrl: 'assets/images/pro1.png',
        category: 'ELECTRONICS',
        isOnSale: true,
      ),
      Product(
        id: '4',
        name: 'WOMEN FLORAL FROCK',
        price: 3.11,
        originalPrice: 4.89,
        rating: 4.1,
        reviews: 67,
        imageUrl: 'assets/images/pro2.png',
        category: 'CLOTHING',
        isOnSale: true,
      ),
      Product(
        id: '5',
        name: 'CRYSTAL BEADED BRACELET',
        price: 2.85,
        originalPrice: 4.20,
        rating: 4.8,
        reviews: 234,
        imageUrl: 'assets/images/pro1.png',
        category: 'ACCESSORIES',
        isOnSale: true,
      ),
      Product(
        id: '6',
        name: 'GOLD RING SET',
        price: 15.99,
        originalPrice: 22.50,
        rating: 4.9,
        reviews: 89,
        imageUrl: 'assets/images/pro2.png',
        category: 'ACCESSORIES',
        isOnSale: true,
      ),
      Product(
        id: '7',
        name: 'LEATHER HANDBAG CHAIN',
        price: 4.25,
        originalPrice: 6.99,
        rating: 4.6,
        reviews: 142,
        imageUrl: 'assets/images/pro1.png',
        category: 'ACCESSORIES',
        isOnSale: true,
      ),
      Product(
        id: '8',
        name: 'CASUAL SUMMER DRESS',
        price: 2.99,
        originalPrice: 4.50,
        rating: 4.3,
        reviews: 98,
        imageUrl: 'assets/images/pro2.png',
        category: 'CLOTHING',
        isOnSale: true,
      ),
    ]);

    filteredProducts.addAll(allProducts);
    isLoading.value = false;
  }

  void _filterProducts() {
    List<Product> filtered =
        allProducts.where((product) {
          final matchesSearch =
              searchQuery.value.isEmpty ||
              product.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );
          final matchesCategory =
              selectedCategory.value == 'ALL PRODUCTS' ||
              product.category == selectedCategory.value;

          return matchesSearch && matchesCategory;
        }).toList();

    filteredProducts.assignAll(filtered);
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _filterProducts();
    HapticFeedback.lightImpact();
  }

  void addToCart(Product product) {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
    );
  }

  void onProductTap(Product product) {
    HapticFeedback.lightImpact();
    // Get.to(() => ProductDetailScreen(product: product));
  }

  void openCamera() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Camera',
      'Visual search feature coming soon!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4A90E2),
      colorText: Colors.white,
    );
  }
}

// Product Model
class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String category;
  final bool isOnSale;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.category,
    this.isOnSale = false,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice =>
      originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : '';
}
