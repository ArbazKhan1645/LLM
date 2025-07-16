import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/controllers/shopify_store_controller.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/cart_screen.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/orders.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/variants.dart';

import 'package:shopify_flutter/shopify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ShopifyStoreController controller = Get.put(ShopifyStoreController());
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Product> filteredProducts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupSearchListener();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await controller.fetchProducts();
    _filterProducts();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        _filterProducts();
      });
    });
  }

  void _filterProducts() {
    final products = controller.products;
    if (searchQuery.isEmpty) {
      filteredProducts = products.toList();
    } else {
      filteredProducts =
          products.where((product) {
            return product.title.toLowerCase().contains(searchQuery) ||
                product.description.toString().toLowerCase().contains(
                  searchQuery,
                ) ||
                product.productType.toLowerCase().contains(searchQuery);
          }).toList();
    }
  }

  void _navigateToCart() {
    if (controller.cart.value == null || controller.cartItemCount.value == 0) {
      controller.showInfoSnackbar('Cart Empty', 'Your cart is empty');
      return;
    }
    Get.to(() => CartPage());
  }

  Future<void> _refreshProducts() async {
    await controller.fetchProducts();
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _buildUserInfoCard(),
          _buildSearchBar(),
          _buildProductList(),
          SizedBox(height: 150),
        ],
      ),
      // floatingActionButton: _buildFloatingCartButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          Get.to(() => OrdersPage());
        },
        tooltip: 'View Order History',
      ),
      title: const Text(
        'Ptchpal Store',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: _navigateToCart,
              tooltip: 'View Cart',
            ),
            Obx(
              () =>
                  controller.cartItemCount.value > 0
                      ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            controller.cartItemCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  controller.isAuthenticated.value
                      ? Colors.green.shade100
                      : Colors.red.shade100,
              child: Icon(
                controller.isAuthenticated.value
                    ? Icons.person
                    : Icons.person_off,
                color:
                    controller.isAuthenticated.value
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isAuthenticating.value
                        ? 'Authenticating...'
                        : controller.isAuthenticated.value
                        ? 'Welcome, ${controller.shopifyUser.value?.firstName ?? "User"}'
                        : 'Not authenticated',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.isAuthenticated.value)
              TextButton.icon(
                onPressed: () {
                  controller.clearCart();
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear Cart'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Search products...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: null,
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading products...'),
            ],
          ),
        );
      }

      if (controller.products.isEmpty) {
        return _buildEmptyState();
      }

      if (filteredProducts.isEmpty) {
        return _buildNoResultsState();
      }

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        controller: scrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProducts,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              searchController.clear();
            },
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          controller.selectProduct(product);
          Get.to(() => ProductDetailScreen(product: product));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildProductImage(product),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.productType.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.productType,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Description
                  if ((product.description ?? '').isNotEmpty)
                    Text(
                      product.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Price and Variants Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${product.formattedPrice}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (product.productVariants.isNotEmpty)
                              Text(
                                '${product.productVariants.length} variant${product.productVariants.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Add to Cart Button
                      Obx(
                        () =>
                            controller.isLoading.value
                                ? const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : _buildQuickAddButton(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'PKR':
        return '₨';
      default:
        return code; // fallback to code if symbol not mapped
    }
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      child: AspectRatio(
        aspectRatio: 16 / 15,
        child:
            product.images.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: product.images.first.originalSrc,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                )
                : Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
      ),
    );
  }

  Widget _buildQuickAddButton(Product product) {
    if (product.productVariants.length <= 1) {
      // Single variant or no variants - quick add
      return IconButton(
        onPressed: () => controller.addToCart(product),
        icon: const Icon(Icons.add_shopping_cart),
        color: Colors.blue.shade600, // Optional: change icon color
        tooltip: 'Add to Cart', // Optional: shows on long-press
      );
    } else {
      return const SizedBox();
    }
  }
}
