import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/controllers/shopify_store_controller.dart';
import 'package:shopify_flutter/shopify_flutter.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  final ShopifyStoreController controller =
      Get.isRegistered<ShopifyStoreController>()
          ? Get.find<ShopifyStoreController>()
          : Get.put(ShopifyStoreController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeOrders() async {
    if (controller.isAuthenticated.value) {
      await controller.fetchOrders();
    }
  }

  Future<void> _refreshOrders() async {
    await controller.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Obx(() => _buildBody()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Order History',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        Obx(
          () =>
              controller.isAuthenticated.value
                  ? IconButton(
                    onPressed:
                        controller.isLoadingOrders.value
                            ? null
                            : _refreshOrders,
                    icon:
                        controller.isLoadingOrders.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    tooltip: 'Refresh Orders',
                  )
                  : const SizedBox(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (!controller.isAuthenticated.value) {
      return _buildNotAuthenticatedState();
    }

    if (controller.isLoadingOrders.value && controller.orders.isEmpty) {
      return _buildLoadingState();
    }

    if (controller.orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrdersList();
  }

  Widget _buildNotAuthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to view your order history',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // ElevatedButton.icon(
          //   onPressed: () => controller._initializeShopifyAuth(),
          //   icon: const Icon(Icons.login),
          //   label: const Text('Login'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue.shade600,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your orders...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here\nafter you make your first purchase',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: Column(
        children: [
          _buildOrdersSummaryCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return _buildOrderCard(order, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummaryCard() {
    final orderCount = controller.orders.length;
    final totalSpent = controller.orders.fold<double>(
      0.0,
      (sum, order) => sum + (order.totalPriceV2.amount ?? 0.0),
    );

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.green.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$orderCount Order${orderCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total spent: \$${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: Colors.green.shade600, size: 24),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getOrderStatusColor(
              order.fulfillmentStatus,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getOrderStatusIcon(order.fulfillmentStatus),
            color: _getOrderStatusColor(order.fulfillmentStatus),
            size: 20,
          ),
        ),
        title: Text(
          order.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatOrderDate(order.processedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getOrderStatusColor(
                      order.fulfillmentStatus,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getOrderStatusText(order.fulfillmentStatus),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getOrderStatusColor(order.fulfillmentStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order.totalPriceV2.formattedPrice ?? '\$0.00',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [_buildOrderDetails(order)],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),

        // Order summary
        Row(
          children: [
            Expanded(
              child: _buildOrderSummaryItem(
                'Items',
                '${order.lineItems.lineItemOrderList.length}',
                Icons.shopping_bag_outlined,
              ),
            ),
            Expanded(
              child: _buildOrderSummaryItem(
                'Subtotal',
                order.subtotalPriceV2.formattedPrice ?? '\$0.00',
                Icons.calculate_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildOrderSummaryItem(
                'Tax',
                order.totalTaxV2.formattedPrice ?? '\$0.00',
                Icons.percent,
              ),
            ),
            Expanded(
              child: _buildOrderSummaryItem(
                'Shipping',
                order.totalShippingPriceV2.formattedPrice ?? 'Free',
                Icons.local_shipping_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Order items
        const Text(
          'Items:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...order.lineItems.lineItemOrderList.map(
          (item) => _buildOrderItem(item),
        ),

        const SizedBox(height: 16),

        // Shipping address if available
        if (order.shippingAddress != null) ...[
          const Text(
            'Shipping Address:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // _buildShippingAddress(order.shippingAddress!),
        ],
      ],
    );
  }

  Widget _buildOrderSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(LineItemOrder item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.currentQuantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (item.originalTotalPrice.amount !=
                    item.discountedTotalPrice.amount) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        item.originalTotalPrice.formattedPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SALE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            item.discountedTotalPrice.formattedPrice,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(MailingAddress address) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.name?.isNotEmpty == true)
                  Text(
                    address.name!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                if (address.address1.isNotEmpty == true) Text(address.address1),
                if (address.address2?.isNotEmpty == true)
                  Text(address.address2!),
                Text(
                  '${address.city ?? ''}, ${address.province ?? ''} ${address.zip ?? ''}',
                ),
                if (address.country.isNotEmpty == true) Text(address.country),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'fulfilled':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unfulfilled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getOrderStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'fulfilled':
        return Icons.check_circle;
      case 'partial':
        return Icons.pending;
      case 'unfulfilled':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _getOrderStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'fulfilled':
        return 'Delivered';
      case 'partial':
        return 'Partial';
      case 'unfulfilled':
        return 'Processing';
      default:
        return 'Unknown';
    }
  }

  String _formatOrderDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
