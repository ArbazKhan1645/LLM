import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room_history.dart';
import 'package:llm_video_shopify/app/modules/shopify_store/widgets/cart_screen.dart';
import 'package:llm_video_shopify/app/modules/video_script/widget/users_video_screen.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}

// Enhanced Profile Screen with Firebase Integration
class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                : controller.isEditing.value
                ? _buildEditMode()
                : _buildViewMode(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'MY PROFILE',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(
          () =>
              controller.isEditing.value
                  ? IconButton(
                    onPressed: () => controller.isEditing.value = false,
                    icon: const Icon(Icons.close, color: Colors.black87),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildUserInfoCards(),
          const SizedBox(height: 24),
          _buildMenuItems(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEditableProfileHeader(),
          const SizedBox(height: 24),
          _buildEditableFields(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade500],
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
      child: Row(
        children: [
          // Profile Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Obx(
                    () =>
                        controller.userAvatar.value.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: controller.userAvatar.value,
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
                                        controller.userName.value.isNotEmpty
                                            ? controller.userName.value[0]
                                                .toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 32,
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
                                  controller.userName.value.isNotEmpty
                                      ? controller.userName.value[0]
                                          .toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.userType.value == UserType.business
                          ? 'Business Account'
                          : 'Personal Account',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'EDIT PROFILE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileHeader() {
    return Column(
      children: [
        // Profile Avatar with upload option
        GestureDetector(
          onTap: controller.changeProfilePicture,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade300, width: 3),
                ),
                child: ClipOval(
                  child: Obx(
                    () =>
                        controller.isUploadingImage.value
                            ? Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              ),
                            )
                            : controller.userAvatar.value.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: controller.userAvatar.value,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.blue.shade100,
                                    child: Center(
                                      child: Text(
                                        controller.userName.value.isNotEmpty
                                            ? controller.userName.value[0]
                                                .toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 36,
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
                                  controller.userName.value.isNotEmpty
                                      ? controller.userName.value[0]
                                          .toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCards() {
    return Column(
      children: [
        // Basic Info Card
        _buildInfoCard(
          title: 'Personal Information',
          children: [
            _buildInfoRow('Full Name', controller.userName.value),
            _buildInfoRow('Email', controller.userEmail.value),
            _buildInfoRow(
              'Phone',
              controller.userPhone.value.isNotEmpty
                  ? controller.userPhone.value
                  : 'Not provided',
            ),
            if (controller.professionalStatus.value.isNotEmpty)
              _buildInfoRow(
                'Professional Status',
                controller.professionalStatus.value,
              ),
            if (controller.industry.value.isNotEmpty)
              _buildInfoRow('Industry', controller.industry.value),
          ],
        ),

        // Business Info Card (if business user)
        Obx(
          () =>
              controller.userType.value == UserType.business
                  ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Business Information',
                        children: [
                          _buildInfoRow(
                            'Business Name',
                            controller.businessName.value,
                          ),
                          _buildInfoRow(
                            'Business Link',
                            controller.businessLink.value,
                          ),
                          _buildInfoRow(
                            'Business Address',
                            controller.businessAddress.value,
                          ),
                        ],
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(
                fontSize: 14,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'CHANGE PASSWORD',
          subtitle: 'Update your account password',
          onTap: controller.showChangePasswordDialog,
        ),
        _buildMenuItem(
          icon: Icons.email_outlined,
          title: 'RESET PASSWORD',
          subtitle: 'Send password reset email',
          onTap: controller.sendPasswordResetEmail,
        ),
        _buildMenuItem(
          icon: Icons.video_library_outlined,
          title: 'MY VIDEOS',
          subtitle: 'View your recorded videos',
          onTap: () => Get.to(() => UserVideosScreen()),
        ),
        _buildMenuItem(
          icon: Icons.chat_outlined,
          title: 'MY CHATS',
          subtitle: 'View chat conversations',
          onTap: () => Get.to(() => ChatRoomHistoryScreen()),
        ),
        _buildMenuItem(
          icon: Icons.shopping_cart,
          title: 'My Cart',
          subtitle: 'My Cart',
          onTap: () {
            Get.to(() => CartPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: 'My Orders',
          subtitle: 'My orders Track',
          onTap: controller.orderRouteScreen,
        ),
        // _buildMenuItem(
        //   icon: Icons.settings_outlined,
        //   title: 'SETTINGS',
        //   subtitle: 'App preferences and settings',
        //   onTap: controller.openSettings,
        // ),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'LOGOUT',
          subtitle: 'Sign out of your account',
          onTap: controller.logout,
          isDestructive: false,
        ),
        _buildMenuItem(
          icon: Icons.delete_forever_outlined,
          title: 'DELETE ACCOUNT',
          subtitle: 'Permanently delete your account',
          onTap: controller.deleteAccount,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDestructive ? Colors.red.shade200 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        isDestructive
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isDestructive
                            ? Colors.red.shade600
                            : Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDestructive
                                  ? Colors.red.shade700
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDestructive
                                  ? Colors.red.shade500
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        // Personal Information Section
        _buildSectionTitle('Personal Information'),
        _buildEditField(
          'Full Name',
          controller.nameController,
          Icons.person_outline,
        ),
        _buildEditField(
          'Email Address',
          controller.emailController,
          Icons.email_outlined,
        ),
        _buildEditField(
          'Phone Number',
          controller.phoneController,
          Icons.phone_outlined,
        ),

        // Professional Status Dropdown
        _buildDropdownField(
          'Professional Status',
          controller.selectedProfessionalStatus.value,
          controller.professionalStatuses,
          (value) => controller.selectedProfessionalStatus.value = value ?? '',
          Icons.work_outline,
        ),

        // Industry Dropdown
        _buildDropdownField(
          'Industry',
          controller.selectedIndustry.value,
          controller.industries,
          (value) => controller.selectedIndustry.value = value ?? '',
          Icons.business_outlined,
        ),

        // Business Information Section (if business user)
        Obx(
          () =>
              controller.userType.value == UserType.business
                  ? Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle('Business Information'),
                      _buildEditField(
                        'Business Name',
                        controller.businessNameController,
                        Icons.store_outlined,
                      ),
                      _buildEditField(
                        'Business Website',
                        controller.businessLinkController,
                        Icons.web_outlined,
                      ),
                      _buildEditField(
                        'Business Address',
                        controller.businessAddressController,
                        Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),

        const SizedBox(height: 32),

        // Save Button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.toggleEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController textController,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: textController,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value.isNotEmpty ? value : null,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
