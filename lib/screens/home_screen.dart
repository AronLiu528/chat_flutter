import 'package:chat_flutter/components/user_card.dart';
import 'package:chat_flutter/screens/chat_screen.dart';
import 'package:chat_flutter/screens/loading_screen.dart';
import 'package:chat_flutter/screens/setting_screen.dart';
import 'package:chat_flutter/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/bottom_sheet/add_friend.dart';
import '../models/chat_user.dart';
import '../service/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChatUser currentUser;
  List<ChatUser> friendsList = [];
  List<ChatUser> searchList = [];
  bool isSearching = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseService.getCurrentUserInfo();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => AddFriendBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBarWidget(context),
      body: Column(
        children: [
          _searchBarWidget(),
          Expanded(
            child: _friendListWidget(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        '好友',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.person_add_alt_outlined,
            color: Colors.black,
          ),
          onPressed: _showBottomSheet,
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingScreen(user: currentUser),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _searchBarWidget() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.inputBgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: _controller,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: Colors.grey,
          hintText: '搜尋',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: isSearching
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      isSearching = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onChanged: (value) {
          searchList.clear();
          //關鍵詞為搜尋username && mail
          for (var i in friendsList) {
            if (i.username.toLowerCase().contains(value.toLowerCase()) ||
                i.email.toLowerCase().contains(value.toLowerCase())) {
              searchList.add(i);
            }
            setState(() {
              isSearching = true;
            });
          }
        },
      ),
    );
  }

  Widget _friendListWidget() {
    return StreamBuilder(
      stream: FirebaseService.getCurrentUser(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (!snapshots.hasData) {
          return const SizedBox.shrink();
        }
        final data = snapshots.data!.data()!;
        currentUser = ChatUser.fromJson(data);

        List<String> uidFriendsList = currentUser.friends; //取好友清單

        return FutureBuilder<List<ChatUser>>(
          future: fetchFriendsData(uidFriendsList),
          builder: (context, friendSnapshot) {
            if (friendSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }
            if (!friendSnapshot.hasData || friendSnapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            friendsList = friendSnapshot.data!;

            return ListView.builder(
              itemCount: isSearching ? searchList.length : friendsList.length,
              itemBuilder: (context, index) {
                ChatUser friendUser =
                    isSearching ? searchList[index] : friendsList[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(friendUser: friendUser),
                      ),
                    );
                  },
                  child: UserCard(friendUser: friendUser),
                );
              },
            );
          },
        );

        //-----------------

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   // 避免每次 build 都觸發
        //   if (getfriendsList.isEmpty) {
        //     getFriends(friendsList);
        //   }
        // });

        // // await searchList = fetchFriendsData(friendsList);
        // print('friends = $getfriendsList');

        // return ListView.builder(
        //   padding: const EdgeInsets.symmetric(horizontal: 5),
        //   itemCount: getfriendsList.length,
        //   itemBuilder: (context, index) {
        //     ChatUser friendUser = getfriendsList[index];

        //     return GestureDetector(
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => ChatScreen(
        //               friendUser: friendUser,
        //             ),
        //           ),
        //         );
        //       },
        //       child: UserCard(friendUser: friendUser),
        //     );
        //   },
        // );
        //-----------------
        // return friendsList.isEmpty
        //     ? const SizedBox.shrink()
        //     : ListView.builder(
        //         padding: const EdgeInsets.symmetric(horizontal: 5),
        //         itemCount: friendsList.length,
        //         itemBuilder: (context, index) {
        //           String friendUid = friendsList[index];

        //           return StreamBuilder(
        //             stream: FirebaseFirestore.instance
        //                 .collection('users')
        //                 .doc(friendUid)
        //                 .snapshots(),
        //             builder: (context, snapshot) {
        //               if (!snapshot.hasData) {
        //                 return const SizedBox.shrink();
        //               }

        //               Map<String, dynamic> friendData = snapshot.data!.data()!;
        //               ChatUser friendUser = ChatUser.fromJson(friendData);

        //               return GestureDetector(
        //                 onTap: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => ChatScreen(
        //                         friendUser: friendUser,
        //                       ),
        //                     ),
        //                   );
        //                 },
        //                 child: UserCard(friendUser: friendUser),
        //               );
        //             },
        //           );
        //         },
        //       );
      },
    );
  }

  // Future<List<ChatUser>> fetchFriendsData(List<String> friendsList) async {
  //   List<ChatUser> chatUsers = [];

  //   // Firestore 允許一次最多查詢 10 筆 document
  //   // 所以若超過 10 筆，建議分批查詢
  //   const chunkSize = 10;

  //   for (var i = 0; i < friendsList.length; i += chunkSize) {
  //     final chunk = friendsList.sublist(
  //       i,
  //       i + chunkSize > friendsList.length ? friendsList.length : i + chunkSize,
  //     );

  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where(FieldPath.documentId, whereIn: chunk)
  //         .get();

  //     for (var doc in snapshot.docs) {
  //       chatUsers.add(ChatUser.fromJson(doc.data()));
  //     }
  //   }

  //   return chatUsers;
  // }

  Future<List<ChatUser>> fetchFriendsData(List<String> friendsList) async {
    final futures = friendsList.map((uid) async {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          return ChatUser.fromJson(doc.data()!);
        }
      } catch (e) {
        debugPrint('讀取 $uid 發生錯誤: $e');
      }
      return null;
    }).toList();

    final results = await Future.wait(futures);
    return results.whereType<ChatUser>().toList();
  }
}
