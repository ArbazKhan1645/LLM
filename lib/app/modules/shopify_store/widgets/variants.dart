import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/controllers/shopify_store_controller.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/cart_screen.dart';
import 'package:shopify_flutter/shopify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ShopifyStoreController controller = Get.find<ShopifyStoreController>();
  final PageController pageController = PageController();

  ProductVariant? selectedVariant;
  int selectedImageIndex = 0;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeProduct();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _initializeProduct() {
    controller.selectProduct(widget.product);

    // Set initial selected variant
    if (widget.product.productVariants.isNotEmpty) {
      selectedVariant = widget.product.productVariants.first;
      controller.selectVariant(selectedVariant!);
    }
  }

  void _onVariantSelected(ProductVariant variant) {
    setState(() {
      selectedVariant = variant;
    });
    controller.selectVariant(variant);
  }

  void _onImageChanged(int index) {
    setState(() {
      selectedImageIndex = index;
    });
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    if (selectedVariant == null && widget.product.productVariants.isNotEmpty) {
      controller.showErrorSnackbar(
        'Select Variant',
        'Please select a product variant',
      );
      return;
    }

    await controller.addToCart(
      widget.product,
      variant: selectedVariant,
      quantity: quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                if (widget.product.productVariants.isNotEmpty)
                  _buildVariantSelection(),
                _buildQuantitySelector(),
                _buildDescription(),
                // _buildAddToCartSection(),
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingAddToCart(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(background: _buildImageGallery()),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                if (controller.cart.value == null ||
                    controller.cartItemCount.value == 0) {
                  controller.showInfoSnackbar(
                    'Cart Empty',
                    'Your cart is empty',
                  );
                  return;
                }
                Get.to(() => CartPage());
              },
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
      ],
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images;

    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported,
          size: 100,
          color: Colors.grey.shade400,
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: _onImageChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index].originalSrc,
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
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                  ),
            );
          },
        ),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            selectedImageIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
            ),
          ),

        // Navigation arrows
        if (images.length > 1) ...[
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed:
                    selectedImageIndex > 0
                        ? () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        : null,
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed:
                    selectedImageIndex < images.length - 1
                        ? () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        : null,
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Type
          if (widget.product.productType.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.product.productType,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Product Title
          Text(
            widget.product.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Price
          Row(
            children: [
              Text(
                selectedVariant?.price.formattedPriceWithLocale('en_US') ??
                    '\$${(widget.product.price ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),

              // Availability
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (selectedVariant?.availableForSale ?? true)
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (selectedVariant?.availableForSale ?? true)
                      ? 'In Stock'
                      : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        (selectedVariant?.availableForSale ?? true)
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSelection() {
    final variants = widget.product.productVariants;

    if (variants.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Variant:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                variants.map((variant) {
                  final isSelected = selectedVariant?.id == variant.id;
                  final isAvailable = variant.availableForSale;

                  final itemWidth =
                      (MediaQuery.of(context).size.width - 48) / 2;

                  return InkWell(
                    onTap:
                        isAvailable ? () => _onVariantSelected(variant) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.blue.shade600
                                : isAvailable
                                ? Colors.grey.shade100
                                : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            variant.title,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : isAvailable
                                      ? Colors.black87
                                      : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          Text(
                            variant.price.formattedPriceWithLocale('en_US'),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : isAvailable
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade600,
                            ),
                          ),
                          if (!isAvailable)
                            Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final isAvailable = selectedVariant?.availableForSale ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              IconButton(
                onPressed:
                    isAvailable && quantity > 1 ? _decrementQuantity : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor:
                      isAvailable && quantity > 1
                          ? Colors.black87
                          : Colors.grey.shade400,
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: isAvailable ? _incrementQuantity : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor:
                      isAvailable ? Colors.black87 : Colors.grey.shade400,
                ),
              ),

              const Spacer(),

              Text(
                'Total: ${selectedVariant?.price != null ? '\$${(double.parse(selectedVariant!.price.formattedPriceWithLocale('en_US').replaceAll(RegExp(r'[\$\£\€]'), '')) * quantity).toStringAsFixed(2)}' : '\$${((widget.product.price ?? 0) * quantity).toStringAsFixed(2)}'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if ((widget.product.description ?? '').isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Text(
            widget.product.description ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddToCartSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ready to add to cart?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Add $quantity item${quantity > 1 ? 's' : ''} to your cart',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Obx(
                () =>
                    controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                          onPressed:
                              (selectedVariant?.availableForSale ?? true)
                                  ? _addToCart
                                  : null,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddToCart() {
    return Obx(
      () => AnimatedOpacity(
        opacity: (selectedVariant?.availableForSale ?? true) ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap:
              controller.isLoading.value ||
                      !(selectedVariant?.availableForSale ?? true)
                  ? null
                  : _addToCart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  controller.isLoading.value ||
                          !(selectedVariant?.availableForSale ?? true)
                      ? Colors.blue.shade300
                      : Colors.blue.shade600,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                controller.isLoading.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.add_shopping_cart, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  controller.isLoading.value
                      ? 'Adding...'
                      : 'Add $quantity to Cart',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
