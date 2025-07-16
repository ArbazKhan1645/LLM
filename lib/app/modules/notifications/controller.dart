// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MessagesTabControllerNotifications extends GetxController {}

class NotificationModel {
  final String receiverId;
  final String senderId;
  final String senderName;
  final String title;
  final String senderImage;
  final String bookingId;

  NotificationModel({
    required this.receiverId,
    required this.senderId,
    required this.bookingId,
    required this.senderName,
    required this.title,
    required this.senderImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'senderId': senderId,
      'bookingId': bookingId,
      'senderName': senderName,
      'title': title,
      'senderImage': senderImage,
    };
  }

  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      bookingId: data['bookingId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      title: data['title'] ?? '',
      senderImage: data['senderImage'] ?? '',
    );
  }
}

Future<void> uploadNotification(
    {required String receiverId,
    required String senderId,
    required String senderName,
    required String title,
    required String senderImage,
    required String bookingId}) async {
  CollectionReference notifications =
      FirebaseFirestore.instance.collection('notifications');

  DocumentReference newNotificationRef = notifications.doc();

  NotificationModel notification = NotificationModel(
    bookingId: bookingId,
    receiverId: receiverId,
    senderId: senderId,
    senderName: senderName,
    title: title,
    senderImage: senderImage,
  );

  await newNotificationRef.set(notification.toMap()).then((_) {
    print("Notification added with ID: ${newNotificationRef.id}");
  }).catchError((error) {
    print("Failed to add notification: $error");
  });
}
