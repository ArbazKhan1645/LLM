import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:llm_video_shopify/app/routes/app_pages.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return EnhancedDashboardScreen();
  }
}

// Enhanced Dashboard Screen with Firebase Integration
class EnhancedDashboardScreen extends StatelessWidget {
  final AdminDashboardController controller = Get.put(
    AdminDashboardController(),
  );

  EnhancedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: CustomDrawer(),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                : RefreshIndicator(
                  onRefresh: controller.refreshDashboard,
                  color: Colors.blue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 20),
                        _buildTimeFrameSelector(),
                        const SizedBox(height: 20),
                        _buildQuickStatsGrid(),
                        const SizedBox(height: 20),
                        _buildUserAnalyticsSection(),
                        const SizedBox(height: 20),
                        _buildVideoAnalyticsSection(),
                        const SizedBox(height: 20),
                        _buildChatAnalyticsSection(),
                        const SizedBox(height: 20),
                        _buildUserDistributionCharts(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refreshDashboard,
        backgroundColor: Colors.blue,
        child: Obx(
          () =>
              controller.isRefreshing.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[600],
      elevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: const Text(
        'ADMIN DASHBOARD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                DateTime.now().toString().substring(0, 16),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'WELCOME ADMIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time dashboard with live Firebase data',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTimeFrameButton('Day', 'day'),
            _buildTimeFrameButton('Week', 'week'),
            _buildTimeFrameButton('Month', 'month'),
            _buildTimeFrameButton('Year', 'year'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameButton(String label, String value) {
    final isSelected = controller.selectedTimeFrame.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateTimeFrame(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return Obx(
      () =>
          controller.userStats.value == null
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    icon: Icons.people,
                    title: 'TOTAL USERS',
                    value: controller.userStats.value!.totalUsers.toString(),
                    subtitle: 'All registered users',
                    color: Colors.blue,
                    growth: controller.userStats.value!.growthPercentage,
                  ),
                  _buildStatCard(
                    icon: Icons.person_add,
                    title: 'NEW USERS TODAY',
                    value: controller.userStats.value!.newUsersToday.toString(),
                    subtitle: 'Joined today',
                    color: Colors.green,
                    growth: controller.userStats.value!.weeklyGrowthPercentage,
                  ),
                  _buildStatCard(
                    icon: Icons.video_library,
                    title: 'TOTAL VIDEOS',
                    value:
                        controller.videoStats.value?.totalVideos.toString() ??
                        '0',
                    subtitle: 'Videos uploaded',
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    icon: Icons.chat,
                    title: 'ACTIVE CHATS',
                    value:
                        controller.chatStats.value?.activeChatRoomsToday
                            .toString() ??
                        '0',
                    subtitle: 'Chat rooms today',
                    color: Colors.orange,
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    double? growth,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        growth >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: growth >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'USER GROWTH ANALYTICS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
            ],
          ),
          Obx(
            () => Text(
              controller.userStats.value != null
                  ? '${controller.userStats.value!.growthPercentage >= 0 ? '+' : ''}${controller.userStats.value!.growthPercentage.toStringAsFixed(1)}%'
                  : '0%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    controller.userStats.value?.growthPercentage != null &&
                            controller.userStats.value!.growthPercentage >= 0
                        ? Colors.green
                        : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly growth compared to previous month',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Obx(
              () =>
                  controller.userStats.value != null
                      ? LineChart(_buildUserGrowthChart())
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 16),
          _buildUserStatsRow(),
        ],
      ),
    );
  }

  Widget _buildUserStatsRow() {
    return Obx(
      () =>
          controller.userStats.value != null
              ? Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      'Active Today',
                      controller.userStats.value!.activeUsersToday.toString(),
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildMiniStat(
                      'This Week',
                      controller.userStats.value!.newUsersThisWeek.toString(),
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildMiniStat(
                      'Business',
                      controller.userStats.value!.businessUsers.toString(),
                      Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildMiniStat(
                      'Verified',
                      controller.userStats.value!.verifiedUsers.toString(),
                      Colors.orange,
                    ),
                  ),
                ],
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVideoAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIDEO ANALYTICS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () =>
                controller.videoStats.value != null
                    ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildVideoStat(
                                'Total Videos',
                                controller.videoStats.value!.totalVideos
                                    .toString(),
                                Icons.video_library,
                                Colors.purple,
                              ),
                            ),
                            Expanded(
                              child: _buildVideoStat(
                                'Today',
                                controller.videoStats.value!.videosToday
                                    .toString(),
                                Icons.today,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVideoStat(
                                'This Week',
                                controller.videoStats.value!.videosThisWeek
                                    .toString(),
                                Icons.calendar_view_week,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildVideoStat(
                                'Storage',
                                '${controller.videoStats.value!.totalStorageUsed.toStringAsFixed(1)} GB',
                                Icons.storage,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHAT ANALYTICS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () =>
                controller.chatStats.value != null
                    ? Row(
                      children: [
                        Expanded(
                          child: _buildChatStat(
                            'Total Chats',
                            controller.chatStats.value!.totalChatRooms
                                .toString(),
                            Icons.chat_bubble_outline,
                          ),
                        ),
                        Expanded(
                          child: _buildChatStat(
                            'Active Today',
                            controller.chatStats.value!.activeChatRoomsToday
                                .toString(),
                            Icons.chat,
                          ),
                        ),
                        Expanded(
                          child: _buildChatStat(
                            'Messages',
                            controller.chatStats.value!.totalMessages
                                .toString(),
                            Icons.message,
                          ),
                        ),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildChatStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserDistributionCharts() {
    return Obx(
      () =>
          controller.userStats.value != null
              ? Row(
                children: [
                  Expanded(
                    child: _buildPieChart('User Types', [
                      PieChartSectionData(
                        value:
                            controller.userStats.value!.businessUsers
                                .toDouble(),
                        title: 'Business',
                        color: Colors.blue,
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value:
                            controller.userStats.value!.personalUsers
                                .toDouble(),
                        title: 'Personal',
                        color: Colors.green,
                        radius: 50,
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPieChart('Verification Status', [
                      PieChartSectionData(
                        value:
                            controller.userStats.value!.verifiedUsers
                                .toDouble(),
                        title: 'Verified',
                        color: Colors.green,
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value:
                            controller.userStats.value!.unverifiedUsers
                                .toDouble(),
                        title: 'Unverified',
                        color: Colors.red,
                        radius: 50,
                      ),
                    ]),
                  ),
                ],
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildPieChart(String title, List<PieChartSectionData> sections) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildUserGrowthChart() {
    final userData = controller.getUserGrowthData();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 7,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < userData.length) {
                final date = userData[value.toInt()].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots:
              userData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.userCount.toDouble(),
                );
              }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}

// Custom Drawer
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.blue[400],
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[400],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerMenuItem(
                    icon: Icons.dashboard,
                    title: 'DASHBOARD',
                    isSelected: true,
                  ),
                  DrawerMenuItem(icon: Icons.people, title: 'USER MANAGEMENT'),
                  DrawerMenuItem(
                    icon: Icons.content_paste,
                    title: 'CONTENT MODERATION',
                  ),
                  // DrawerMenuItem(
                  //   icon: Icons.security,
                  //   title: 'ALERT AND SECURITY',
                  // ),
                  DrawerMenuItem(icon: Icons.person, title: 'PROFILE'),
                  // DrawerMenuItem(icon: Icons.settings, title: 'SETTINGS'),
                ],
              ),
            ),

            // Logout Button
            Container(
              margin: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  _showConfirmationDialog(
                    'Logout',
                    'Are you sure you want to logout? You will need to sign in again.',
                    () async {
                      try {
                        await auth.signOut();
                        Get.offAllNamed(Routes.AUTHENTCATION);
                      } catch (e) {}
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

// Drawer Menu Item
class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700], size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        onTap: () {
          // Handle menu item tap

          Navigator.pop(context);
          switch (title) {
            case 'DASHBOARD':
              // Navigate to dashboard screen
              break;
            case 'USER MANAGEMENT':
              Get.toNamed(Routes.USERS_MANAGMENT);
              break;
            case 'CONTENT MODERATION':
              Get.toNamed(Routes.REPORTED_LIST);
              break;
            case 'ALERT AND SECURITY':
              Get.toNamed(Routes.SECURITY);
              break;
            case 'PROFILE':
              Get.toNamed(Routes.PROFILE);
              break;
            case 'SETTINGS':
              Get.toNamed(Routes.SETTINGS);
              break;
          }
        },
      ),
    );
  }
}

// Stat Card Widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.percentage,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPositive ? Colors.red[600] : Colors.green[600],
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
}
