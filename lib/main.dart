import 'package:chat_flutter/service/firebase_service.dart';
import 'package:chat_flutter/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_flutter/screens/home_screen.dart';
import 'package:chat_flutter/screens/loading_screen.dart';
import 'package:chat_flutter/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  // NotificationService.initNotificationChannel();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'chat_flutter',
      home: StreamBuilder(
        stream: FirebaseService.auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
