import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, audio, document, gif }

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoURL;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;
  final List<String> readBy;
  final List<String> deliveredTo;
  final bool isForwarded;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isGroupMessage;
  final String? groupId;
  final List<String> mentions;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoURL,
    required this.content,
    required this.type,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.mediaUrl,
    this.thumbnailUrl,
    this.metadata,
    this.replyToMessageId,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.isForwarded = false,
    this.isEdited = false,
    this.editedAt,
    this.isGroupMessage = false,
    this.groupId,
    this.mentions = const [],
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoURL: data['senderPhotoURL'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${data['status']}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      mediaUrl: data['mediaUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      metadata: data['metadata'],
      replyToMessageId: data['replyToMessageId'],
      readBy: List<String>.from(data['readBy'] ?? []),
      deliveredTo: List<String>.from(data['deliveredTo'] ?? []),
      isForwarded: data['isForwarded'] ?? false,
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt']?.toDate(),
      isGroupMessage: data['isGroupMessage'] ?? false,
      groupId: data['groupId'],
      mentions: List<String>.from(data['mentions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'readBy': readBy,
      'deliveredTo': deliveredTo,
      'isForwarded': isForwarded,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isGroupMessage': isGroupMessage,
      'groupId': groupId,
      'mentions': mentions,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderPhotoURL,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? mediaUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    List<String>? readBy,
    List<String>? deliveredTo,
    bool? isForwarded,
    bool? isEdited,
    DateTime? editedAt,
    bool? isGroupMessage,
    String? groupId,
    List<String>? mentions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoURL: senderPhotoURL ?? this.senderPhotoURL,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      isForwarded: isForwarded ?? this.isForwarded,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isGroupMessage: isGroupMessage ?? this.isGroupMessage,
      groupId: groupId ?? this.groupId,
      mentions: mentions ?? this.mentions,
    );
  }
}
