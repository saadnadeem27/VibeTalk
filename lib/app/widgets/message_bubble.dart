import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: VibeTalkSpacing.xs,
        horizontal: VibeTalkSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message content
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildSenderAvatar(),
              if (!isMe) const SizedBox(width: VibeTalkSpacing.sm),
              Flexible(
                child: _buildMessageContainer(context),
              ),
              if (isMe) const SizedBox(width: VibeTalkSpacing.sm),
              if (isMe) _buildMessageStatus(),
            ],
          ),

          // Message time
          Container(
            margin: EdgeInsets.only(
              top: VibeTalkSpacing.xs,
              left: isMe ? 0 : 40,
              right: isMe ? 20 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: VibeTalkColors.textHint,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: VibeTalkColors.primaryColor,
      backgroundImage: message.senderPhotoURL != null
          ? NetworkImage(message.senderPhotoURL!)
          : null,
      child: message.senderPhotoURL == null
          ? Text(
              message.senderName.isNotEmpty
                  ? message.senderName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: VibeTalkColors.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        gradient: isMe
            ? VibeTalkColors.primaryGradient
            : const LinearGradient(
                colors: [
                  VibeTalkColors.receivedMessageColor,
                  VibeTalkColors.receivedMessageColor
                ],
              ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(VibeTalkRadius.lg),
          topRight: const Radius.circular(VibeTalkRadius.lg),
          bottomLeft:
              Radius.circular(isMe ? VibeTalkRadius.lg : VibeTalkRadius.sm),
          bottomRight:
              Radius.circular(isMe ? VibeTalkRadius.sm : VibeTalkRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: (isMe ? VibeTalkColors.primaryColor : Colors.black)
                .withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender name for group chats
          if (!isMe && message.senderName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: VibeTalkSpacing.md,
                right: VibeTalkSpacing.md,
                top: VibeTalkSpacing.sm,
              ),
              child: Text(
                message.senderName,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: VibeTalkColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

          // Reply to message indicator
          if (message.replyToMessageId != null)
            Container(
              margin: const EdgeInsets.only(
                left: VibeTalkSpacing.md,
                right: VibeTalkSpacing.md,
                top: VibeTalkSpacing.sm,
              ),
              padding: const EdgeInsets.all(VibeTalkSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(VibeTalkRadius.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    color: VibeTalkColors.secondaryColor,
                  ),
                  const SizedBox(width: VibeTalkSpacing.sm),
                  Expanded(
                    child: Text(
                      'Replying to a message',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: isMe
                                ? VibeTalkColors.onPrimary.withOpacity(0.8)
                                : VibeTalkColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Message content
          _buildMessageContent(context),

          // Edited indicator
          if (message.isEdited)
            Padding(
              padding: const EdgeInsets.only(
                left: VibeTalkSpacing.md,
                right: VibeTalkSpacing.md,
                bottom: VibeTalkSpacing.sm,
              ),
              child: Text(
                'Edited',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isMe
                          ? VibeTalkColors.onPrimary.withOpacity(0.6)
                          : VibeTalkColors.textHint,
                      fontStyle: FontStyle.italic,
                      fontSize: 10,
                    ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: VibeTalkAnimations.fast,
        )
        .fadeIn();
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.all(VibeTalkSpacing.md),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isMe
                      ? VibeTalkColors.onPrimary
                      : VibeTalkColors.textPrimary,
                ),
          ),
        );

      case MessageType.image:
        return _buildImageMessage(context);

      case MessageType.video:
        return _buildVideoMessage(context);

      case MessageType.audio:
        return _buildAudioMessage(context);

      case MessageType.document:
        return _buildDocumentMessage(context);

      case MessageType.gif:
        return _buildGifMessage(context);

      default:
        return Padding(
          padding: const EdgeInsets.all(VibeTalkSpacing.md),
          child: Text(
            'Unsupported message type',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isMe
                      ? VibeTalkColors.onPrimary.withOpacity(0.7)
                      : VibeTalkColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        );
    }
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(VibeTalkRadius.md),
            child: Image.network(
              message.mediaUrl!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: VibeTalkColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: VibeTalkColors.primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: VibeTalkColors.surface,
                  child: const Icon(
                    Icons.broken_image,
                    color: VibeTalkColors.textHint,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(VibeTalkSpacing.md),
            child: Text(
              message.content,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isMe
                        ? VibeTalkColors.onPrimary
                        : VibeTalkColors.textPrimary,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        borderRadius: BorderRadius.circular(VibeTalkRadius.md),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.play_circle_outline,
            color: VibeTalkColors.primaryColor,
            size: 50,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VibeTalkSpacing.sm,
                vertical: VibeTalkSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(VibeTalkRadius.sm),
              ),
              child: const Text(
                '00:30', // This would be the actual video duration
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VibeTalkSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color:
                isMe ? VibeTalkColors.onPrimary : VibeTalkColors.primaryColor,
          ),
          const SizedBox(width: VibeTalkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Row(
                    children: List.generate(20, (index) {
                      return Container(
                        width: 2,
                        height: (index % 3 + 1) * 6.0,
                        margin: const EdgeInsets.only(right: 1),
                        decoration: BoxDecoration(
                          color: isMe
                              ? VibeTalkColors.onPrimary.withOpacity(0.7)
                              : VibeTalkColors.primaryColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: VibeTalkSpacing.xs),
                Text(
                  '0:30', // This would be the actual audio duration
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: isMe
                            ? VibeTalkColors.onPrimary.withOpacity(0.8)
                            : VibeTalkColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VibeTalkSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(VibeTalkSpacing.sm),
            decoration: BoxDecoration(
              color: isMe
                  ? VibeTalkColors.onPrimary.withOpacity(0.2)
                  : VibeTalkColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(VibeTalkRadius.sm),
            ),
            child: Icon(
              Icons.description,
              color:
                  isMe ? VibeTalkColors.onPrimary : VibeTalkColors.primaryColor,
            ),
          ),
          const SizedBox(width: VibeTalkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content.isNotEmpty ? message.content : 'Document',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isMe
                            ? VibeTalkColors.onPrimary
                            : VibeTalkColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '12 KB', // This would be the actual file size
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: isMe
                            ? VibeTalkColors.onPrimary.withOpacity(0.8)
                            : VibeTalkColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGifMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(VibeTalkRadius.md),
      child: Image.network(
        message.mediaUrl ?? '',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 150,
            height: 150,
            color: VibeTalkColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                color: VibeTalkColors.primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 150,
            height: 150,
            color: VibeTalkColors.surface,
            child: const Icon(
              Icons.gif,
              color: VibeTalkColors.textHint,
              size: 40,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData statusIcon;
    Color statusColor;

    switch (message.status) {
      case MessageStatus.sending:
        statusIcon = Icons.schedule;
        statusColor = VibeTalkColors.textHint;
        break;
      case MessageStatus.sent:
        statusIcon = Icons.check;
        statusColor = VibeTalkColors.textHint;
        break;
      case MessageStatus.delivered:
        statusIcon = Icons.done_all;
        statusColor = VibeTalkColors.textHint;
        break;
      case MessageStatus.read:
        statusIcon = Icons.done_all;
        statusColor = VibeTalkColors.primaryColor;
        break;
      case MessageStatus.failed:
        statusIcon = Icons.error_outline;
        statusColor = VibeTalkColors.error;
        break;
    }

    return Icon(
      statusIcon,
      size: 16,
      color: statusColor,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEE HH:mm').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy HH:mm').format(dateTime);
    }
  }
}
