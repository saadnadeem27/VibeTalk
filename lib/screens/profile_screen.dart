import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final AuthController authController = Get.find<AuthController>();

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

              // Profile content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(VibeTalkSpacing.lg),
                  child: Column(
                    children: [
                      _buildProfileHeader(authService),
                      const SizedBox(height: VibeTalkSpacing.xl),
                      _buildProfileOptions(authController),
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
            'Profile',
            style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.3, end: 0);
  }

  Widget _buildProfileHeader(AuthService authService) {
    return Obx(() {
      final user = authService.currentUser.value;

      return Container(
        padding: const EdgeInsets.all(VibeTalkSpacing.xl),
        decoration: BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.circular(VibeTalkRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: VibeTalkColors.primaryColor,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: VibeTalkColors.onPrimary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: VibeTalkColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: VibeTalkColors.surface,
                        width: 3,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.snackbar('Info', 'Photo update coming soon!');
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: VibeTalkColors.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .scale()
                .shimmer(delay: const Duration(milliseconds: 500)),

            const SizedBox(height: VibeTalkSpacing.lg),

            // User Name
            Text(
              user?.displayName ?? 'Unknown User',
              style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

            const SizedBox(height: VibeTalkSpacing.sm),

            // User Email
            Text(
              user?.email ?? 'No email',
              style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                    color: VibeTalkColors.textSecondary,
                  ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 500)),

            const SizedBox(height: VibeTalkSpacing.sm),

            // User ID
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VibeTalkSpacing.md,
                vertical: VibeTalkSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: VibeTalkColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(VibeTalkRadius.md),
              ),
              child: Text(
                'ID: ${user?.id.substring(0, 8) ?? 'N/A'}...',
                style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                      color: VibeTalkColors.primaryColor,
                      fontFamily: 'monospace',
                    ),
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
          ],
        ),
      );
    });
  }

  Widget _buildProfileOptions(AuthController authController) {
    final options = [
      {
        'icon': Icons.edit,
        'title': 'Edit Profile',
        'subtitle': 'Update your name and photo',
        'onTap': () => Get.snackbar('Info', 'Profile editing coming soon!'),
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Manage notification preferences',
        'onTap': () =>
            Get.snackbar('Info', 'Notification settings coming soon!'),
      },
      {
        'icon': Icons.privacy_tip,
        'title': 'Privacy',
        'subtitle': 'Control your privacy settings',
        'onTap': () => Get.snackbar('Info', 'Privacy settings coming soon!'),
      },
      {
        'icon': Icons.help,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'onTap': () => Get.snackbar('Info', 'Help section coming soon!'),
      },
      {
        'icon': Icons.info,
        'title': 'About',
        'subtitle': 'App version and information',
        'onTap': () => _showAboutDialog(),
      },
      {
        'icon': Icons.logout,
        'title': 'Sign Out',
        'subtitle': 'Sign out of your account',
        'onTap': () => _showSignOutDialog(authController),
        'isDestructive': true,
      },
    ];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: VibeTalkSpacing.sm),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(VibeTalkSpacing.md),
            leading: Container(
              padding: const EdgeInsets.all(VibeTalkSpacing.sm),
              decoration: BoxDecoration(
                color: (option['isDestructive'] == true
                        ? VibeTalkColors.error
                        : VibeTalkColors.primaryColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(VibeTalkRadius.md),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: option['isDestructive'] == true
                    ? VibeTalkColors.error
                    : VibeTalkColors.primaryColor,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: Theme.of(Get.context!).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: option['isDestructive'] == true
                        ? VibeTalkColors.error
                        : null,
                  ),
            ),
            subtitle: Text(
              option['subtitle'] as String,
              style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                    color: VibeTalkColors.textHint,
                  ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: VibeTalkColors.textHint,
            ),
            onTap: option['onTap'] as VoidCallback,
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + (index * 100)))
            .slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: VibeTalkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        ),
        title: const Text('About VibeTalk'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: VibeTalkSpacing.sm),
            Text('A modern chat application built with Flutter and Firebase.'),
            SizedBox(height: VibeTalkSpacing.sm),
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

  void _showSignOutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: VibeTalkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: VibeTalkColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
