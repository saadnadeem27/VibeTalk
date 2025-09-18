import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/controllers/chat_controller.dart';
import 'package:flash_chat/app/controllers/group_controller.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/services/group_service.dart';
import 'package:flash_chat/app/models/chat_model.dart';
import 'package:flash_chat/app/models/group_model.dart';
import 'package:flash_chat/screens/create_group_screen.dart';
import 'package:flash_chat/screens/profile_screen.dart';
import 'package:flash_chat/screens/settings_screen.dart';
import 'package:flash_chat/screens/group_chat_screen.dart';
import 'package:flash_chat/screens/individual_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final GroupController groupController = Get.put(GroupController());
    final AuthService authService = Get.find<AuthService>();

    // Load user data when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authService.getCurrentUser();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildModernAppBar(authService),

          // Search Bar
          SliverToBoxAdapter(
            child: _buildModernSearchBar(),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: _buildModernTabBar(),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(chatController),
                _buildGroupsTab(groupController),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(chatController),
    );
  }

  // Modern App Bar with glassmorphism effect
  Widget _buildModernAppBar(AuthService authService) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1D29).withOpacity(0.9),
              const Color(0xFF0B0E11).withOpacity(0.7),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Obx(() => Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF6C5CE7),
                    backgroundImage: authService.currentUser.value?.photoURL !=
                            null
                        ? NetworkImage(authService.currentUser.value!.photoURL!)
                        : null,
                    child: authService.currentUser.value?.photoURL == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          authService.currentUser.value?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            onPressed: _showModernOptionsMenu,
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Modern Search Bar
  Widget _buildModernSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.7),
                  ),
                )
              : null,
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.3, end: 0);
  }

  // Modern Tab Bar
  Widget _buildModernTabBar() {
    // Glassmorphism pill container
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.03), // subtle translucent base
            //   borderRadius: BorderRadius.circular(28),
            //   border: Border.all(color: Colors.white.withOpacity(0.03)),
            // ),
            child: Material(
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                // ensure the indicator is comfortably inset
                indicatorPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                indicatorSize: TabBarIndicatorSize.tab,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Chats'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Groups'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  // Modern FAB
  Widget _buildModernFAB(ChatController chatController) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showModernNewChatOptions(chatController),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_comment,
          color: Colors.white,
          size: 28,
        ),
      ),
    )
        .animate()
        .scale(delay: const Duration(milliseconds: 800))
        .shimmer(delay: const Duration(milliseconds: 2000));
  }

  // Updated chat and group tabs with modern design
  Widget _buildChatsTab(ChatController chatController) {
    return Obx(() {
      if (chatController.chats.isEmpty) {
        return _buildModernEmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'No conversations yet',
          subtitle: 'Start a new conversation to begin chatting',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chatController.chats.length,
        itemBuilder: (context, index) {
          final chat = chatController.chats[index];
          return _buildModernChatItem(chat, chatController, index);
        },
      );
    });
  }

  Widget _buildGroupsTab(GroupController groupController) {
    final groupService = Get.find<GroupService>();
    return Obx(() {
      final groups = groupService.userGroups;

      if (groups.isEmpty) {
        return _buildModernEmptyState(
          icon: Icons.group_outlined,
          title: 'No groups yet',
          subtitle: 'Create a new group to start chatting with multiple people',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildModernGroupItem(group, index);
        },
      );
    });
  }

  // Modern empty state
  Widget _buildModernEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D29),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  // Modern chat item
  Widget _buildModernChatItem(
      ChatModel chat, ChatController chatController, int index) {
    final unreadCount = chatController.getUnreadCount(chat);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                ),
                shape: BoxShape.circle,
                image: chat.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(chat.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: chat.photoURL == null
                  ? Icon(
                      chat.type == ChatType.group ? Icons.group : Icons.person,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
            if (chat.type == ChatType.individual)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF1A1D29), width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chatController.getChatDisplayName(chat),
          style: TextStyle(
            fontSize: 16,
            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.lastMessage ?? 'No messages yet',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatController.formatLastMessageTime(chat.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0
                    ? const Color(0xFF6C5CE7)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () => _navigateToChat(chat),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 + (index * 50)))
        .slideX(begin: 0.3, end: 0);
  }

  // Modern group item
  Widget _buildModernGroupItem(GroupModel group, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE17055), Color(0xFFFDCB6E)],
            ),
            shape: BoxShape.circle,
            image: group.groupPhoto != null
                ? DecorationImage(
                    image: NetworkImage(group.groupPhoto!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: group.groupPhoto == null
              ? const Icon(Icons.group, color: Colors.white, size: 24)
              : null,
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.lastMessage ?? 'No messages yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          group.lastMessageTime != null
              ? _formatTime(group.lastMessageTime!)
              : _formatTime(group.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        onTap: () => _navigateToGroupChat(group),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 + (index * 50)))
        .slideX(begin: 0.3, end: 0);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Navigation methods
  void _navigateToChat(ChatModel chat) {
    Get.to(() => IndividualChatScreen(chat: chat));
  }

  void _navigateToGroupChat(GroupModel group) {
    Get.to(() => GroupChatScreen(group: group));
  }

  // Modern options menu
  void _showModernOptionsMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D29),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildModernMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Get.back();
                Get.to(() => const ProfileScreen());
              },
            ),
            _buildModernMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Get.back();
                Get.to(() => const SettingsScreen());
              },
            ),
            _buildModernMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Create Demo Chat',
              onTap: () {
                Get.back();
                _createDemoChat();
              },
            ),
            _buildModernMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
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

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : const Color(0xFF6C5CE7))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF6C5CE7),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Modern new chat options
  void _showModernNewChatOptions(ChatController chatController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D29),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start New Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildModernMenuItem(
              icon: Icons.person_add_outlined,
              title: 'New Chat',
              onTap: () {
                Get.back();
                _createDemoChat();
              },
            ),
            _buildModernMenuItem(
              icon: Icons.group_add_outlined,
              title: 'Create Group',
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

  void _createDemoChat() async {
    final chatController = Get.find<ChatController>();

    try {
      await chatController.createDemoChat();
      Get.snackbar(
        'Success',
        'Demo chat created!',
        backgroundColor: const Color(0xFF6C5CE7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create demo chat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
