import 'package:intl/intl.dart';

class Utils {
  static String convertTo12Hour(DateTime timestamp) {
    DateFormat formatter = DateFormat('a h:mm'); //a 是 AM/PM，h:mm 是 12 小時制
    return formatter.format(timestamp);
  }

  static String dateConvert(DateTime timestamp) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    String displayDate;
    if (date == today) {
      displayDate = '今天';
    } else if (date == yesterday) {
      displayDate = '昨天';
    } else {
      displayDate = DateFormat('M/d').format(timestamp); // 例：6/8
    }

    return displayDate;
  }

  static String getLastMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final difference = today.difference(messageDay).inDays;

    final timeFormat = DateFormat('h:mm'); // 不要包含 AM/PM，自己處理
    final dateFormat = DateFormat('MM/dd');

    if (difference == 0) {
      // 今天
      final hour = timestamp.hour;

      String prefix;
      if (hour == 12 && timestamp.minute == 0) {
        prefix = '中午'; // 僅 12:00 顯示為「中午」
      } else if (hour >= 12) {
        prefix = '下午';
      } else {
        prefix = '上午';
      }

      String timeString = timeFormat.format(timestamp);
      return '$prefix $timeString';
    } else if (difference == 1) {
      return '昨天';
    } else {
      return dateFormat.format(timestamp);
    }
  }
}
