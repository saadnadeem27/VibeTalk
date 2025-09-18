import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flash_chat/app/controllers/chat_controller.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/models/chat_model.dart';
import 'package:flash_chat/app/widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  static const String id = 'chat_screen';

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.find<ChatController>();
    final String? chatId = Get.arguments?['chatId'];
    
    if (chatId != null) {
      chatController.openChat(chatId);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              _buildAppBar(chatController),
              
              // Messages list
              Expanded(
                child: _buildMessagesList(chatController),
              ),
              
              // Typing indicator
              _buildTypingIndicator(chatController),
              
              // Message input
              _buildMessageInput(chatController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ChatController chatController) {
    return Container(
      padding: EdgeInsets.all(VibeTalkSpacing.md),
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: VibeTalkColors.textPrimary,
            ),
          )
              .animate()
              .fadeIn()
              .slideX(begin: -0.3, end: 0),
          
          // Chat avatar
          Obx(() {
            final chat = chatController.currentChat.value;
            return CircleAvatar(
              radius: 20,
              backgroundColor: VibeTalkColors.primaryColor,
              backgroundImage: chat?.photoURL != null 
                  ? NetworkImage(chat!.photoURL!) 
                  : null,
              child: chat?.photoURL == null
                  ? Icon(
                      chat?.type == ChatType.group
                          ? Icons.group
                          : Icons.person,
                      color: VibeTalkColors.onPrimary,
                      size: 20,
                    )
                  : null,
            );
          })
              .animate()
              .scale(delay: Duration(milliseconds: 200)),
          
          SizedBox(width: VibeTalkSpacing.md),
          
          // Chat name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  chatController.currentChat.value?.name ?? 'Chat',
                  style: Theme.of(Get.context!).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
                
                Obx(() {
                  if (chatController.typingUser.value.isNotEmpty) {
                    return Text(
                      '${chatController.typingUser.value} is typing...',
                      style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                        color: VibeTalkColors.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }
                  
                  return Text(
                    'Online', // This would show real online status
                    style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                      color: VibeTalkColors.online,
                    ),
                  );
                }),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 300))
              .slideX(begin: -0.2, end: 0),
          
          // Video call button
          IconButton(
            onPressed: () {
              // TODO: Implement video call
            },
            icon: Icon(
              Icons.videocam,
              color: VibeTalkColors.primaryColor,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 400)),
          
          // Voice call button
          IconButton(
            onPressed: () {
              // TODO: Implement voice call
            },
            icon: Icon(
              Icons.call,
              color: VibeTalkColors.primaryColor,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 500)),
          
          // More options
          IconButton(
            onPressed: () {
              _showChatOptions();
            },
            icon: Icon(
              Icons.more_vert,
              color: VibeTalkColors.textPrimary,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatController chatController) {
    return Obx(() {
      if (chatController.messages.isEmpty) {
        return _buildEmptyMessages();
      }

      return ListView.builder(
        controller: chatController.scrollController,
        reverse: true,
        padding: EdgeInsets.all(VibeTalkSpacing.md),
        itemCount: chatController.messages.length,
        itemBuilder: (context, index) {
          final message = chatController.messages[index];
          final isMe = message.senderId == Get.find<AuthService>().user.value?.uid;
          
          return MessageBubble(
            message: message,
            isMe: isMe,
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.3, end: 0);
        },
      );
    });
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: VibeTalkColors.textHint,
          )
              .animate()
              .scale()
              .shimmer(),
          
          SizedBox(height: VibeTalkSpacing.lg),
          
          Text(
            'No messages yet',
            style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
              color: VibeTalkColors.textSecondary,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 300)),
          
          SizedBox(height: VibeTalkSpacing.sm),
          
          Text(
            'Send a message to start the conversation',
            style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
              color: VibeTalkColors.textHint,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 500)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ChatController chatController) {
    return Obx(() {
      if (chatController.typingUser.value.isEmpty) {
        return SizedBox.shrink();
      }
      
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: VibeTalkSpacing.lg,
          vertical: VibeTalkSpacing.sm,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 20,
              child: Row(
                children: [
                  _buildTypingDot(0),
                  SizedBox(width: 2),
                  _buildTypingDot(1),
                  SizedBox(width: 2),
                  _buildTypingDot(2),
                ],
              ),
            ),
            SizedBox(width: VibeTalkSpacing.sm),
            Text(
              '${chatController.typingUser.value} is typing...',
              style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                color: VibeTalkColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn()
          .slideY(begin: 0.3, end: 0);
    });
  }

  Widget _buildTypingDot(int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: VibeTalkColors.primaryColor,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          delay: Duration(milliseconds: index * 200),
          duration: Duration(milliseconds: 600),
          begin: Offset(0.5, 0.5),
          end: Offset(1.2, 1.2),
        );
  }

  Widget _buildMessageInput(ChatController chatController) {
    return Container(
      padding: EdgeInsets.all(VibeTalkSpacing.md),
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Attachment button
              IconButton(
                onPressed: () {
                  _showAttachmentOptions();
                },
                icon: Icon(
                  Icons.attach_file,
                  color: VibeTalkColors.primaryColor,
                ),
              ),
              
              // Message input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: VibeTalkColors.background,
                    borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
                  ),
                  child: TextField(
                    controller: chatController.messageController,
                    onChanged: chatController.onTypingChanged,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: VibeTalkSpacing.md,
                        vertical: VibeTalkSpacing.sm,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _showEmojiPicker();
                        },
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: VibeTalkColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: VibeTalkSpacing.sm),
              
              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient: VibeTalkColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: chatController.sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: VibeTalkColors.onPrimary,
                  ),
                ),
              )
                  .animate()
                  .scale()
                  .shimmer(delay: Duration(milliseconds: 1000)),
            ],
          ),
          
          // Voice message indicator
          Obx(() {
            if (chatController.isTyping.value) {
              return Container(
                margin: EdgeInsets.only(top: VibeTalkSpacing.sm),
                padding: EdgeInsets.symmetric(
                  horizontal: VibeTalkSpacing.md,
                  vertical: VibeTalkSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: VibeTalkColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(VibeTalkRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard,
                      size: 16,
                      color: VibeTalkColors.primaryColor,
                    ),
                    SizedBox(width: VibeTalkSpacing.xs),
                    Text(
                      'Typing...',
                      style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                        color: VibeTalkColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0);
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showChatOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(VibeTalkSpacing.lg),
        decoration: BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibeTalkRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info, color: VibeTalkColors.primaryColor),
              title: Text('Chat Info'),
              onTap: () {
                Get.back();
                // TODO: Navigate to chat info
              },
            ),
            ListTile(
              leading: Icon(Icons.search, color: VibeTalkColors.primaryColor),
              title: Text('Search Messages'),
              onTap: () {
                Get.back();
                // TODO: Implement message search
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off, color: VibeTalkColors.primaryColor),
              title: Text('Mute Notifications'),
              onTap: () {
                Get.back();
                // TODO: Implement mute
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(VibeTalkSpacing.lg),
        decoration: BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibeTalkRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: VibeTalkColors.primaryColor,
                  onTap: () {
                    Get.back();
                    // TODO: Open camera
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: VibeTalkColors.secondaryColor,
                  onTap: () {
                    Get.back();
                    // TODO: Open gallery
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.description,
                  label: 'Document',
                  color: VibeTalkColors.warning,
                  onTap: () {
                    Get.back();
                    // TODO: Open file picker
                  },
                ),
              ],
            ),
            SizedBox(height: VibeTalkSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: VibeTalkColors.error,
                  onTap: () {
                    Get.back();
                    // TODO: Share location
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.person,
                  label: 'Contact',
                  color: VibeTalkColors.success,
                  onTap: () {
                    Get.back();
                    // TODO: Share contact
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.mic,
                  label: 'Audio',
                  color: VibeTalkColors.primaryColor,
                  onTap: () {
                    Get.back();
                    // TODO: Record audio
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(height: VibeTalkSpacing.sm),
          Text(
            label,
            style: Theme.of(Get.context!).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    Get.bottomSheet(
      Container(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            final controller = Get.find<ChatController>();
            final text = controller.messageController.text;
            final selection = controller.messageController.selection;
            final newText = text.replaceRange(
              selection.start,
              selection.end,
              emoji.emoji,
            );
            controller.messageController.text = newText;
            controller.messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: selection.start + emoji.emoji.length),
            );
          },
        ),
      ),
    );
  }
}