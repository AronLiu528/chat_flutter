import 'package:chat_flutter/components/date_bubble.dart';
import 'package:chat_flutter/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_flutter/models/chat_user.dart';
import '../models/message.dart';
import 'message_bubble.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.friendData,
  });

  final ChatUser friendData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.getChatMessage(friendData.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.docs;
        List<Message> messageList =
            data.map((doc) => Message.fromJson(doc.data())).toList();

        return ListView.builder(
          padding: const EdgeInsets.only(left: 5, right: 7, bottom: 10),
          reverse: true,
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            Message chatMessage = messageList[index];
            //取得下則訊息數據
            Message? nextChatMessgae =
                index + 1 < messageList.length ? messageList[index + 1] : null;

            String currentMessageUserID = chatMessage.userId;
            String nextMessageUserID = //取得下則訊息的用戶ID
                nextChatMessgae != null ? nextChatMessgae.userId : '';
            bool nextUserIsSame =
                nextMessageUserID == currentMessageUserID; //比對下則訊息是否為為同一用戶

            bool isMe = currentMessageUserID == FirebaseService.me.uid;
            //檢查跨日訊息
            DateTime? nextMessageTime =
                index + 1 < messageList.length //取得下則訊息數據
                    ? messageList[index + 1].timestamp
                    : null;
            DateTime? currentMessageTime = chatMessage.timestamp;

            bool isNextDay = nextMessageTime == null ||
                !isSameDay(currentMessageTime, nextMessageTime);

            return isNextDay
                ? Column(
                    children: [
                      DateBubble(timestamp: chatMessage.timestamp),
                      MessageBubble(
                        chatMessage: chatMessage,
                        isMe: isMe,
                        nextUserIsSame: nextUserIsSame,
                        friendData: friendData,
                      ),
                    ],
                  )
                : MessageBubble(
                    chatMessage: chatMessage,
                    isMe: isMe,
                    nextUserIsSame: nextUserIsSame,
                    friendData: friendData,
                  );
          },
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
