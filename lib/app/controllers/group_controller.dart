import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/app/models/group_model.dart';
import 'package:flash_chat/app/models/message_model.dart';
import 'package:flash_chat/app/services/group_service.dart';
import 'package:flash_chat/app/services/auth_service.dart';

class GroupController extends GetxController {
  final GroupService _groupService = Get.find<GroupService>();
  final AuthService _authService = Get.find<AuthService>();

  // Current group being viewed
  Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  RxList<GroupMemberModel> groupMembers = <GroupMemberModel>[].obs;
  RxList<MessageModel> groupMessages = <MessageModel>[].obs;

  // Group creation form
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  RxList<String> selectedMembers = <String>[].obs;
  RxString groupPhotoPath = ''.obs;

  // Group settings
  RxBool allowMembersToAddOthers = false.obs;
  RxBool allowMembersToChangeGroupInfo = false.obs;
  RxBool allowMembersToSendMessages = true.obs;
  RxBool allowMembersToSendMedia = true.obs;
  RxBool muteNewMembers = false.obs;
  RxBool requireAdminApproval = false.obs;

  // UI state
  RxBool isLoading = false.obs;
  RxBool isCreatingGroup = false.obs;
  RxString searchQuery = ''.obs;
  RxBool showMembersList = false.obs;
  RxBool showGroupSettings = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to group service updates
    ever(_groupService.userGroups, (_) => update());
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.onClose();
  }

  // Create new group
  Future<void> createGroup() async {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a group name');
      return;
    }

    isCreatingGroup.value = true;
    try {
      final groupSettings = {
        'allowMembersToAddOthers': allowMembersToAddOthers.value,
        'allowMembersToChangeGroupInfo': allowMembersToChangeGroupInfo.value,
        'allowMembersToSendMessages': allowMembersToSendMessages.value,
        'allowMembersToSendMedia': allowMembersToSendMedia.value,
        'muteNewMembers': muteNewMembers.value,
        'requireAdminApproval': requireAdminApproval.value,
      };

      final groupId = await _groupService.createGroup(
        name: groupNameController.text.trim(),
        description: groupDescriptionController.text.trim(),
        memberIds: selectedMembers.toList(),
        groupPhoto: groupPhotoPath.value.isNotEmpty ? groupPhotoPath.value : null,
        groupSettings: groupSettings,
      );

      if (groupId != null) {
        // Clear form
        clearCreateGroupForm();
        Get.back(); // Close create group screen
        Get.snackbar('Success', 'Group created successfully!');
        
        // Navigate to group chat
        // Get.to(() => GroupChatScreen(groupId: groupId));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
    } finally {
      isCreatingGroup.value = false;
    }
  }

  // Join group
  Future<void> joinGroup(String groupId, String inviteCode) async {
    isLoading.value = true;
    try {
      final success = await _groupService.joinGroup(
        groupId: groupId,
        inviteCode: inviteCode,
      );

      if (success) {
        Get.snackbar('Success', 'Joined group successfully!');
        // Navigate to group chat
        // Get.to(() => GroupChatScreen(groupId: groupId));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join group: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Leave group
  Future<void> leaveGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      isLoading.value = true;
      try {
        final success = await _groupService.leaveGroup(groupId);
        if (success) {
          Get.back(); // Navigate back from group chat
          Get.snackbar('Success', 'Left group successfully');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to leave group: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Add member to group
  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
    required String displayName,
    String? profilePhoto,
  }) async {
    try {
      final currentUserId = _authService.user.value?.uid;
      if (currentUserId == null) return;

      // Check if user can add members
      final canAdd = await _groupService.canManageMembers(groupId, currentUserId);
      if (!canAdd) {
        Get.snackbar('Error', 'You don\'t have permission to add members');
        return;
      }

      final success = await _groupService.addGroupMember(
        groupId: groupId,
        userId: userId,
        displayName: displayName,
        profilePhoto: profilePhoto,
      );

      if (success) {
        Get.snackbar('Success', 'Member added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member: $e');
    }
  }

  // Remove member from group
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String userId,
    required String memberName,
  }) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove $memberName from this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUserId = _authService.user.value?.uid;
        if (currentUserId == null) return;

        final success = await _groupService.removeGroupMember(
          groupId: groupId,
          userId: userId,
          currentUserId: currentUserId,
        );

        if (success) {
          Get.snackbar('Success', 'Member removed successfully');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to remove member: $e');
      }
    }
  }

  // Promote/demote member
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupMemberRole newRole,
    required String memberName,
  }) async {
    final roleText = newRole == GroupMemberRole.admin ? 'admin' : 
                     newRole == GroupMemberRole.moderator ? 'moderator' : 'member';
    
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Change Role'),
        content: Text('Make $memberName a $roleText?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUserId = _authService.user.value?.uid;
        if (currentUserId == null) return;

        final success = await _groupService.updateMemberRole(
          groupId: groupId,
          userId: userId,
          newRole: newRole,
          currentUserId: currentUserId,
        );

        if (success) {
          Get.snackbar('Success', 'Member role updated successfully');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to update member role: $e');
      }
    }
  }

  // Load group details
  void loadGroupDetails(String groupId) {
    // Listen to group stream
    _groupService.getGroupStream(groupId).listen((group) {
      currentGroup.value = group;
      if (group?.groupSettings != null) {
        _updateGroupSettingsFromData(group!.groupSettings!);
      }
    });

    // Listen to group members
    _groupService.getGroupMembers(groupId).listen((members) {
      groupMembers.value = members;
    });
  }

  // Update group settings
  Future<void> updateGroupSettings(String groupId) async {
    try {
      final currentUserId = _authService.user.value?.uid;
      if (currentUserId == null) return;

      final settings = {
        'allowMembersToAddOthers': allowMembersToAddOthers.value,
        'allowMembersToChangeGroupInfo': allowMembersToChangeGroupInfo.value,
        'allowMembersToSendMessages': allowMembersToSendMessages.value,
        'allowMembersToSendMedia': allowMembersToSendMedia.value,
        'muteNewMembers': muteNewMembers.value,
        'requireAdminApproval': requireAdminApproval.value,
      };

      final success = await _groupService.updateGroupSettings(
        groupId: groupId,
        currentUserId: currentUserId,
        settings: settings,
      );

      if (success) {
        Get.snackbar('Success', 'Group settings updated');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings: $e');
    }
  }

  // Delete group
  Future<void> deleteGroup(String groupId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUserId = _authService.user.value?.uid;
        if (currentUserId == null) return;

        final success = await _groupService.deleteGroup(
          groupId: groupId,
          currentUserId: currentUserId,
        );

        if (success) {
          Get.back(); // Navigate back from group
          Get.snackbar('Success', 'Group deleted successfully');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete group: $e');
      }
    }
  }

  // Helper methods
  void clearCreateGroupForm() {
    groupNameController.clear();
    groupDescriptionController.clear();
    selectedMembers.clear();
    groupPhotoPath.value = '';
    allowMembersToAddOthers.value = false;
    allowMembersToChangeGroupInfo.value = false;
    allowMembersToSendMessages.value = true;
    allowMembersToSendMedia.value = true;
    muteNewMembers.value = false;
    requireAdminApproval.value = false;
  }

  void toggleMemberSelection(String userId) {
    if (selectedMembers.contains(userId)) {
      selectedMembers.remove(userId);
    } else {
      selectedMembers.add(userId);
    }
  }

  void toggleMembersList() {
    showMembersList.value = !showMembersList.value;
  }

  void toggleGroupSettings() {
    showGroupSettings.value = !showGroupSettings.value;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  bool isUserSelected(String userId) {
    return selectedMembers.contains(userId);
  }

  bool isCurrentUserAdmin(String groupId) {
    final currentUserId = _authService.user.value?.uid;
    if (currentUserId == null) return false;
    
    return currentGroup.value?.isUserAdmin(currentUserId) ?? false;
  }

  bool isCurrentUserModerator(String groupId) {
    final currentUserId = _authService.user.value?.uid;
    if (currentUserId == null) return false;
    
    return currentGroup.value?.isUserModerator(currentUserId) ?? false;
  }

  int get onlineMembersCount {
    return groupMembers.where((member) => member.isOnline).length;
  }

  List<GroupMemberModel> get filteredMembers {
    if (searchQuery.value.isEmpty) {
      return groupMembers.toList();
    }
    return groupMembers.where((member) =>
        member.displayName.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  void _updateGroupSettingsFromData(Map<String, dynamic> settings) {
    allowMembersToAddOthers.value = settings['allowMembersToAddOthers'] ?? false;
    allowMembersToChangeGroupInfo.value = settings['allowMembersToChangeGroupInfo'] ?? false;
    allowMembersToSendMessages.value = settings['allowMembersToSendMessages'] ?? true;
    allowMembersToSendMedia.value = settings['allowMembersToSendMedia'] ?? true;
    muteNewMembers.value = settings['muteNewMembers'] ?? false;
    requireAdminApproval.value = settings['requireAdminApproval'] ?? false;
  }
}