// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/chat_room/controllers/chat_room_controller.dart';
import 'package:llm_video_shopify/app/modules/chat_room/views/chat_room_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatRoomHistoryScreen extends StatefulWidget {
  const ChatRoomHistoryScreen({super.key});

  @override
  _ChatRoomHistoryScreenState createState() => _ChatRoomHistoryScreenState();
}

class _ChatRoomHistoryScreenState extends State<ChatRoomHistoryScreen> {
  final ChatRoomController chatController = Get.put(ChatRoomController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,

        title: const Text(
          'Send history',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Chat History Section
            _buildChatHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistorySection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Chats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: chatController.loadChatRooms,
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                ),
              ],
            ),
          ),

          Obx(
            () =>
                chatController.isLoadingChats.value
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Loading chats...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : chatController.chatRooms.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No chats yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Send your first video to start chatting',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: chatController.chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatController.chatRooms[index];
                        return _buildChatRoomTile(chatRoom);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    final currentUserId = chatController.currentUser.value?.uid ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              child:
                  chatRoom.getChatImage(currentUserId).isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: chatRoom.getChatImage(currentUserId),
                        placeholder:
                            (context, url) => Text(
                              chatRoom
                                  .getChatName(currentUserId)
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
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
                        ),
                      ),
            ),
            if (chatRoom.getUnreadCount(currentUserId) > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chatRoom.getUnreadCount(currentUserId) > 99
                        ? '99+'
                        : chatRoom.getUnreadCount(currentUserId).toString(),
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
        title: Text(
          chatRoom.getChatName(currentUserId),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (chatRoom.lastMessageType == MessageType.video)
              Icon(Icons.videocam, size: 16, color: Colors.grey.shade600),
            if (chatRoom.lastMessageType == MessageType.video)
              const SizedBox(width: 4),
            Expanded(
              child: Text(
                chatRoom.lastMessage ?? 'No messages yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatRoom.lastMessageTime != null
                  ? chatController.formatMessageTime(chatRoom.lastMessageTime!)
                  : '',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            if (chatRoom.getUnreadCount(currentUserId) > 0)
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
        onTap: () => _openChatRoom(chatRoom),
      ),
    );
  }

  void _openChatRoom(ChatRoom chatRoom) {
    Get.to(() => ChatRoomScreen(chatRoom: chatRoom));
  }
}
