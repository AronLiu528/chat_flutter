import 'package:chat_flutter/models/chat_user.dart';
import 'package:chat_flutter/service/firebase_service.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({
    super.key,
    required this.friendData,
    required this.bottomPadding,
  });
  final ChatUser friendData;
  final double bottomPadding;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() async {
    final String enteredMessage = _textController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    //發送訊息至firebase
    FirebaseService.sendMessage(
      widget.friendData.uid,
      enteredMessage,
    );
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText: '輸入訊息...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _textController.text = value;
                  });
                },
              ),
            ),
          ),
          if (_textController.text.isNotEmpty)
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(
                Icons.send,
                color: Colors.blue,
              ),
              onPressed: _sendMessage,
            ),
        ],
      ),
    );
  }
}
