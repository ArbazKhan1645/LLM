import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return Column(
            children: [
              // Top blue header
              Container(
                height: 140,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const Spacer(),
                        FadeTransition(
                          opacity: controller.fadeAnimation,
                          child: const Text(
                            'SETTINGS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the menu icon
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: SlideTransition(
                      position: controller.slideAnimation,
                      child: Column(
                        children: [
                          // General Settings
                          _buildSettingsSection(
                            title: 'GENERAL SETTINGS',
                            children: [
                              _buildSettingsRow(
                                icon: Icons.language,
                                title: 'LANGUAGE',
                                trailing: _buildSelectButton(
                                  onPressed:
                                      () => _showLanguageSelector(controller),
                                ),
                              ),
                              _buildSettingsRow(
                                icon: Icons.access_time,
                                title: 'TIMEZONE',
                                trailing: _buildSelectButton(
                                  onPressed:
                                      () => _showTimezoneSelector(controller),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Role Management
                          _buildSettingsSection(
                            title: 'ROLE MANAGEMENT',
                            children: [
                              ...controller.roles.map(
                                (role) => _buildRoleRow(
                                  role: role,
                                  onEdit: () => controller.editRole(role),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildAddRoleButton(controller),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Access Control
                          _buildSettingsSection(
                            title: 'ACCESS CONTROL',
                            children: [
                              _buildToggleRow(
                                title: 'RESTRICT CONTENT ACCESS',
                                subtitle: 'RESTRICT ACCESS BASED ON USER ROLES',
                                value: controller.restrictContentAccess,
                                onChanged:
                                    (value) =>
                                        controller
                                            .toggleRestrictContentAccess(),
                              ),
                              _buildToggleRow(
                                title: 'FEATURED TOGGLE',
                                subtitle: 'ENABLE SPECIFIC FEATURES FOR ROLES',
                                value: controller.featuredToggle,
                                onChanged:
                                    (value) =>
                                        controller.toggleFeaturedToggle(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Notification Preferences
                          _buildSettingsSection(
                            title: 'NOTIFICATION PREFERENCES',
                            children: [
                              _buildToggleRow(
                                icon: Icons.admin_panel_settings,
                                title: 'ADMIN ALERTS',
                                value: controller.adminAlerts,
                                onChanged:
                                    (value) => controller.toggleAdminAlerts(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildRoleRow({required UserRole role, required VoidCallback onEdit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            role.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          _buildEditButton(onPressed: onEdit),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    IconData? icon,
    required String title,
    String? subtitle,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 15),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: value.value,
              onChanged: onChanged,
              activeColor: const Color(0xFF4FC3F7),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton({required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: const Text(
          'SELECT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton({required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: const Text(
          'EDIT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAddRoleButton(SettingsController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: controller.addNewRole,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          '+ADD ROLE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(SettingsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ...controller.languages.map(
              (language) => ListTile(
                title: Text(language),
                onTap: () {
                  controller.selectLanguage(language);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneSelector(SettingsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Timezone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ...controller.timezones.map(
              (timezone) => ListTile(
                title: Text(timezone),
                onTap: () {
                  controller.selectTimezone(timezone);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
