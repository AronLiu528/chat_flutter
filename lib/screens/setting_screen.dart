import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_flutter/models/chat_user.dart';
import 'package:chat_flutter/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../components/dialogs.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    super.key,
    this.user,
  });

  final ChatUser? user;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _imageUrl;
  late String _email;
  bool _isEditing = false;
  String? image;

  @override
  Widget build(BuildContext context) {
    _username = FirebaseService.me.username;
    _imageUrl = FirebaseService.me.imageUrl;
    _email = FirebaseService.me.email;
    var mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, //Color(0xFF2EC4B6),//Color(0xFF03B5AA)
          centerTitle: true,
          title: const Text(
            '個人檔案',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: mq.height * 0.05, width: mq.width),
                  _avatarWidget(context),
                  SizedBox(height: mq.height * 0.1),
                  _userInfoCard(),
                  SizedBox(height: mq.width * 0.3),
                  _logoutButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarWidget(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Stack(
      children: [
        image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.1),
                child: Image.file(
                  File(image!),
                  width: mq.height * 0.2,
                  height: mq.height * 0.2,
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.1),
                child: Image.network(
                  _imageUrl,
                  width: mq.height * 0.2,
                  height: mq.height * 0.2,
                  fit: BoxFit.cover,
                ),
                // CachedNetworkImage(
                //   width: mq.height * 0.2,
                //   height: mq.height * 0.2,
                //   fit: BoxFit.cover,
                //   imageUrl: _imageUrl,
                //   errorWidget: (context, url, error) => const CircleAvatar(
                //     child: Icon(Icons.person),
                //   ),
                // ),
              ),
        Positioned(
          bottom: 0,
          right: 0,
          child: MaterialButton(
            onPressed: () {
              _showBottomSheet(context);
            },
            elevation: 1,
            shape: const CircleBorder(),
            color: Colors.white,
            child: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }

  Widget _userInfoCard() {
    return Card(
      color: Colors.white,
      // shadowColor: Colors.blueAccent,
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text(_username),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}, // 可選點擊功能
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.mail),
              title: Text(_email),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}, // 可選點擊功能
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('******'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}, // 可選點擊功能
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return ElevatedButton.icon(
      onPressed: () {
        FirebaseService.auth.signOut();
        GoogleSignIn().signOut();
        Navigator.pop(context);
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        '登出',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // 紅色背景
        minimumSize: Size(mq.width * 0.9, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 圓角
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    ImagePicker imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Center(
                      child: Text(
                        '開啟相機',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final pickedImage = await imagePicker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 50,
                        maxWidth: 150,
                      );

                      if (pickedImage == null) {
                        return;
                      }
                      FirebaseService.uploadUserImage(
                        imageFile: File(pickedImage.path),
                        isRegister: false,
                      );

                      setState(() {
                        image = pickedImage.path;
                      });
                      Dialogs.showSnackBar(context, '頭像已更新');
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Center(
                      child: Text(
                        '選擇照片',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final pickedImage = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 50,
                        maxWidth: 150,
                      );

                      if (pickedImage == null) {
                        return;
                      }

                      FirebaseService.uploadUserImage(
                        imageFile: File(pickedImage.path),
                        isRegister: false,
                      );

                      setState(() {
                        image = pickedImage.path;
                      });
                      Dialogs.showSnackBar(context, '頭像已更新');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: const Center(
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
