import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopify_flutter/shopify_flutter.dart';
import 'package:intl/intl.dart';

class UsersOrdersHistoryPage extends StatefulWidget {
  const UsersOrdersHistoryPage({super.key, required this.accessToken});
  final String accessToken;

  @override
  State<UsersOrdersHistoryPage> createState() => _UsersOrdersHistoryPageState();
}

class _UsersOrdersHistoryPageState extends State<UsersOrdersHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Loading states
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await fetchOrders();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });
    await fetchOrders();
    setState(() {
      _isRefreshing = false;
    });
  }

  final shopifyAuth = ShopifyAuth.instance;
  var orders = <Order>[];

  Future<void> fetchOrders() async {
    try {
      final fetchedOrders = await ShopifyOrder.instance.getAllOrders(
        widget.accessToken,
      );

      if (fetchedOrders != null) {
        setState(() {
          orders = fetchedOrders;
          _errorMessage = null;
        });
      } else {
        setState(() {
          orders = [];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        orders = [];
        _errorMessage = 'Failed to load orders: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'User Order History',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        _isRefreshing
            ? Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 16),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
            : IconButton(
              onPressed: _refreshOrders,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Orders',
            ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildShimmerLoadingState();
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrdersList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 24),
          Text(
            'Error Loading Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _initializeOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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

  Widget _buildShimmerLoadingState() {
    return Column(
      children: [
        _buildShimmerSummaryCard(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // Show 5 shimmer cards
            itemBuilder: (context, index) => _buildShimmerOrderCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSummaryCard() {
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
          _buildShimmerContainer(48, 48, BorderRadius.circular(8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(120, 18, BorderRadius.circular(4)),
                const SizedBox(height: 8),
                _buildShimmerContainer(80, 14, BorderRadius.circular(4)),
              ],
            ),
          ),
          _buildShimmerContainer(24, 24, BorderRadius.circular(12)),
        ],
      ),
    );
  }

  Widget _buildShimmerOrderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          _buildShimmerContainer(40, 40, BorderRadius.circular(8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(100, 16, BorderRadius.circular(4)),
                const SizedBox(height: 8),
                _buildShimmerContainer(150, 12, BorderRadius.circular(4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildShimmerContainer(60, 20, BorderRadius.circular(4)),
                    const Spacer(),
                    _buildShimmerContainer(70, 16, BorderRadius.circular(4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(
    double width,
    double height,
    BorderRadius borderRadius,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [0.0, _animationController.value, 1.0],
            ),
          ),
        );
      },
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
            'User order history will appear here\nafter user make his first purchase',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
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
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummaryCard() {
    final orderCount = orders.length;
    final totalSpent = orders.fold<double>(
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
          _buildShippingAddress(
            MailingAddress(
              id: order.shippingAddress?.id ?? '',
              address1: order.shippingAddress?.address1 ?? '',
              city: order.shippingAddress?.city ?? '',
              country: order.shippingAddress?.country ?? '',
            ),
          ),
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
