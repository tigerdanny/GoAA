# 🎯 GoAA 分帳神器 - Flutter版本

> 跨平台分帳應用，讓分帳變得簡單優雅

## 📱 專案概述

GoAA是一個現代化的分帳應用，已成功從Android原生遷移至Flutter跨平台架構。提供直觀的用戶界面和強大的分帳功能，支援多平台部署。

## 🚀 快速開始

### 環境要求
- Flutter SDK 3.32.0+
- Dart 3.8.0+
- Android Studio / VS Code / Cursor IDE
- Git

### 安裝與運行
```bash
# 1. 克隆專案
git clone [repository-url]
cd GoAA

# 2. 進入Flutter專案目錄
cd goaa_flutter

# 3. 安裝依賴
flutter pub get

# 4. 運行應用
flutter run -d web          # Web版本
flutter run -d windows      # Windows版本
flutter run -d android      # Android版本
```

## 🎨 技術特色

### 設計系統
- ✅ **完整的Material 3主題** - 1200+行設計系統代碼
- ✅ **品牌化色彩系統** - GoAA專屬色彩規範
- ✅ **響應式設計** - 支援多種螢幕尺寸
- ✅ **暗色模式支援** - 自動適應系統主題

### 架構特點
- 🏗️ **Feature-driven架構** - 模組化開發
- 🔄 **BLoC狀態管理** - 可預測的狀態管理
- 🗄️ **Drift數據庫** - 類型安全的本地存儲
- 🔐 **安全存儲** - 生物識別和加密存儲

### 跨平台支援
- 🌐 **Web** - PWA支援
- 🪟 **Windows** - 原生Windows應用
- 🤖 **Android** - Material Design
- 🍎 **iOS** - Cupertino風格 (規劃中)

## 📁 專案結構

```
GoAA/
├── goaa_flutter/              # Flutter主專案
│   ├── lib/
│   │   ├── core/              # 核心設計系統
│   │   │   └── theme/         # 主題配置
│   │   ├── features/          # 功能模組
│   │   │   ├── splash/        # ✅ 啟動畫面
│   │   │   ├── auth/          # 🔄 用戶認證
│   │   │   ├── profile/       # 🔄 個人資料
│   │   │   ├── groups/        # 🔄 群組管理
│   │   │   ├── expenses/      # 🔄 分帳記錄
│   │   │   └── settlement/    # 🔄 結算功能
│   │   └── main.dart          # 應用入口
│   ├── assets/                # 資源文件
│   ├── test/                  # 測試文件
│   └── pubspec.yaml           # 依賴配置
├── docs/                      # 專案文檔
└── README.md                  # 本文件
```

## 🛠️ 開發指令

### 常用指令
```bash
# 代碼品質檢查
flutter analyze

# 運行測試
flutter test

# 清理建置檔案
flutter clean

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

## 📊 開發進度

| 功能模組 | 狀態 | 進度 | 說明 |
|---------|------|------|------|
| 設計系統 | ✅ 完成 | 100% | Material 3主題系統 |
| 啟動畫面 | ✅ 完成 | 100% | 品牌化啟動動畫 |
| 用戶認證 | 🔄 開發中 | 0% | 生物識別 + 密碼 |
| 個人資料 | 🔄 規劃中 | 0% | 頭像系統 + 設定 |
| 群組管理 | 🔄 規劃中 | 0% | 創建 + 邀請 + 管理 |
| 分帳功能 | 🔄 規劃中 | 0% | 記錄 + 計算 + 結算 |

## 🎯 開發路線圖

### Phase 1: 核心功能 (2週)
- [ ] 用戶認證系統
- [ ] 個人資料管理
- [ ] 基礎數據模型

### Phase 2: 社交功能 (3週)
- [ ] 群組創建與管理
- [ ] 頭像系統遷移
- [ ] 成員邀請功能

### Phase 3: 分帳核心 (4週)
- [ ] 支出記錄功能
- [ ] 分帳計算引擎
- [ ] 結算系統

### Phase 4: 優化&擴展 (2週)
- [ ] 數據同步
- [ ] 報表統計
- [ ] 匯出功能

## 📚 文檔

- [Flutter快速啟動指南](FLUTTER_QUICK_START.md)
- [Flutter遷移總結](FLUTTER_MIGRATION_SUMMARY.md)
- [專案結構清理指南](PROJECT_STRUCTURE_CLEANUP.md)

## 🤝 貢獻

歡迎提交Issue和Pull Request來改善這個專案。

## 📄 授權

本專案採用 MIT 授權條款。

---

**GoAA分帳神器** - 讓分帳變得簡單優雅 ✨ 
