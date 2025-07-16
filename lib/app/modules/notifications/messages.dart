import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:llm_video_shopify/app/modules/notifications/controller.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessagesTabController messagesTabController = Get.put(
    MessagesTabController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [_tabBarViews()]),
      ),
    );
  }

  Widget _tabBarViews() {
    return GetBuilder<MessagesTabController>(
      init: MessagesTabController(),
      builder: (controller) {
        return [const Messages()][0];
      },
    );
  }
}

Stream<List<NotificationModel>> getNotificationsForCurrentUser() {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('receiverId', isEqualTo: currentUserId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc.data()))
                .toList(),
      );
}

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<NotificationModel>>(
        stream: getNotificationsForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final message = notifications[index];
              return MessageTile(
                bookingID: message.senderImage,
                title: message.senderName,
                message: message.title,
                date: message.title,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String title;
  final String message;
  final String date;
  final bool isRead;
  final String bookingID;
  final VoidCallback onTap;

  const MessageTile({
    super.key,
    required this.title,
    required this.message,
    required this.bookingID,
    required this.date,
    this.isRead = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        height: 106,
        decoration: BoxDecoration(
          color: !isRead ? Colors.white : const Color(0xffF8F9FA),
          border: Border.all(
            color: !isRead ? Colors.transparent : const Color(0xffDDE2E5),
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            !isRead
                ? BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
                : const BoxShadow(color: Colors.transparent),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(bookingID),
                        ),
                        10.horizontalSpace,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                10.horizontalSpace,
                                !isRead
                                    ? Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 20,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffDEFFDD),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Unread',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    : Container(),
                              ],
                            ),
                            5.verticalSpace,
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesTabController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  RxInt get currentIndex => _currentIndex;

  set setCurrentIndex(int val) {
    _currentIndex.value = val;
    update();
  }
}
