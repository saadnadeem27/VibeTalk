import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/models/chat_model.dart';
import '../app/services/auth_service.dart';

class IndividualChatScreen extends StatefulWidget {
  final ChatModel chat;

  const IndividualChatScreen({super.key, required this.chat});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1D29),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFF74B9FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                widget.chat.participants.first[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.participants.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF74B9FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            // Video call functionality - placeholder
            Get.snackbar(
              'Coming Soon',
              'Video call feature will be available soon!',
              backgroundColor: const Color(0xFF1A1D29),
              colorText: Colors.white,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            // Voice call functionality - placeholder
            Get.snackbar(
              'Coming Soon',
              'Voice call feature will be available soon!',
              backgroundColor: const Color(0xFF1A1D29),
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    // For now, show a placeholder with some sample messages
    String currentUserId = _authService.user.value?.uid ?? 'current_user';

    List<Map<String, dynamic>> sampleMessages = [
      {
        'id': '1',
        'senderId': 'other_user',
        'senderName': widget.chat.participants.first,
        'content': 'Hey! How are you doing?',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'id': '2',
        'senderId': currentUserId,
        'senderName': 'You',
        'content': 'I\'m doing great! Thanks for asking 😊',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
      },
      {
        'id': '3',
        'senderId': 'other_user',
        'senderName': widget.chat.participants.first,
        'content': 'That\'s awesome to hear!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B0E11),
            const Color(0xFF1A1D29).withOpacity(0.3),
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sampleMessages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(sampleMessages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    String currentUserId = _authService.user.value?.uid ?? 'current_user';
    final bool isCurrentUser = message['senderId'] == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF74B9FF),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  widget.chat.participants.first[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isCurrentUser
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF6C5CE7),
                          Color(0xFF74B9FF),
                        ],
                      )
                    : null,
                color: isCurrentUser ? null : const Color(0xFF1A1D29),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2D3748).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['content'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp']),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF74B9FF),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E11),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF2D3748).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: () {
                      // File attachment functionality - placeholder
                      Get.snackbar(
                        'Coming Soon',
                        'File attachment feature will be available soon!',
                        backgroundColor: const Color(0xFF1A1D29),
                        colorText: Colors.white,
                      );
                    },
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFF74B9FF),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _messageController.clear();

    // For now, just show a placeholder message
    Get.snackbar(
      'Message Sent',
      'Individual chat messaging will be fully functional soon!',
      backgroundColor: const Color(0xFF1A1D29),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // TODO: Implement actual message sending to Firestore
    // This would involve creating a ChatService similar to GroupService
    // and implementing real-time messaging for individual chats
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
