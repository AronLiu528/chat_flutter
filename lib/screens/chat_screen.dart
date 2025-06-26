import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_flutter/components/chat_message.dart';
import 'package:chat_flutter/models/chat_user.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../service/firebase_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.friendUser});

  final ChatUser friendUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _showEmoji = false;

  void _sendMessage() async {
    final String enteredMessage = _textController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    //發送訊息至firebase
    FirebaseService.sendMessage(
      widget.friendUser.uid,
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 248, 255),
      appBar: AppBar(
        backgroundColor: Colors.white, //Color(0xFF2EC4B6),//Color(0xFF03B5AA)
        centerTitle: false,
        title: Text(
          widget.friendUser.username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: ChatMessage(friendData: widget.friendUser),
            ),
            // NewMessage(
            //   friendData: widget.friendUser,
            //   bottomPadding: MediaQuery.of(context).padding.bottom,
            // ),
            chatInputWidget(),
            if (!_showEmoji)
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).padding.bottom,
              ),
            Offstage(
              offstage: !_showEmoji,
              child: EmojiPicker(
                textEditingController: _textController,
                config: Config(
                  height: 260,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    columns: 8,
                    emojiSizeMax: 30 * (Platform.isIOS ? 1.2 : 1.0),
                  ),
                  bottomActionBarConfig:
                      const BottomActionBarConfig(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatInputWidget() {
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
      // padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.camera_alt_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.image_outlined),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                onTap: () {
                  setState(() {
                    _showEmoji = false;
                  });
                },
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: '輸入訊息...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    onPressed: () {
                      // FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                  ),
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
