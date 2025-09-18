import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/models/group_model.dart';
import 'package:flash_chat/app/models/message_model.dart';
import 'package:flash_chat/app/services/group_service.dart';
import 'package:flash_chat/app/services/auth_service.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroupService _groupService = Get.find<GroupService>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1D29),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE17055), Color(0xFFFDCB6E)],
              ),
              shape: BoxShape.circle,
              image: widget.group.groupPhoto != null
                  ? DecorationImage(
                      image: NetworkImage(widget.group.groupPhoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.group.groupPhoto == null
                ? const Icon(Icons.group, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.group.memberCount} members',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
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
          onPressed: _showGroupInfo,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _getGroupMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C5CE7),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyMessages();
        }

        final messages = snapshot.data!;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == _authService.currentUser.value?.id;
            final showSenderName = !isMe &&
                (index == 0 ||
                    messages[index - 1].senderId != message.senderId);

            return _buildMessageBubble(message, isMe, showSenderName);
          },
        );
      },
    );
  }

  Widget _buildEmptyMessages() {
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
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to send a message in ${widget.group.name}',
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

  Widget _buildMessageBubble(
      MessageModel message, bool isMe, bool showSenderName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderName && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                          )
                        : null,
                    color: isMe ? null : const Color(0xFF1A1D29),
                    borderRadius: BorderRadius.circular(16),
                    border: isMe
                        ? null
                        : Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: isMe ? 0.3 : -0.3, end: 0);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E11),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<MessageModel>> _getGroupMessages() {
    return _groupService.getGroupMessages(widget.group.id);
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    _messageController.clear();

    try {
      await _groupService.sendGroupMessage(
        groupId: widget.group.id,
        content: content,
        senderId: currentUser.id,
        senderName: currentUser.displayName,
      );

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _messageController.text = content; // Restore message
    }
  }

  void _showGroupInfo() {
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE17055), Color(0xFFFDCB6E)],
                ),
                shape: BoxShape.circle,
                image: widget.group.groupPhoto != null
                    ? DecorationImage(
                        image: NetworkImage(widget.group.groupPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.group.groupPhoto == null
                  ? const Icon(Icons.group, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.group.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.group.description.isNotEmpty
                  ? widget.group.description
                  : 'No description',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInfoItem(
              icon: Icons.group,
              title: 'Members',
              subtitle: '${widget.group.memberCount} members',
              onTap: () {
                Get.back();
                _showGroupMembers();
              },
            ),
            _buildInfoItem(
              icon: Icons.settings,
              title: 'Group Settings',
              subtitle: 'Manage group preferences',
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Group settings coming soon!');
              },
            ),
            _buildInfoItem(
              icon: Icons.exit_to_app,
              title: 'Leave Group',
              subtitle: 'Exit this group conversation',
              isDestructive: true,
              onTap: () {
                Get.back();
                _showLeaveGroupDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showGroupMembers() {
    // TODO: Implement group members screen
    Get.snackbar('Info', 'Group members list coming soon!');
  }

  void _showLeaveGroupDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Leave Group',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave "${widget.group.name}"? You won\'t receive new messages from this group.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await _groupService.leaveGroup(widget.group.id);
              if (success) {
                Get.back(); // Exit group chat screen
                Get.snackbar(
                  'Success',
                  'You left the group',
                  backgroundColor: const Color(0xFF6C5CE7),
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
