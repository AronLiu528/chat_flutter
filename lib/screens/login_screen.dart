import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_flutter/components/dialogs.dart';
import 'package:chat_flutter/components/user_image_picker.dart';
import 'package:chat_flutter/models/chat_user.dart';
import 'package:chat_flutter/service/firebase_service.dart';
import 'package:chat_flutter/utils/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';
  File? _selectedImage;

  void _submit() async {
    bool isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      //show error message
      return;
    }
    _form.currentState!.save();

    try {
      Dialogs.showProgressBar(context);
      if (_isLogin) {
        //登入邏輯
        await FirebaseService.auth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        //註冊邏輯
        final userCredentials = await FirebaseService.auth
            .createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);

        String imageUrl = await FirebaseService.uploadUserImage(
          imageFile: _selectedImage!,
          isRegister: true,
        );

        DateTime createdAt = DateTime.now();

        ChatUser newUser = ChatUser(
          uid: userCredentials.user!.uid,
          email: _enteredEmail,
          username: _enteredUsername,
          imageUrl: imageUrl,
          createdAt: createdAt,
        );
        //建立新用戶
        await FirebaseService.createNewUser(newUser);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('註冊失敗:$e');
      if (e.code == 'email-already-in-use') {
        //...郵件已有人使用
      }
      Dialogs.showSnackBar(context, e.message ?? '驗證失敗');
    }
    Navigator.pop(context); //關閉ProgressBar
  }

  void _googleSignIn() {
    _signInWithGoogle().then((user) {
      if (user != null) {
        debugPrint('Google用戶資訊1:${user.user}');
        debugPrint('Google用戶資訊2:${user.additionalUserInfo}');
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // 檢查裝置是否可以連網
      await InternetAddress.lookup('google.com');
      // 觸發身份驗證流程
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // 從請求中獲取授權詳細信息
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      // 建立新憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      if (await FirebaseService.googleUserExists()) {
        debugPrint('google用戶已存在');
      }
      // else {
      //   FirebaseService.createGoogleUser();
      // }
      // 登入後，返回 UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('google登入失敗:$e');
      Dialogs.showSnackBar(context, 'Goolge帳戶登入失敗');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
                width: 400,
                child: Image.asset('assets/icons/app_icon.png'),
              ),
              // const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: AppTheme.textFieldDecoration(
                            hintText: '帳號/信箱',
                          ).copyWith(
                            prefixIcon: const Icon(
                              Icons.email,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return '請輸入有效的 email 地址';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (!_isLogin) ...[
                          TextFormField(
                            decoration: AppTheme.textFieldDecoration(
                              hintText: '使用者名稱',
                            ).copyWith(
                              prefixIcon: const Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 2) {
                                return '用戶名至少需要2個字元';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          decoration: AppTheme.textFieldDecoration(
                            hintText: '密碼',
                          ).copyWith(
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 6) {
                              return '密碼長度至少需要6個字元';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: AppTheme.elevatedButtonStyle,
                            onPressed: _submit,
                            child: Text(
                              _isLogin ? '登入' : '註冊',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? '建立新帳號' : '已有帳號？登入',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_isLogin) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppTheme.textLightColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '或',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppTheme.textLightColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            icon: Image.asset(
                              'assets/icons/google.png',
                              height: 24,
                            ),
                            label: const Text(
                              '使用 Google 帳號登入',
                              style: TextStyle(
                                color: AppTheme.textPrimaryColor,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              side: const BorderSide(
                                color: AppTheme.textLightColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _googleSignIn,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
