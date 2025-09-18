import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType { individual, group }

class ChatModel {
  final String id;
  final String name;
  final String? description;
  final String? photoURL;
  final ChatType type;
  final List<String> participants;
  final List<String> admins;
  final String? lastMessageId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> typingStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isMuted;
  final String? createdBy;

  ChatModel({
    required this.id,
    required this.name,
    this.description,
    this.photoURL,
    required this.type,
    required this.participants,
    this.admins = const [],
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    this.typingStatus = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isMuted = false,
    this.createdBy,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      photoURL: data['photoURL'],
      type: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${data['type']}',
        orElse: () => ChatType.individual,
      ),
      participants: List<String>.from(data['participants'] ?? []),
      admins: List<String>.from(data['admins'] ?? []),
      lastMessageId: data['lastMessageId'],
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime']?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      typingStatus: Map<String, bool>.from(data['typingStatus'] ?? {}),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      isMuted: data['isMuted'] ?? false,
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'photoURL': photoURL,
      'type': type.toString().split('.').last,
      'participants': participants,
      'admins': admins,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'typingStatus': typingStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'isMuted': isMuted,
      'createdBy': createdBy,
    };
  }

  ChatModel copyWith({
    String? id,
    String? name,
    String? description,
    String? photoURL,
    ChatType? type,
    List<String>? participants,
    List<String>? admins,
    String? lastMessageId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? typingStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isMuted,
    String? createdBy,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoURL: photoURL ?? this.photoURL,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      admins: admins ?? this.admins,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      typingStatus: typingStatus ?? this.typingStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
