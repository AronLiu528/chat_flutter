import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final DateTime timestamp;
  final String userId;
  final String userImage;
  final String username;
  final bool read;

  Message({
    required this.message,
    required this.timestamp,
    required this.userId,
    required this.userImage,
    required this.username,
    this.read = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: json['userId'] ?? '',
      userImage: json['userImage'] ?? '',
      username: json['username'] ?? '',
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'userImage': userImage,
      'username': username,
      'read': read,
    };
  }
}
