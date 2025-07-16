import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/users_managment/views/order_history.dart';
import '../controllers/users_managment_controller.dart';

class UserProfileScreen extends StatelessWidget {
  final UserManagementModel user;
  final UsersManagmentController controller =
      Get.find<UsersManagmentController>();

  UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildUserInfoCards(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildActivityLogs(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[600],
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        user.fullName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('Export Data'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child:
                      user.profileImageUrl != null
                          ? CachedNetworkImage(
                            imageUrl: user.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.white,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.blue.shade100,
                                  child: Center(
                                    child: Text(
                                      user.initials,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.blue.shade100,
                            child: Center(
                              child: Text(
                                user.initials,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                ),
              ),

              const SizedBox(width: 20),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.statusDisplayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.userType == UserType.business
                                ? 'BUSINESS'
                                : 'PERSONAL',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Videos',
                  user.videoCount.toString(),
                  Icons.video_library,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Chats',
                  user.chatCount.toString(),
                  Icons.chat,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Storage',
                  '${user.totalStorageUsed.toStringAsFixed(1)} MB',
                  Icons.storage,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Joined',
                  _formatDate(user.createdAt),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          
          GestureDetector(
            onTap: () {
              Get.to(
                () => UsersOrdersHistoryPage(
                  accessToken: user.shopifyAccessToken ?? '',
                ),
              );
            },
            child: _buildInfoCard('User Orders', Icons.history, [
              Text('click here to view the order history of the user'),
            ]),
          ),
          const SizedBox(height: 16),

          // Personal Information Card
          _buildInfoCard('Personal Information', Icons.person, [
            _buildInfoRow('Full Name', user.fullName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
            _buildInfoRow(
              'Email Verified',
              user.isEmailVerified ? 'Yes' : 'No',
            ),
            _buildInfoRow(
              'Professional Status',
              user.professionalStatus ?? 'Not specified',
            ),
            _buildInfoRow('Industry', user.industry ?? 'Not specified'),
          ]),

          // Business Information Card (if business user)
          if (user.userType == UserType.business) ...[
            const SizedBox(height: 16),
            _buildInfoCard('Business Information', Icons.business, [
              _buildInfoRow(
                'Business Name',
                user.businessName ?? 'Not provided',
              ),
              _buildInfoRow(
                'Business Link',
                user.businessLink ?? 'Not provided',
              ),
              _buildInfoRow(
                'Business Address',
                user.businessAddress ?? 'Not provided',
              ),
            ]),
          ],

          const SizedBox(height: 16),

          // Account Status Card
          _buildInfoCard('Account Status', Icons.security, [
            _buildInfoRow('Status', user.statusDisplayName),
            _buildInfoRow(
              'Online Status',
              user.isOnline ? 'Online' : 'Offline',
            ),
            _buildInfoRow(
              'Last Seen',
              user.lastSeen != null ? _formatDateTime(user.lastSeen!) : 'Never',
            ),
            _buildInfoRow('Registered', _formatDateTime(user.createdAt)),
            _buildInfoRow('Last Updated', _formatDateTime(user.updatedAt)),
            if (user.isBanned) ...[
              _buildInfoRow(
                'Banned Date',
                user.bannedDate != null
                    ? _formatDateTime(user.bannedDate!)
                    : 'Unknown',
              ),
              _buildInfoRow(
                'Ban Reason',
                user.banReason ?? 'No reason provided',
              ),
              _buildInfoRow(
                'Banned By',
                user.bannedBy.isNotEmpty ? user.bannedBy.join(', ') : 'System',
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Admin Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (user.isBanned)
              // Unban Button
              Obx(
                () => _buildActionButton(
                  'Unban User',
                  'Restore user access',
                  Icons.check_circle,
                  Colors.green,
                  controller.isLoadingProfile.value
                      ? null
                      : () => controller.unbanUser(user.uid),
                ),
              )
            else if (user.isSuspended)
              // Reactivate Button
              Obx(
                () => _buildActionButton(
                  'Reactivate User',
                  'Restore user access',
                  Icons.play_circle,
                  Colors.green,
                  controller.isLoadingProfile.value
                      ? null
                      : () => controller.reactivateUser(user.uid),
                ),
              )
            else ...[
              // Ban Button
              Obx(
                () => _buildActionButton(
                  'Ban User',
                  'Permanently ban this user',
                  Icons.block,
                  Colors.red,
                  controller.isLoadingProfile.value
                      ? null
                      : () => controller.showBanDialog(user),
                ),
              ),

              const SizedBox(height: 12),

              // Suspend Button
              Obx(
                () => _buildActionButton(
                  'Suspend User',
                  'Temporarily suspend this user',
                  Icons.pause_circle,
                  Colors.orange,
                  controller.isLoadingProfile.value
                      ? null
                      : () => controller.showSuspendDialog(user),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Reset Password Button
            _buildActionButton(
              'Reset Password',
              'Send password reset email',
              Icons.lock_reset,
              Colors.blue,
              () => _showResetPasswordDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (onPressed == null)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLogs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (user.activityLogs.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...user.activityLogs
                  .take(10)
                  .map((log) => ActivityLogItem(log: log)),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        controller.refreshUsers();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'delete':
        _showDeleteAccountDialog();
        break;
    }
  }

  void _showResetPasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send a password reset email to ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement password reset
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export User Data'),
        content: const Text(
          'Export all user data including profile information, videos, and activity logs?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will permanently delete:'),
            const SizedBox(height: 8),
            const Text('• User profile and data'),
            const Text('• All uploaded videos'),
            const Text('• Chat history'),
            const Text('• Activity logs'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user.uid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Activity Log Item Widget
class ActivityLogItem extends StatelessWidget {
  final ActivityLogModel log;

  const ActivityLogItem({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(log.icon, size: 16, color: _getIconColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (log.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    log.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  log.timeAgo,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    switch (log.type) {
      case ActivityType.login:
        return Colors.green;
      case ActivityType.videoUpload:
        return Colors.blue;
      case ActivityType.profileUpdate:
        return Colors.orange;
      case ActivityType.chatMessage:
        return Colors.purple;
      case ActivityType.banned:
        return Colors.red;
      case ActivityType.unbanned:
        return Colors.green;
      case ActivityType.suspended:
        return Colors.orange;
      case ActivityType.general:
        return Colors.grey;
    }
  }
}
