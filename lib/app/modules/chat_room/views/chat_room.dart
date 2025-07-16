// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/models/customer_model/user_model.dart';
import 'package:llm_video_shopify/app/modules/chat_room/controllers/chat_room_controller.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room_screen.dart';
import 'package:llm_video_shopify/app/modules/video_script/controllers/video_script_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SendVideoScreen extends StatefulWidget {
  const SendVideoScreen({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  _SendVideoScreenState createState() => _SendVideoScreenState();
}

class _SendVideoScreenState extends State<SendVideoScreen> {
  final VideoScriptController videoController =
      Get.find<VideoScriptController>();
  final ChatRoomController chatController = Get.put(ChatRoomController());
  final TextEditingController descriptionController = TextEditingController();

  // Selected chat users for hold-to-select functionality

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Send Video',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () =>
                chatController.selectedUsers.isNotEmpty
                    ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: ElevatedButton.icon(
                        onPressed: _sendVideoToSelectedUsers,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Send',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.blue.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Description Input
            _buildDescriptionInput(),
            const SizedBox(height: 16),

            // User Search Section
            _buildUserSearchSection(),
            const SizedBox(height: 16),

            // Selected Users List
            _buildSelectedUsersList(),

            // Chat History Section
            _buildChatHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.blue.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add a description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a message about this video...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.green.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add recipients',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field with Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.emailSearchController,
                    decoration: InputDecoration(
                      hintText: 'Enter email address...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey.shade500,
                      ),
                      suffixIcon:
                          chatController.emailSearchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  chatController.emailSearchController.clear();
                                  chatController.searchResults.clear();
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        chatController.isSearching.value
                            ? null
                            : () {
                              if (chatController.emailSearchController.text
                                  .trim()
                                  .isNotEmpty) {
                                chatController.searchUserByEmail(
                                  chatController.emailSearchController.text
                                      .trim(),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child:
                        chatController.isSearching.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.search, size: 20),
                  ),
                ),
              ],
            ),

            // Search Results
            Obx(
              () =>
                  chatController.searchResults.isNotEmpty
                      ? Container(
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatController.searchResults.length,
                          separatorBuilder:
                              (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                          itemBuilder: (context, index) {
                            final user = chatController.searchResults[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    chatController.addUserToSelected(user);
                                  });
                                },

                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.blue.shade100,
                                        child:
                                            user.avatar != null
                                                ? CachedNetworkImage(
                                                  imageUrl: user.avatar!,
                                                  placeholder:
                                                      (context, url) => Text(
                                                        user.initials,
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade700,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Text(
                                                            user.initials,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .blue
                                                                      .shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                )
                                                : Text(
                                                  user.initials,
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user.email,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              user.userType == UserType.business
                                                  ? Colors.purple.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.green.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          user.userType == UserType.business
                                              ? 'Business'
                                              : 'Personal',
                                          style: TextStyle(
                                            color:
                                                user.userType ==
                                                        UserType.business
                                                    ? Colors.purple.shade700
                                                    : Colors.green.shade700,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedUsersList() {
    return Obx(
      () =>
          chatController.selectedUsers.isNotEmpty
              ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.people_rounded,
                                  color: Colors.orange.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recipients (${chatController.selectedUsers.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                chatController.clearSelectedUsers();
                              });
                            },
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chatController.selectedUsers.length,
                          itemBuilder: (context, index) {
                            final user = chatController.selectedUsers[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.blue.shade100,
                                          child:
                                              user.avatar != null
                                                  ? CachedNetworkImage(
                                                    imageUrl: user.avatar!,
                                                    placeholder:
                                                        (context, url) => Text(
                                                          user.initials,
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .blue
                                                                    .shade700,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Text(
                                                          user.initials,
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .blue
                                                                    .shade700,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                  )
                                                  : Text(
                                                    user.initials,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              chatController
                                                  .removeUserFromSelected(user);
                                            });
                                          },
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade500,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      user.fullName.split(' ').first,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildChatHistorySection() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: Colors.purple.shade600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recent Chats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: chatController.loadChatRooms,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Obx(
            () =>
                chatController.isLoadingChats.value
                    ? Container(
                      height: 200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.blue),
                            SizedBox(height: 16),
                            Text(
                              'Loading Users...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : chatController.chatRooms.isEmpty
                    ? Container(
                      height: 200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No chats yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Send your first video to start chatting',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        // Instruction text
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hold and tap to select recipients from recent chats',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Chat rooms list
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatController.chatRooms.length,
                          itemBuilder: (context, index) {
                            final chatRoom = chatController.chatRooms[index];
                            return _buildChatRoomTile(chatRoom);
                          },
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    final currentUserId = chatController.currentUser.value?.uid ?? '';
    final isSelected =
        chatController.selectedUsers
            .where(
              (user) =>
                  user.uid ==
                  chatRoom.participants.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => '',
                  ),
            )
            .isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChatRoom(chatRoom),
          onLongPress:
              () => _toggleChatUserSelection(
                chatRoom,
                chatRoom.participantDetails
                    .firstWhere((user) => user.uid != currentUserId)
                    .uid,
              ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            isSelected
                                ? Border.all(
                                  color: Colors.blue.shade300,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child:
                            chatRoom.getChatImage(currentUserId).isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: chatRoom.getChatImage(
                                    currentUserId,
                                  ),
                                  placeholder:
                                      (context, url) => Text(
                                        chatRoom
                                            .getChatName(currentUserId)
                                            .substring(0, 2)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Text(
                                        chatRoom
                                            .getChatName(currentUserId)
                                            .substring(0, 2)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                )
                                : Text(
                                  chatRoom
                                      .getChatName(currentUserId)
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),

                    // Selection checkmark
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),

                    // Unread count
                    if (chatRoom.getUnreadCount(currentUserId) > 0 &&
                        !isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chatRoom.getUnreadCount(currentUserId) > 99
                                ? '99+'
                                : chatRoom
                                    .getUnreadCount(currentUserId)
                                    .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatRoom.getChatName(currentUserId),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isSelected
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (chatRoom.lastMessageType ==
                              MessageType.video) ...[
                            Icon(
                              Icons.videocam_rounded,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              chatRoom.lastMessage ?? 'No messages yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chatRoom.lastMessageTime != null)
                      Text(
                        chatController.formatMessageTime(
                          chatRoom.lastMessageTime!,
                        ),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    if (chatRoom.getUnreadCount(currentUserId) > 0 &&
                        !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Toggles the selection state of a chat user in a chat room.
  ///
  /// If the user is currently selected, they are removed from the list
  /// of selected users and recipients. If the user is not selected,
  /// they are added to the list of selected users.
  ///
  /// Updates the chat controller and UI state after toggling.
  ///
  /// Parameters:
  /// - `chatRoom`: The chat room containing the user to be toggled.
  /// - `currentUserId`: The ID of the current user whose selection state is to be toggled.

  /*******  9f8fda53-408f-47da-b3af-7c0e679966b5  *******/
  void _toggleChatUserSelection(ChatRoom chatRoom, String currentUserId) {
    if (chatController.selectedUsers
        .where(
          (user) =>
              user.uid ==
              chatRoom.participants.firstWhere(
                (id) => id == currentUserId,
                orElse: () => '',
              ),
        )
        .isNotEmpty) {
      // Remove from selection and from recipients

      // Find and remove user from selected users
      final otherUserId = chatRoom.participants.firstWhere(
        (id) => id == currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty) {
        chatController.selectedUsers.removeWhere(
          (user) => user.uid == otherUserId,
        );
      }
    } else {
      // Add to selection

      var otherUsers = chatRoom.participantDetails.where(
        (user) => user.uid == currentUserId,
      );

      chatController.selectedUsers.addAll(otherUsers);

      // Add user to recipients (you'll need to implement this method in your controller)
      // _addChatUserToRecipients(chatRoom, currentUserId);
    }
    chatController.update();
    setState(() {});
  }

  // void _addChatUserToRecipients(ChatRoom chatRoom, String currentUserId) {
  //   // Get the other participant's ID
  //   final otherUserId = chatRoom.participants.firstWhere(
  //     (id) => id != currentUserId,
  //     orElse: () => '',
  //   );

  //   if (otherUserId.isNotEmpty) {
  //     // You'll need to implement a method in your controller to get user details by ID
  //     // and add them to selectedUsers
  //     chatController.addUserToSelectedById(
  //       otherUserId,
  //       chatRoom.getChatName(currentUserId),
  //     );
  //   }
  // }

  void _openChatRoom(ChatRoom chatRoom) {
    if (chatController.selectedUsers.isNotEmpty) {
      // If in selection mode, toggle selection instead of opening chat
      _toggleChatUserSelection(
        chatRoom,
        chatRoom.participants.firstWhere(
          (id) => id != chatController.currentUser.value?.uid,
          orElse: () => '',
        ),
      );
    } else {
      Get.to(() => ChatRoomScreen(chatRoom: chatRoom));
    }
  }

  Future<void> _sendVideoToSelectedUsers() async {
    if (chatController.selectedUsers.isEmpty) {
      chatController.showerrorSnackBar(
        'No Recipients',
        'Please select at least one user',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showSendConfirmationDialog();
    if (!confirmed) return;

    try {
      if (widget.videoUrl.startsWith('Failed') ||
          widget.videoUrl.startsWith('Error')) {
        throw Exception(widget.videoUrl);
      }

      // Send video to selected users
      await chatController.sendVideoToSelectedUsers(
        videoUrl: widget.videoUrl,
        description: descriptionController.text.trim(),
      );

      // Clear selections

      // Navigate back
      Get.back();
    } catch (e) {
      chatController.showerrorSnackBar(
        'Send Failed',
        'Failed to send video: $e',
      );
    }
  }

  Future<bool> _showSendConfirmationDialog() async {
    return await Get.dialog<bool>(
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.blue.shade600,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Send Video?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      'Send this video to ${chatController.selectedUsers.length} recipient${chatController.selectedUsers.length > 1 ? 's' : ''}?',
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }
}
