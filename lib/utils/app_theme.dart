import 'package:flutter/material.dart';

class AppTheme {
  // 主要顏色系列
  static const Color primaryColor = Color(0xFF2196F3); // 主色調：清新藍
  static const Color primaryLightColor = Color(0xFF64B5F6); // 淺藍
  static const Color primaryDarkColor = Color(0xFF1976D2); // 深藍
  static const Color accentColor = Color(0xFF03A9F4); // 次要色：天藍色

  // 背景色系列
  static const Color backgroundColor = Color(0xFFF5F5F5); // 淺灰背景
  static const Color cardColor = Colors.white; // 卡片背景
  static const Color inputBgColor = Color(0xFFF5F5F5); // 輸入框背景色
  static const Color surfaceColor = Color(0xFFE3F2FD); // 表面色：極淺藍

  // 文字顏色
  static const Color textPrimaryColor = Color(0xFF212121); // 主要文字
  static const Color textSecondaryColor = Color(0xFF757575); // 次要文字
  static const Color textLightColor = Color(0xFFBDBDBD); // 淺色文字
  static const Color textOnPrimaryColor = Colors.white; // 主色調上的文字

  // 功能色
  static const Color successColor = Color(0xFF4CAF50); // 成功綠
  static const Color errorColor = Color(0xFFf44336); // 錯誤紅
  static const Color warningColor = Color(0xFFFF9800); // 警告橙
  static const Color infoColor = Color(0xFF2196F3); // 信息藍

  // 登入頁面樣式
  static InputDecoration textFieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textLightColor),
      filled: true,
      fillColor: inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        color: errorColor,
        fontSize: 12,
      ),
    );
  }

  // 按鈕樣式
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textOnPrimaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );

  // 卡片樣式
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // 聊天氣泡樣式
  static BoxDecoration chatBubbleDecoration(bool isMe) {
    return BoxDecoration(
      color: isMe ? primaryColor : surfaceColor,
      borderRadius: BorderRadius.circular(20).copyWith(
        bottomRight: isMe ? const Radius.circular(0) : null,
        bottomLeft: !isMe ? const Radius.circular(0) : null,
      ),
    );
  }

  // 底部導航列樣式
  static const BottomNavigationBarThemeData bottomNavBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: cardColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: textLightColor,
    selectedLabelStyle: TextStyle(fontSize: 12),
    unselectedLabelStyle: TextStyle(fontSize: 12),
  );

  // AppBar 樣式
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: textOnPrimaryColor),
    titleTextStyle: TextStyle(
      color: textOnPrimaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
