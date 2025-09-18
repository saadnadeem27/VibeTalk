import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flash_chat/app/services/chat_service.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/models/chat_model.dart';
import 'package:flash_chat/app/models/message_model.dart';
import 'package:flash_chat/app/models/user_model.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.put(ChatService());
  final AuthService _authService = Get.find<AuthService>();

  // Observable lists
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<UserModel> searchResults = <UserModel>[].obs;

  // Current chat
  final Rx<ChatModel?> currentChat = Rx<ChatModel?>(null);
  final RxString currentChatId = ''.obs;

  // UI states
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isTyping = false.obs;
  final RxString typingUser = ''.obs;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadChats();

    // Listen to typing changes
    ever(isTyping, (bool typing) {
      if (currentChatId.value.isNotEmpty) {
        _chatService.updateTypingStatus(currentChatId.value, typing);
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Load user chats
  void loadChats() {
    _chatService.getUserChats().listen((chatList) {
      chats.value = chatList;
    });
  }

  // Open a specific chat
  void openChat(String chatId) {
    currentChatId.value = chatId;

    // Find the chat in the list
    final chat = chats.firstWhereOrNull((c) => c.id == chatId);
    currentChat.value = chat;

    // Load messages
    _chatService.getChatMessages(chatId).listen((messageList) {
      messages.value = messageList;
    });

    // Mark messages as read
    _chatService.markMessagesAsRead(chatId);

    // Listen to typing status
    if (chat != null) {
      _listenToTypingStatus(chat);
    }
  }

  // Send a text message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || currentChatId.value.isEmpty) {
      return;
    }

    final content = messageController.text.trim();
    messageController.clear();

    // Stop typing indicator
    isTyping.value = false;

    await _chatService.sendMessage(
      chatId: currentChatId.value,
      content: content,
      type: MessageType.text,
    );

    // Scroll to bottom
    _scrollToBottom();
  }

  // Start or get individual chat
  Future<void> startIndividualChat(String otherUserId) async {
    isLoading.value = true;

    try {
      final chatId = await _chatService.createOrGetIndividualChat(otherUserId);
      if (chatId.isNotEmpty) {
        Get.toNamed('/chat', arguments: {'chatId': chatId});
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start chat');
    } finally {
      isLoading.value = false;
    }
  }

  // Create group chat
  Future<void> createGroupChat({
    required String name,
    required List<String> participantIds,
    String? description,
  }) async {
    isLoading.value = true;

    try {
      final chatId = await _chatService.createGroupChat(
        name: name,
        participantIds: participantIds,
        description: description,
      );

      if (chatId.isNotEmpty) {
        Get.back(); // Close create group screen
        Get.toNamed('/chat', arguments: {'chatId': chatId});
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group');
    } finally {
      isLoading.value = false;
    }
  }

  // Search users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final results = await _chatService.searchUsers(query);
      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  // Handle typing
  void onTypingChanged(String text) {
    final wasTyping = isTyping.value;
    final nowTyping = text.isNotEmpty;

    if (wasTyping != nowTyping) {
      isTyping.value = nowTyping;
    }
  }

  // Listen to typing status of other users
  void _listenToTypingStatus(ChatModel chat) {
    // This would be implemented with real-time listeners
    // For now, we'll just reset typing status
    typingUser.value = '';
  }

  // Scroll to bottom of messages
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Get chat display name
  String getChatDisplayName(ChatModel chat) {
    if (chat.type == ChatType.group) {
      return chat.name;
    }

    // For individual chats, return the stored name
    return chat.name; // Simplified for now
  }

  // Get unread count for a chat
  int getUnreadCount(ChatModel chat) {
    final currentUserId = _authService.user.value?.uid;
    if (currentUserId == null) return 0;

    return chat.unreadCount[currentUserId] ?? 0;
  }

  // Format last message time
  String formatLastMessageTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  // Create a demo chat for testing
  Future<void> createDemoChat() async {
    try {
      final currentUser = _authService.user.value;
      if (currentUser == null) return;

      // Create a demo chat with a fake user ID
      final demoChatId =
          await _chatService.createOrGetIndividualChat('demo_user_12345');

      // Send a demo message
      await _chatService.sendMessage(
        chatId: demoChatId,
        content:
            'Hello! This is a demo chat to test VibeTalk functionality. 🎉',
        type: MessageType.text,
      );

      // Refresh chat list
      loadChats();
    } catch (e) {
      print('Error creating demo chat: $e');
      rethrow;
    }
  }
}
