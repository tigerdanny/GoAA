# 🚀 GoAA Flutter 快速啟動指南

## 📋 環境要求

### 必要軟體
- ✅ Flutter SDK 3.32.0+ (`C:\flutter\bin`)
- ✅ Cursor IDE
- ✅ Android Studio / VS Code (可選)
- ✅ Git

### 路徑配置
確保在Cursor中設置正確的Flutter路徑：
```json
{
  "dart.flutterSdkPath": "C:\\flutter\\bin"
}
```

## 🛠️ 專案設置

### 1. 進入Flutter專案目錄
```bash
cd C:\WinAp\Cursor\android\GoAA\goaa_flutter
```

### 2. 安裝依賴
```bash
flutter pub get
```

### 3. 檢查專案狀態
```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter doctor
```

### 4. 運行應用 (可選設備)

#### Web版本 (推薦快速預覽)
```bash
flutter run -d web
```

#### Windows版本
```bash
flutter run -d windows
```

#### Android模擬器
```bash
flutter run -d android
```

#### iOS模擬器 (如果有Mac)
```bash
flutter run -d ios
```

## 📱 功能演示

### 當前可用功能
1. **啟動畫面** - 品牌化啟動動畫 (1.2秒)
2. **設計系統** - 完整的Material 3主題
3. **佔位頁面** - 展示開發進度

### 預期體驗
- 🎨 漸層背景啟動畫面
- ⚡ 流暢的縮放動畫
- 🌟 GoAA品牌標誌展示
- 📱 響應式設計

## 🔧 開發指令

### 常用指令
```bash
# 檢查代碼品質
flutter analyze

# 運行測試
flutter test

# 清理建置檔案
flutter clean

# 重新安裝依賴
flutter pub get

# 檢查Flutter環境
flutter doctor
```

### 建置指令
```bash
# Web版本建置
flutter build web

# Windows版本建置
flutter build windows

# Android APK建置
flutter build apk

# Android Bundle建置
flutter build appbundle
```

## 📁 專案結構

```
goaa_flutter/
├── lib/
│   ├── core/              # 核心設計系統
│   │   └── theme/         # 主題配置
│   ├── features/          # 功能模組
│   │   └── splash/        # 啟動畫面
│   └── main.dart          # 應用入口
├── assets/                # 資源文件
├── test/                  # 測試文件
└── pubspec.yaml          # 依賴配置
```

## 🎯 下一步開發

### 立即可做
1. 運行 `flutter run -d web` 查看效果
2. 修改 `splash_screen.dart` 體驗動畫效果
3. 調整 `app_colors.dart` 嘗試不同色彩

### 開發建議
1. 先實現用戶認證功能
2. 創建個人資料頁面
3. 添加群組管理功能
4. 實現分帳核心功能

## ⚠️ 常見問題

### 1. Flutter命令找不到
```bash
# 添加Flutter到系統PATH
$env:PATH = "C:\flutter\bin;" + $env:PATH
```

### 2. Cursor IDE設定
確保在Cursor設定中：
- Flutter SDK路徑正確
- Dart插件已安裝

### 3. 編譯錯誤
大部分警告可以忽略（deprecation warnings），只關注error級別的問題。

### 4. 網路問題
如果pub get失敗，嘗試：
```bash
flutter pub cache repair
flutter clean
flutter pub get
```

## 🚀 立即體驗

執行以下命令快速體驗GoAA Flutter版本：

```bash
cd C:\WinAp\Cursor\android\GoAA\goaa_flutter
flutter run -d web
```

在瀏覽器中將看到：
- 🎨 漂亮的漸層啟動畫面
- ⚡ 流暢的GoAA標誌動畫
- 📱 響應式設計展示

---

**恭喜！** GoAA Flutter專案已準備就緒，可以開始跨平台開發之旅！ 🎉 
