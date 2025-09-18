import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flash_chat/app/controllers/chat_controller.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/models/chat_model.dart';
import 'package:flash_chat/screens/create_group_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              _buildAppBar(authService),

              // Search bar
              _buildSearchBar(chatController),

              // Chat list
              Expanded(
                child: _buildChatList(chatController),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(chatController),
    );
  }

  Widget _buildAppBar(AuthService authService) {
    return Container(
      padding: const EdgeInsets.all(VibeTalkSpacing.lg),
      child: Row(
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: VibeTalkColors.primaryColor,
            child: Obx(
              () => authService.currentUser.value?.photoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        authService.currentUser.value!.photoURL!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: VibeTalkColors.onPrimary,
                      size: 28,
                    ),
            ),
          )
              .animate()
              .scale()
              .shimmer(delay: const Duration(milliseconds: 1000)),

          const SizedBox(width: VibeTalkSpacing.md),

          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                        color: VibeTalkColors.textSecondary,
                      ),
                ),
                Obx(() => Text(
                      authService.currentUser.value?.displayName ?? 'User',
                      style: Theme.of(Get.context!)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 300))
              .slideX(begin: -0.3, end: 0),

          // Menu button
          IconButton(
            onPressed: () {
              _showOptionsMenu();
            },
            icon: const Icon(
              Icons.more_vert,
              color: VibeTalkColors.textPrimary,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ChatController chatController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: VibeTalkSpacing.lg),
      child: TextField(
        controller: chatController.searchController,
        onChanged: chatController.searchUsers,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(
            Icons.search,
            color: VibeTalkColors.primaryColor,
          ),
          suffixIcon: Obx(() => chatController.isSearching.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VibeTalkColors.primaryColor,
                  ),
                )
              : const SizedBox.shrink()),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 600))
        .slideY(begin: -0.3, end: 0);
  }

  Widget _buildChatList(ChatController chatController) {
    return Obx(() {
      if (chatController.chats.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        itemCount: chatController.chats.length,
        padding: const EdgeInsets.symmetric(horizontal: VibeTalkSpacing.sm),
        itemBuilder: (context, index) {
          final chat = chatController.chats[index];
          return _buildChatItem(chat, chatController, index);
        },
      );
    });
  }

  Widget _buildChatItem(
      ChatModel chat, ChatController chatController, int index) {
    final unreadCount = chatController.getUnreadCount(chat);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: VibeTalkSpacing.sm,
        vertical: VibeTalkSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(VibeTalkSpacing.md),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: VibeTalkColors.primaryColor,
              backgroundImage:
                  chat.photoURL != null ? NetworkImage(chat.photoURL!) : null,
              child: chat.photoURL == null
                  ? Icon(
                      chat.type == ChatType.group ? Icons.group : Icons.person,
                      color: VibeTalkColors.onPrimary,
                      size: 28,
                    )
                  : null,
            ),
            // Online indicator for individual chats
            if (chat.type == ChatType.individual)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: VibeTalkColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VibeTalkColors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chatController.getChatDisplayName(chat),
                style: Theme.of(Get.context!).textTheme.headlineSmall!.copyWith(
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              chatController.formatLastMessageTime(chat.lastMessageTime),
              style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                    color: unreadCount > 0
                        ? VibeTalkColors.primaryColor
                        : VibeTalkColors.textHint,
                    fontWeight:
                        unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage ?? 'No messages yet',
                style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                      color: unreadCount > 0
                          ? VibeTalkColors.textPrimary
                          : VibeTalkColors.textSecondary,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              badges.Badge(
                badgeContent: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: VibeTalkColors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: VibeTalkColors.primaryColor,
                  padding: EdgeInsets.all(6),
                ),
              ),
          ],
        ),
        onTap: () {
          chatController.openChat(chat.id);
          Get.toNamed('/chat', arguments: {'chatId': chat.id});
        },
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.chat_bubble_outline,
          size: 80,
          color: VibeTalkColors.textHint,
        ).animate().scale().shimmer(),
        const SizedBox(height: VibeTalkSpacing.lg),
        Text(
          'No conversations yet',
          style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
                color: VibeTalkColors.textSecondary,
              ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        const SizedBox(height: VibeTalkSpacing.sm),
        Text(
          'Start a new conversation by tapping the + button',
          style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                color: VibeTalkColors.textHint,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
      ],
    );
  }

  Widget _buildFloatingActionButton(ChatController chatController) {
    return FloatingActionButton(
      onPressed: () {
        _showNewChatOptions(chatController);
      },
      child: const Icon(Icons.add),
    )
        .animate()
        .scale(delay: const Duration(milliseconds: 800))
        .shimmer(delay: const Duration(milliseconds: 2000));
  }

  void _showNewChatOptions(ChatController chatController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(VibeTalkSpacing.lg),
        decoration: const BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibeTalkRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add,
                  color: VibeTalkColors.primaryColor),
              title: const Text('New Chat'),
              onTap: () {
                Get.back();
                // TODO: Navigate to user search/selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add,
                  color: VibeTalkColors.primaryColor),
              title: const Text('New Group'),
              onTap: () {
                Get.back();
                Get.to(() => const CreateGroupScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(VibeTalkSpacing.lg),
        decoration: const BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibeTalkRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings,
                  color: VibeTalkColors.primaryColor),
              title: const Text('Settings'),
              onTap: () {
                Get.back();
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.person, color: VibeTalkColors.primaryColor),
              title: const Text('Profile'),
              onTap: () {
                Get.back();
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: VibeTalkColors.error),
              title: const Text('Logout'),
              onTap: () {
                Get.back();
                Get.find<AuthController>().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
