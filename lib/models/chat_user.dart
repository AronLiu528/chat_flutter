import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  String uid;
  String email;
  String username;
  String imageUrl;
  List<String> friends;
  DateTime createdAt;
  String? fcmToken;

  ChatUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.imageUrl,
    required this.createdAt,
    this.fcmToken,
    List<String>? friends, // 註冊時無設置會自動提供空陣列
  }) : friends = friends ?? [];

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      fcmToken: json['fcm_token'] as String?,
      friends:
          (json['friends'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'friends': friends,
      'fcm_token': fcmToken,
      // if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }
}
