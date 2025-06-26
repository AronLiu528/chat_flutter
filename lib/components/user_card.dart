import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_flutter/models/chat_user.dart';
import '../models/message.dart';
import '../service/firebase_service.dart';
import '../utils/utils.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.friendUser});

  final ChatUser friendUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      // color: Colors.white,
      // elevation: 0.5,
      child: StreamBuilder(
        stream: FirebaseService.getLastMessage(friendUser),
        builder: (context, snapshot) {
          Message? message;
          String lastMessageText = '';
          String lastMessageTime = '';
          var mq = MediaQuery.of(context).size;
          double imageSize = mq.width * 0.14;
          bool isMe = false;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final doc = snapshot.data!.docs.first;
            message = Message.fromJson(doc.data());
            lastMessageText = message.message;
            // debugPrint('time:${message.timestamp}');
            lastMessageTime = Utils.getLastMessageTime(message.timestamp);
            isMe = message.userId == FirebaseService.me.uid;
          }
          return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(imageSize / 2),
                child: CachedNetworkImage(
                  width: imageSize,
                  height: imageSize,
                  imageUrl: friendUser.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              title: Text(
                friendUser.username,
                maxLines: 1,
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                lastMessageText,
                maxLines: 1,
              ),
              // trailing: Text(
              //   lastMessageTime,
              //   style: const TextStyle(color: Colors.black45),
              // ),
              trailing: message == null
                  ? null
                  : Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(lastMessageTime),
                        const SizedBox(height: 8),
                        if (!message.read && !isMe)
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                      ],
                    ));
        },
      ),
    );
  }
}
