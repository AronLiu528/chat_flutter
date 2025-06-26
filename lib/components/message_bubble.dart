import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_flutter/service/firebase_service.dart';
import 'package:chat_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.nextUserIsSame,
    required this.friendData,
    required this.chatMessage,
  });

  final bool isMe;
  final bool nextUserIsSame;
  final ChatUser friendData;
  final Message chatMessage;

  @override
  Widget build(BuildContext context) {
    return isMe ? _myMessageBubble(context) : _friendMessageBubble(context);
  }

  Widget _myMessageBubble(BuildContext contex) {
    String time = Utils.convertTo12Hour(chatMessage.timestamp);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chatMessage.read)
              const Text(
                '已讀',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Flexible(
          child: Bubble(
            margin: const BubbleEdges.only(top: 15),
            padding: const BubbleEdges.symmetric(horizontal: 15, vertical: 6),
            nip: BubbleNip.rightTop,
            color: const Color.fromRGBO(225, 255, 199, 1),
            child: Text(
              chatMessage.message,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _friendMessageBubble(BuildContext context) {
    String time = Utils.convertTo12Hour(chatMessage.timestamp);
    var mq = MediaQuery.of(context).size;

    if (chatMessage.read == false) {
      FirebaseService.updateMessageReadStatus(chatMessage);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!nextUserIsSame)
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.1),
            child: CachedNetworkImage(
              width: mq.height * 0.05,
              height: mq.height * 0.05,
              fit: BoxFit.cover,
              imageUrl: friendData.imageUrl,
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
        if (nextUserIsSame)
          const SizedBox(width: 50), //寬度須配合CircleAvatar().radius*2+泡泡角標
        Flexible(
          child: Bubble(
            margin: const BubbleEdges.only(top: 15, left: 5),
            padding: const BubbleEdges.symmetric(horizontal: 15, vertical: 6),
            nip: nextUserIsSame ? BubbleNip.no : BubbleNip.leftTop,
            color: Colors.grey.shade100,
            child: Text(
              chatMessage.message,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        if (nextUserIsSame) const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

// import 'package:bubble/bubble.dart';
// import 'package:flutter/material.dart';

// class MessageBubble extends StatelessWidget {
//   const MessageBubble.first({
//     super.key,
//     required this.userImage,
//     required this.username,
//     required this.message,
//     required this.isMe,
//   }) : isFirstInSequence = true;

//   const MessageBubble.next({
//     super.key,
//     required this.message,
//     required this.isMe,
//   })  : isFirstInSequence = false,
//         userImage = null,
//         username = null;

//   final bool isFirstInSequence;
//   final String? userImage;
//   final String? username;
//   final String message;
//   final bool isMe;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         if (userImage != null && !isMe)
//           CircleAvatar(
//             backgroundImage: NetworkImage(
//               userImage!,
//             ),
//             backgroundColor: theme.colorScheme.primary.withAlpha(180),
//             radius: 23,
//           ),
//         if (!isFirstInSequence)
//           const SizedBox(width: 46), //須配合CircleAvatar().radius*2
//         Bubble(
//           margin: BubbleEdges.only(
//             top: 10,
//             left: isMe ? 0 : 10,
//           ),
//           padding: const BubbleEdges.symmetric(horizontal: 10, vertical: 6),
//           nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
//           color: isMe
//               ? const Color.fromRGBO(225, 255, 199, 1.0)
//               : Colors.grey.shade300,
//           child: Text(
//             message,
//             style: const TextStyle(fontSize: 18),
//           ),
//         ),
//       ],
//     );
//   }
// }

