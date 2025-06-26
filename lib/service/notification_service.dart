import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

class NotificationService {
  static Future<void> initNotificationChannel() async {
    var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'Notification',
      id: 'chat_flutter',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'chat_flutter',
    );
    print('NotificationChannel:$result');
  }
}
