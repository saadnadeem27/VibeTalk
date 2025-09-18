import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/controllers/group_controller.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.put(GroupController());

    return Scaffold(
      backgroundColor: VibeTalkColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: VibeTalkColors.surface,
        title: const Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: groupController.isCreatingGroup.value
                    ? null
                    : () => groupController.createGroup(),
                child: groupController.isCreatingGroup.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(
                          color: VibeTalkColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Photo Section
              Center(
                child: GestureDetector(
                  onTap: () => _showImagePicker(groupController),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: VibeTalkColors.primaryGradient,
                      border: Border.all(
                        color: VibeTalkColors.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: const Duration(milliseconds: 600))
                    .fadeIn(duration: const Duration(milliseconds: 600)),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Tap to add group photo',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Group Name
              _buildInputField(
                controller: groupController.groupNameController,
                label: 'Group Name',
                hint: 'Enter group name',
                icon: Icons.group,
                maxLength: 50,
              )
                  .animate()
                  .slideX(duration: const Duration(milliseconds: 500))
                  .fadeIn(duration: const Duration(milliseconds: 500)),

              const SizedBox(height: 20),

              // Group Description
              _buildInputField(
                controller: groupController.groupDescriptionController,
                label: 'Description (Optional)',
                hint: 'Enter group description',
                icon: Icons.description,
                maxLines: 3,
                maxLength: 200,
              )
                  .animate()
                  .slideX(
                    begin: -0.3,
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                  )
                  .fadeIn(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                  ),

              const SizedBox(height: 24),

              // Member Selection Section
              const Text(
                'Add Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Mock Member List
              _buildMembersList(groupController),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: VibeTalkColors.surface,
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(color: VibeTalkColors.primaryColor.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: VibeTalkColors.primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(GroupController groupController) {
    // Mock data - replace with actual contacts from your service
    final mockMembers = [
      {'id': 'user1', 'name': 'Alice Johnson', 'email': 'alice@example.com'},
      {'id': 'user2', 'name': 'Bob Smith', 'email': 'bob@example.com'},
      {'id': 'user3', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
      {'id': 'user4', 'name': 'Diana Prince', 'email': 'diana@example.com'},
      {'id': 'user5', 'name': 'Eve Adams', 'email': 'eve@example.com'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: VibeTalkColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: VibeTalkColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Selected Members Count
          Obx(() => groupController.selectedMembers.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: VibeTalkColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: VibeTalkColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.group,
                        size: 16,
                        color: VibeTalkColors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${groupController.selectedMembers.length} members selected',
                        style: const TextStyle(
                          color: VibeTalkColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()),

          // Member List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockMembers.length,
            itemBuilder: (context, index) {
              final member = mockMembers[index];
              final memberId = member['id'] as String;

              return Obx(() => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: VibeTalkColors.primaryColor,
                      child: Text(
                        (member['name'] as String)[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      member['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      member['email'] as String,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Checkbox(
                      value: groupController.isUserSelected(memberId),
                      onChanged: (value) =>
                          groupController.toggleMemberSelection(memberId),
                      activeColor: VibeTalkColors.primaryColor,
                      checkColor: Colors.white,
                    ),
                    onTap: () =>
                        groupController.toggleMemberSelection(memberId),
                  ));
            },
          ),
        ],
      ),
    );
  }

  void _showImagePicker(GroupController groupController) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: VibeTalkColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Group Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    Get.snackbar('Info', 'Camera capture will be implemented');
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                        'Info', 'Gallery selection will be implemented');
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.person,
                  label: 'Default',
                  onTap: () {
                    groupController.groupPhotoPath.value = '';
                    Get.back();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: VibeTalkColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: VibeTalkColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: VibeTalkColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
