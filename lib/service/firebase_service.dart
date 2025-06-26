import 'dart:io';
import 'package:chat_flutter/models/chat_user.dart';
import 'package:chat_flutter/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;

  //建立新用戶
  static Future<void> createNewUser(ChatUser newUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toJson());
    } catch (e) {
      print('建立新用戶失敗: $e');
      rethrow;
    }
  }

  /// 上傳用戶頭像，並回傳頭像的downloadURL
  static Future<String> uploadUserImage({
    required File imageFile,
    required bool isRegister,
  }) async {
    try {
      final ref = storage.ref().child('user_images').child('${user.uid}.jpg');

      final uploadTask = await ref.putFile(imageFile);

      final imageUrl = await uploadTask.ref.getDownloadURL();

      if (!isRegister) {
        await firestore.collection('users').doc(user.uid).update({
          'image_url': imageUrl,
        }).then((_) {
          me.imageUrl = imageUrl;
        });
      }

      return imageUrl;
    } catch (e) {
      print('上傳頭像失敗：$e');
      rethrow;
    }
  }

  static Future<bool> googleUserExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> createGoogleUser() async {
    final time = DateTime.now();
    final chatUser = ChatUser(
      uid: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? '',
      imageUrl: user.photoURL ?? '',
      friends: [],
      createdAt: time,
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //獲取當前用戶訊息(Stream)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() {
    return firestore.collection('users').doc(user.uid).snapshots();
  }

  //獲取當前用戶訊息(Future)
  static Future<void> getCurrentUserInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);

        await getFirebaseMessagingToken();

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          await firestore.collection('users').doc(me.uid).update({
            'fcm_token': newToken,
          });
          me.fcmToken = newToken;
        });
      }
    });
  }

  //取得Token，目前僅設置為登入單一設備
  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission(); //請求權限

    // iOS模擬器上略過獲取token步驟
    if (Platform.isIOS) {
      final apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        print('[警告]iOS模擬器不支援 APNs，略過 token 取得流程');
        return;
      }
    }

    final token = await messaging.getToken();
    if (token != null) {
      // 更新 Firestore
      await FirebaseFirestore.instance.collection('users').doc(me.uid).update({
        'fcm_token': token,
      });
      // 同步更新本地 me 物件
      me.fcmToken = token;
    }
  }

  static Future<void> updateCurrentUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'username': me.username,
    });
  }

  static Future<void> updateCurrentUserImageUrlInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'image_url': me.imageUrl,
    });
  }

  //取得聊天室ID
  static String getJoinedRoomId(String friendUid) {
    final roomId = [user.uid, friendUid]..sort(); // 字串排序
    final joinedRoomId = roomId.join('_');
    return joinedRoomId;
  }

  //取得聊天室(joinedRoomId)訊息，Collection > Document(joinedRoomId) > Subcollection
  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessage(
      String friendUid) {
    String joinedRoomId = getJoinedRoomId(friendUid);

    return firestore
        .collection('rooms')
        .doc(joinedRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) //依時間排序
        .snapshots();
  }

  //發送訊息
  static Future<void> sendMessage(
      String friendUid, String enteredMessage) async {
    String joinedRoomId = getJoinedRoomId(friendUid);

    Message message = Message(
      message: enteredMessage,
      timestamp: DateTime.now(),
      userId: me.uid,
      userImage: me.imageUrl,
      username: me.username,
    );

    await firestore
        .collection('rooms')
        .doc(joinedRoomId)
        .collection('messages')
        .add(message.toJson());
  }

  //訊息更新為已讀，(有優化需求，待處理效能浪費與資料競爭問題)
  static Future<void> updateMessageReadStatus(Message chatMessage) async {
    String joinedRoomId = getJoinedRoomId(chatMessage.userId);

    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(joinedRoomId)
        .collection('messages')
        .where('userId', isEqualTo: chatMessage.userId) // 好友的userId
        .where('read', isEqualTo: false) // 可選：只更新未讀訊息
        .limit(20) //限制一次只拉20筆出來更新read：true
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  //取得聊天室中最後一筆訊息
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    String joinedRoomId = getJoinedRoomId(chatUser.uid);

    return firestore
        .collection('rooms')
        .doc(joinedRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) //依時間排序
        .limit(1) //只取一筆
        .snapshots();
  }

  // 取得聊天室中未讀訊息
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadMessages(
      ChatUser chatUser) {
    String joinedRoomId = getJoinedRoomId(chatUser.uid);

    return firestore
        .collection('rooms')
        .doc(joinedRoomId)
        .collection('messages')
        .where('read', isEqualTo: false) // 只取未讀訊息
        .orderBy('timestamp', descending: true) // 依時間排序（可選）
        .snapshots();
  }

  //加入好友
  static Future<void> addFriend(ChatUser newFriend) async {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('users').doc(me.uid);

    await currentUserDoc.update({
      'friends': FieldValue.arrayUnion([newFriend.uid])
    });
  }
}
