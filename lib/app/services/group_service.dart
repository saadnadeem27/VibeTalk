import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flash_chat/app/models/group_model.dart';
import 'package:flash_chat/app/models/message_model.dart';

class GroupService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable lists
  RxList<GroupModel> userGroups = <GroupModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserGroups();
  }

  // Create a new group
  Future<String?> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
    String? groupPhoto,
    Map<String, dynamic>? groupSettings,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Create group document
      final groupDoc = _firestore.collection('groups').doc();
      final groupId = groupDoc.id;

      // Prepare group data
      final groupData = GroupModel(
        id: groupId,
        name: name,
        description: description,
        groupPhoto: groupPhoto,
        createdBy: currentUser.uid,
        createdAt: DateTime.now(),
        members: [], // Will be added separately
        memberCount: memberIds.length + 1, // +1 for creator
        groupSettings: groupSettings ?? _getDefaultGroupSettings(),
      );

      // Create group
      await groupDoc.set(groupData.toFirestore());

      // Add creator as admin
      await addGroupMember(
        groupId: groupId,
        userId: currentUser.uid,
        displayName: currentUser.displayName ?? 'Unknown',
        role: GroupMemberRole.admin,
      );

      // Add other members
      for (String memberId in memberIds) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          await addGroupMember(
            groupId: groupId,
            userId: memberId,
            displayName: userData['displayName'] ?? 'Unknown',
            role: GroupMemberRole.member,
          );
        }
      }

      // Send welcome message
      await sendSystemMessage(
        groupId: groupId,
        message: '${currentUser.displayName ?? 'Someone'} created this group',
      );

      await loadUserGroups();
      return groupId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Add member to group
  Future<bool> addGroupMember({
    required String groupId,
    required String userId,
    required String displayName,
    String? profilePhoto,
    GroupMemberRole role = GroupMemberRole.member,
  }) async {
    try {
      final memberData = GroupMemberModel(
        userId: userId,
        displayName: displayName,
        profilePhoto: profilePhoto,
        role: role,
        joinedAt: DateTime.now(),
      );

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .set(memberData.toFirestore());

      // Update member count
      await _firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member: $e');
      return false;
    }
  }

  // Remove member from group
  Future<bool> removeGroupMember({
    required String groupId,
    required String userId,
    required String currentUserId,
  }) async {
    try {
      // Check if current user has permission
      final canRemove = await canManageMembers(groupId, currentUserId);
      if (!canRemove && userId != currentUserId) {
        Get.snackbar('Error', 'You don\'t have permission to remove members');
        return false;
      }

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .delete();

      // Update member count
      await _firestore.collection('groups').doc(groupId).update({
        'memberCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Send system message
      if (userId == currentUserId) {
        await sendSystemMessage(groupId: groupId, message: 'Someone left the group');
      } else {
        await sendSystemMessage(groupId: groupId, message: 'Someone was removed from the group');
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove member: $e');
      return false;
    }
  }

  // Promote/demote member
  Future<bool> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupMemberRole newRole,
    required String currentUserId,
  }) async {
    try {
      // Check if current user is admin
      final isAdmin = await isGroupAdmin(groupId, currentUserId);
      if (!isAdmin) {
        Get.snackbar('Error', 'Only admins can change member roles');
        return false;
      }

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .update({'role': newRole.toString().split('.').last});

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update member role: $e');
      return false;
    }
  }

  // Join group by invitation
  Future<bool> joinGroup({
    required String groupId,
    required String inviteCode,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Verify invite code (implementation depends on your invite system)
      // For now, we'll assume any user can join any group

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) throw Exception('User data not found');

      final userData = userDoc.data() as Map<String, dynamic>;
      
      await addGroupMember(
        groupId: groupId,
        userId: currentUser.uid,
        displayName: userData['displayName'] ?? 'Unknown',
        profilePhoto: userData['profilePhoto'],
        role: GroupMemberRole.member,
      );

      await sendSystemMessage(
        groupId: groupId,
        message: '${userData['displayName'] ?? 'Someone'} joined the group',
      );

      await loadUserGroups();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to join group: $e');
      return false;
    }
  }

  // Leave group
  Future<bool> leaveGroup(String groupId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      return await removeGroupMember(
        groupId: groupId,
        userId: currentUser.uid,
        currentUserId: currentUser.uid,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave group: $e');
      return false;
    }
  }

  // Get group members
  Stream<List<GroupMemberModel>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupMemberModel.fromFirestore(doc))
            .toList());
  }

  // Get group details
  Stream<GroupModel?> getGroupStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((doc) => doc.exists ? GroupModel.fromFirestore(doc) : null);
  }

  // Check if user is admin
  Future<bool> isGroupAdmin(String groupId, String userId) async {
    try {
      final memberDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();

      if (!memberDoc.exists) return false;

      final memberData = GroupMemberModel.fromFirestore(memberDoc);
      return memberData.role == GroupMemberRole.admin;
    } catch (e) {
      return false;
    }
  }

  // Check if user can manage members
  Future<bool> canManageMembers(String groupId, String userId) async {
    try {
      final memberDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();

      if (!memberDoc.exists) return false;

      final memberData = GroupMemberModel.fromFirestore(memberDoc);
      return memberData.role == GroupMemberRole.admin || 
             memberData.role == GroupMemberRole.moderator;
    } catch (e) {
      return false;
    }
  }

  // Load user's groups
  Future<void> loadUserGroups() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final groupMemberships = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      List<GroupModel> groups = [];
      for (var membership in groupMemberships.docs) {
        final groupId = membership.reference.parent.parent!.id;
        final groupDoc = await _firestore.collection('groups').doc(groupId).get();
        
        if (groupDoc.exists && (groupDoc.data()?['isActive'] ?? true)) {
          groups.add(GroupModel.fromFirestore(groupDoc));
        }
      }

      // Sort by last message time
      groups.sort((a, b) {
        final timeA = a.lastMessageTime ?? a.createdAt;
        final timeB = b.lastMessageTime ?? b.createdAt;
        return timeB.compareTo(timeA);
      });

      userGroups.value = groups;
    } catch (e) {
      print('Error loading user groups: $e');
    }
  }

  // Send system message
  Future<void> sendSystemMessage({
    required String groupId,
    required String message,
  }) async {
    try {
      final messageDoc = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      final systemMessage = MessageModel(
        id: messageDoc.id,
        chatId: groupId,
        senderId: 'system',
        senderName: 'System',
        content: message,
        type: MessageType.text,
        timestamp: DateTime.now(),
        isGroupMessage: true,
        groupId: groupId,
      );

      await messageDoc.set(systemMessage.toFirestore());

      // Update group's last message
      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': 'system',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error sending system message: $e');
    }
  }

  // Default group settings
  Map<String, dynamic> _getDefaultGroupSettings() {
    return {
      'allowMembersToAddOthers': false,
      'allowMembersToChangeGroupInfo': false,
      'allowMembersToSendMessages': true,
      'allowMembersToSendMedia': true,
      'muteNewMembers': false,
      'requireAdminApproval': false,
    };
  }

  // Update group settings
  Future<bool> updateGroupSettings({
    required String groupId,
    required String currentUserId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final isAdmin = await isGroupAdmin(groupId, currentUserId);
      if (!isAdmin) {
        Get.snackbar('Error', 'Only admins can change group settings');
        return false;
      }

      await _firestore.collection('groups').doc(groupId).update({
        'groupSettings': settings,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update group settings: $e');
      return false;
    }
  }

  // Delete group (admin only)
  Future<bool> deleteGroup({
    required String groupId,
    required String currentUserId,
  }) async {
    try {
      final isAdmin = await isGroupAdmin(groupId, currentUserId);
      if (!isAdmin) {
        Get.snackbar('Error', 'Only admins can delete groups');
        return false;
      }

      // Mark group as inactive instead of deleting
      await _firestore.collection('groups').doc(groupId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await loadUserGroups();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete group: $e');
      return false;
    }
  }
}