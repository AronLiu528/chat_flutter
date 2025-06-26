# Chat Flutter - 即時聊天應用程式

一個使用 Flutter 和 Firebase 開發的現代化即時聊天應用程式，支援好友管理、即時訊息傳送和接收功能。

## 📱 功能特色

### 🔐 用戶認證
- Google 登入整合
- 安全的用戶身份驗證

### 👥 好友管理
- 搜尋並新增好友
- 好友列表管理
- 即時好友狀態更新

### 💬 即時聊天
- 即時訊息傳送和接收
- 訊息氣泡設計
- 訊息已讀／未讀顯示
- 時間戳記顯示

### 🎨 現代化 UI
- Material Design 3
- 清新藍色主題
- 響應式佈局
- 流暢的動畫效果

## 🛠 技術架構

### 前端技術
- **Flutter 3.x** - 跨平台 UI 框架
- **Dart** - 程式語言

### 後端服務
- **Firebase Authentication** - 用戶認證
- **Cloud Firestore** - 即時資料庫
- **Firebase_storage** - 用戶資料儲存

## 📁 專案結構

```
lib/
├── components/           # UI 元件
│   ├── bottom_sheet/
│   ├── chat_message.dart
│   ├── message_bubble.dart
│   ├── user_card.dart
│   └── ...
├── models/              # 資料模型
│   ├── chat_user.dart
│   └── message.dart
├── screens/             # 頁面
│   ├── chat_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── ...
├── service/             # 服務層
│   ├── firebase_service.dart
│   └── notification_service.dart
├── utils/               # 工具類
│   ├── app_theme.dart
│   └── utils.dart
└── main.dart           # 應用程式入口
```

## 🎨 UI 主題

應用程式採用清新藍色主題：

- **主色調**: #2196F3 (清新藍)
- **次要色**: #03A9F4 (天藍色)
- **背景色**: #F5F5F5 (淺灰色)
- **文字色**: #212121 (深灰色)

## 📞 聯絡資訊
- 專案維護者: [Aron Liu]
- Email: [aron.liu0528@gmail.com]

## 🙏 致謝

- Flutter 團隊提供的優秀框架
- Firebase 團隊提供的後端服務
- 所有貢獻者的付出

---

⭐ 如果這個專案對你有幫助，請給我們一個星標！
