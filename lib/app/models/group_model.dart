import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupMemberRole { admin, moderator, member }

class GroupMemberModel {
  final String userId;
  final String displayName;
  final String? profilePhoto;
  final GroupMemberRole role;
  final DateTime joinedAt;
  final bool isOnline;
  final DateTime? lastSeen;

  GroupMemberModel({
    required this.userId,
    required this.displayName,
    this.profilePhoto,
    required this.role,
    required this.joinedAt,
    this.isOnline = false,
    this.lastSeen,
  });

  factory GroupMemberModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupMemberModel(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      profilePhoto: data['profilePhoto'],
      role: GroupMemberRole.values.firstWhere(
        (e) => e.toString() == 'GroupMemberRole.${data['role']}',
        orElse: () => GroupMemberRole.member,
      ),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null 
          ? (data['lastSeen'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'profilePhoto': profilePhoto,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  GroupMemberModel copyWith({
    String? userId,
    String? displayName,
    String? profilePhoto,
    GroupMemberRole? role,
    DateTime? joinedAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return GroupMemberModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? groupPhoto;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<GroupMemberModel> members;
  final String? lastMessageId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int memberCount;
  final bool isActive;
  final Map<String, dynamic>? groupSettings;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.groupPhoto,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.members,
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.memberCount,
    this.isActive = true,
    this.groupSettings,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      groupPhoto: data['groupPhoto'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      members: [], // Members loaded separately for performance
      lastMessageId: data['lastMessageId'],
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null 
          ? (data['lastMessageTime'] as Timestamp).toDate() 
          : null,
      lastMessageSenderId: data['lastMessageSenderId'],
      memberCount: data['memberCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      groupSettings: data['groupSettings'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'groupPhoto': groupPhoto,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'memberCount': memberCount,
      'isActive': isActive,
      'groupSettings': groupSettings,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? groupPhoto,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GroupMemberModel>? members,
    String? lastMessageId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    int? memberCount,
    bool? isActive,
    Map<String, dynamic>? groupSettings,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupPhoto: groupPhoto ?? this.groupPhoto,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
      groupSettings: groupSettings ?? this.groupSettings,
    );
  }

  // Helper methods
  bool isUserAdmin(String userId) {
    return members.any((member) => 
        member.userId == userId && member.role == GroupMemberRole.admin);
  }

  bool isUserModerator(String userId) {
    return members.any((member) => 
        member.userId == userId && 
        (member.role == GroupMemberRole.admin || member.role == GroupMemberRole.moderator));
  }

  List<GroupMemberModel> get admins {
    return members.where((member) => member.role == GroupMemberRole.admin).toList();
  }

  List<GroupMemberModel> get onlineMembers {
    return members.where((member) => member.isOnline).toList();
  }
}