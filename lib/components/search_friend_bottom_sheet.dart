import 'package:chat_flutter/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/chat_user.dart';
import '../service/firebase_service.dart';

class SearchFriendBottomSheet extends StatefulWidget {
  const SearchFriendBottomSheet({super.key});

  @override
  State<SearchFriendBottomSheet> createState() =>
      _SearchFriendBottomSheetState();
}

class _SearchFriendBottomSheetState extends State<SearchFriendBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _errorMessage;
  ChatUser? _foundUser;
  String _searchType = 'id'; // 預設搜尋模式

  Future<void> _searchUser(String query) async {
    setState(() {
      _foundUser = null;
      _errorMessage = null;
    });

    try {
      if (_searchType == 'email') {
        final result = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: query)
            .get();

        if (result.docs.isNotEmpty) {
          setState(() {
            _foundUser = ChatUser.fromJson(result.docs.first.data());
          });
        } else {
          setState(() => _errorMessage = '找不到使用者');
        }
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(query)
            .get();

        if (doc.exists) {
          setState(() {
            _foundUser = ChatUser.fromJson(doc.data()!);
          });
        } else {
          setState(() => _errorMessage = '找不到使用者');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = '搜尋失敗：$e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Radio 選項：搜尋模式
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: RadioListTile(
                    value: 'id',
                    groupValue: _searchType,
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('ID'),
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                        _searchController.clear();
                        _foundUser = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: RadioListTile(
                    value: 'email',
                    activeColor: AppTheme.primaryColor,
                    groupValue: _searchType,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Email'),
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                        _searchController.clear();
                        _foundUser = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 搜尋欄位
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.inputBgColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _searchController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                keyboardType: _searchType == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: Colors.grey,
                  hintText: _searchType == 'email' ? '請輸入 Email' : '請輸入用戶 ID',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _foundUser = null;
                              _errorMessage = null;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _searchUser(value.trim());
                  }
                },
              ),
            ),
            // 錯誤訊息
            if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                ),
              ),
            // 搜尋結果
            if (_foundUser != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(_foundUser!.imageUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _foundUser!.username,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: AppTheme.elevatedButtonStyle,
                      onPressed: () {
                        if (_foundUser != null) {
                          FirebaseService.addFriend(_foundUser!);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '加入',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
