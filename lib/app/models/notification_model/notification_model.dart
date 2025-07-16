
// Notification Model
class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String title;
  final String body;
  final String avatar;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.title,
    required this.body,
    required this.avatar,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'avatar': avatar,
      'type': type,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      avatar: map['avatar'] ?? '',
      type: map['type'] ?? '',
      data: map['data'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }
}