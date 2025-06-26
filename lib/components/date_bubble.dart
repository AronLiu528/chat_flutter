import 'package:bubble/bubble.dart';
import 'package:chat_flutter/utils/utils.dart';
import 'package:flutter/material.dart';

class DateBubble extends StatelessWidget {
  const DateBubble({
    super.key,
    required this.timestamp,
  });

  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    String date = Utils.dateConvert(timestamp);

    return Bubble(
      radius: const Radius.circular(10),
      margin: const BubbleEdges.only(top: 15),
      padding: const BubbleEdges.symmetric(horizontal: 10, vertical: 3),
      nip: BubbleNip.no,
      color: Colors.grey.shade400,
      child: Text(
        date,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
