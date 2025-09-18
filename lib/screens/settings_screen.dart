import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              _buildAppBar(),

              // Settings content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(VibeTalkSpacing.lg),
                  child: Column(
                    children: [
                      _buildAccountSection(),
                      const SizedBox(height: VibeTalkSpacing.lg),
                      _buildChatSection(),
                      const SizedBox(height: VibeTalkSpacing.lg),
                      _buildNotificationSection(),
                      const SizedBox(height: VibeTalkSpacing.lg),
                      _buildPrivacySection(),
                      const SizedBox(height: VibeTalkSpacing.lg),
                      _buildStorageSection(),
                      const SizedBox(height: VibeTalkSpacing.lg),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(VibeTalkSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: VibeTalkColors.textPrimary,
            ),
          ),
          const SizedBox(width: VibeTalkSpacing.sm),
          Text(
            'Settings',
            style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.3, end: 0);
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(VibeTalkSpacing.lg),
            child: Text(
              title,
              style: Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: VibeTalkColors.primaryColor,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: VibeTalkSpacing.lg,
        vertical: VibeTalkSpacing.sm,
      ),
      leading: Container(
        padding: const EdgeInsets.all(VibeTalkSpacing.sm),
        decoration: BoxDecoration(
          color: (iconColor ?? VibeTalkColors.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(VibeTalkRadius.md),
        ),
        child: Icon(
          icon,
          color: iconColor ?? VibeTalkColors.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(Get.context!).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
              color: VibeTalkColors.textHint,
            ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VibeTalkColors.textHint,
          ),
      onTap:
          onTap ?? () => Get.snackbar('Info', 'This feature is coming soon!'),
    );
  }

  Widget _buildAccountSection() {
    return _buildSectionCard(
      title: 'Account',
      children: [
        _buildSettingItem(
          icon: Icons.person,
          title: 'Edit Profile',
          subtitle: 'Change your name, photo, and status',
          onTap: () => Get.snackbar('Info', 'Profile editing coming soon!'),
        ),
        _buildSettingItem(
          icon: Icons.phone,
          title: 'Phone Number',
          subtitle: 'Add or change your phone number',
        ),
        _buildSettingItem(
          icon: Icons.security,
          title: 'Two-Step Verification',
          subtitle: 'Add an extra layer of security',
        ),
        _buildSettingItem(
          icon: Icons.key,
          title: 'Change Password',
          subtitle: 'Update your account password',
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildChatSection() {
    return _buildSectionCard(
      title: 'Chats',
      children: [
        _buildSettingItem(
          icon: Icons.backup,
          title: 'Chat Backup',
          subtitle: 'Backup your chats to cloud storage',
        ),
        _buildSettingItem(
          icon: Icons.wallpaper,
          title: 'Wallpaper',
          subtitle: 'Change your chat wallpaper',
        ),
        _buildSettingItem(
          icon: Icons.font_download,
          title: 'Font Size',
          subtitle: 'Adjust text size for better readability',
        ),
        _buildSettingItem(
          icon: Icons.archive,
          title: 'Archived Chats',
          subtitle: 'View and manage archived conversations',
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildNotificationSection() {
    return _buildSectionCard(
      title: 'Notifications',
      children: [
        _buildSettingItem(
          icon: Icons.notifications,
          title: 'Message Notifications',
          subtitle: 'Control how you receive message alerts',
          trailing: Switch(
            value: true,
            onChanged: (value) {
              Get.snackbar('Info', 'Notification preferences updated!');
            },
            activeColor: VibeTalkColors.primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.group,
          title: 'Group Notifications',
          subtitle: 'Manage notifications for group chats',
          trailing: Switch(
            value: true,
            onChanged: (value) {
              Get.snackbar('Info', 'Group notification preferences updated!');
            },
            activeColor: VibeTalkColors.primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Enable vibration for notifications',
          trailing: Switch(
            value: false,
            onChanged: (value) {
              Get.snackbar('Info', 'Vibration settings updated!');
            },
            activeColor: VibeTalkColors.primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.do_not_disturb,
          title: 'Do Not Disturb',
          subtitle: 'Temporarily disable notifications',
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildPrivacySection() {
    return _buildSectionCard(
      title: 'Privacy',
      children: [
        _buildSettingItem(
          icon: Icons.visibility,
          title: 'Last Seen',
          subtitle: 'Control who can see when you were last online',
        ),
        _buildSettingItem(
          icon: Icons.done_all,
          title: 'Read Receipts',
          subtitle: 'Let others know when you\'ve read their messages',
          trailing: Switch(
            value: true,
            onChanged: (value) {
              Get.snackbar('Info', 'Read receipts setting updated!');
            },
            activeColor: VibeTalkColors.primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.block,
          title: 'Blocked Contacts',
          subtitle: 'Manage your blocked contacts list',
        ),
        _buildSettingItem(
          icon: Icons.fingerprint,
          title: 'App Lock',
          subtitle: 'Secure your app with biometric authentication',
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStorageSection() {
    return _buildSectionCard(
      title: 'Storage and Data',
      children: [
        _buildSettingItem(
          icon: Icons.storage,
          title: 'Storage Usage',
          subtitle: 'See how much storage your chats are using',
        ),
        _buildSettingItem(
          icon: Icons.download,
          title: 'Media Auto-Download',
          subtitle: 'Control when media files are downloaded',
        ),
        _buildSettingItem(
          icon: Icons.delete_forever,
          title: 'Clear Cache',
          subtitle: 'Free up space by clearing temporary files',
          onTap: () => _showClearCacheDialog(),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 800))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'About',
      children: [
        _buildSettingItem(
          icon: Icons.help,
          title: 'Help Center',
          subtitle: 'Get help and find answers to common questions',
        ),
        _buildSettingItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Learn how we protect your privacy',
        ),
        _buildSettingItem(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
        ),
        _buildSettingItem(
          icon: Icons.info,
          title: 'App Info',
          subtitle: 'Version, build info, and credits',
          onTap: () => _showAppInfoDialog(),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 1000))
        .slideY(begin: 0.3, end: 0);
  }

  void _showClearCacheDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: VibeTalkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        ),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and free up storage space. Your chats and media will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Cache cleared successfully!');
            },
            style: TextButton.styleFrom(
              foregroundColor: VibeTalkColors.primaryColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: VibeTalkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        ),
        title: const Text('VibeTalk'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: VibeTalkSpacing.sm),
            Text('Build: 100 (Release)'),
            SizedBox(height: VibeTalkSpacing.sm),
            Text('A modern chat application built with Flutter and Firebase.'),
            SizedBox(height: VibeTalkSpacing.md),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: VibeTalkSpacing.xs),
            Text('• Real-time messaging'),
            Text('• Group chats'),
            Text('• Media sharing'),
            Text('• End-to-end encryption'),
            Text('• Cross-platform support'),
            SizedBox(height: VibeTalkSpacing.md),
            Text('© 2024 VibeTalk. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
