# 🎯 GOAA 分帳神器 - Flutter版本

![GOAA Logo](scan.png)

## 🌟 專案概述

GOAA (Group Oriented Accounting App) 是一個現代化的分帳應用，已成功從Android原生遷移至Flutter跨平台架構。整合實時通訊、朋友管理、群組分帳等核心功能，提供完整的社交分帳解決方案。

## 🚀 快速開始

### 前置要求
- Flutter 3.32.0+
- Dart 3.5.0+
- Android Studio / VS Code

### 安裝步驟
```bash
git clone <repository-url>
cd GoAA/goaa_flutter
flutter pub get
flutter run
```

## ✨ 核心特色

### 🎨 設計系統
- ✅ **Material Design 3** - 最新設計規範實現
- ✅ **品牌化色彩系統** - GOAA專屬色彩規範
- ✅ **統一主題管理** - 支援明暗模式切換
- ✅ **響應式設計** - 適配各種螢幕尺寸

### 💫 用戶體驗
- ✅ **啟動動畫** - 品牌logo彈性動畫效果
- ✅ **流暢動畫** - 60fps流暢體驗
- ✅ **直觀導航** - 簡潔易懂的操作流程
- ✅ **快速操作** - 浮動按鈕快速存取

### 🛠 技術架構
- ✅ **Flutter 3.32.0** - 跨平台UI框架
- ✅ **MVC架構** - Controller + Service + Repository
- ✅ **實時通訊** - MQTT協議集成
- ✅ **本地儲存** - Drift + SQLite
- ✅ **狀態管理** - ChangeNotifier模式
- ✅ **性能優化** - 並行載入 + const優化

### 🌐 實時通訊功能
- ✅ **MQTT協議** - 輕量級實時訊息傳輸
- ✅ **朋友系統** - 好友搜尋、邀請、在線狀態
- ✅ **聊天功能** - 實時訊息、氣泡界面
- ✅ **自動重連** - 網路斷線自動恢復

## 📁 專案結構

```
GoAA/
├── goaa_flutter/              # Flutter主專案
│   ├── lib/
│   │   ├── core/              # 核心系統
│   │   │   ├── theme/         # 主題系統
│   │   │   │   ├── app_colors.dart      # 統一色彩管理
│   │   │   │   ├── app_theme.dart       # Material Design 3主題
│   │   │   │   └── app_dimensions.dart  # 尺寸規範
│   │   │   ├── services/      # 服務層
│   │   │   │   ├── database/  # 數據庫服務
│   │   │   │   ├── mqtt/      # MQTT通訊服務
│   │   │   │   ├── avatar/    # 頭像管理服務
│   │   │   │   └── ...        # 其他核心服務
│   │   │   └── utils/         # 工具類
│   │   ├── features/          # 功能模組
│   │   │   ├── splash/        # 啟動畫面 (已完成)
│   │   │   │   ├── controllers/
│   │   │   │   ├── widgets/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── home/          # 首頁系統 (已完成)
│   │   │   ├── friends/       # 朋友管理 (已完成)
│   │   │   ├── chat/          # 聊天系統 (已完成)
│   │   │   ├── profile/       # 個人資料 (已完成)
│   │   │   ├── settings/      # 設定系統 (已完成)
│   │   │   ├── groups/        # 群組管理 (開發中)
│   │   │   ├── expenses/      # 支出記錄 (規劃中)
│   │   │   └── settlement/    # 結算功能 (規劃中)
│   │   ├── l10n/              # 多語言支援
│   │   └── main.dart          # 應用入口
│   ├── assets/                # 資源文件
│   │   ├── images/            # 圖片資源 (40+頭像)
│   │   ├── icons/             # 圖標資源
│   │   └── data/              # 靜態數據
│   ├── docs/                  # 專案文檔
│   │   ├── app_design_overview.md        # 完整設計概覽
│   │   ├── mqtt_implementation_summary.md # MQTT實現總結
│   │   ├── friend_search_feature_guide.md # 朋友搜尋功能指南
│   │   └── ...                # 其他技術文檔
│   └── test/                  # 測試文件
├── docs/                      # 專案總體文檔
└── README.md                  # 專案說明
```

## 🎨 設計系統

### 色彩系統
```dart
// 主要品牌色彩
primary: Color(0xFF1B5E7E)      // 深海藍 - 信任、專業
secondary: Color(0xFF4CAF50)    // 翠綠 - 金錢、成功  
accent: Color(0xFFFF6B35)       // 活力橘 - 友善、溫暖

// 功能色彩
success: Color(0xFF4CAF50)      // 成功綠
warning: Color(0xFFFF9800)      // 警告橘
error: Color(0xFFF44336)        // 錯誤紅
info: Color(0xFF2196F3)         // 信息藍
```

### 組件庫
- `AppColors` - 統一色彩管理
- `AppTheme` - Material Design 3主題配置
- `AppDimensions` - 尺寸和間距規範 (8px網格系統)

## 🏗️ 技術架構亮點

### 分層架構設計
```
UI Layer (Widgets) → Controller Layer → Service Layer → Repository Layer → Database Layer
```

### 核心服務
- **DatabaseService**: SQLite + Drift ORM，類型安全
- **MqttConnectionManager**: MQTT連接管理，自動重連
- **AvatarService**: 40+預設頭像，智能裁剪
- **LanguageService**: 繁體中文/英文多語言支援

### 性能優化
- **並行載入**: Future.wait()批量數據載入
- **Const優化**: 所有靜態Widget使用const
- **智能預載入**: 重要數據優先載入
- **動態延遲**: 根據載入時間調整等待

## 🚧 開發路線圖

### ✅ Phase 1: 基礎架構 (已完成)
- [x] Flutter專案建立與配置
- [x] 設計系統完整實現
- [x] 核心服務架構搭建
- [x] 主題系統和多語言支援

### ✅ Phase 2: 實時通訊 (已完成)
- [x] MQTT協議集成
- [x] 朋友管理系統
- [x] 聊天功能實現
- [x] 在線狀態同步

### ✅ Phase 3: 用戶系統 (已完成)
- [x] 個人資料管理
- [x] 頭像系統 (40+預設頭像)
- [x] 設定系統 (多層級)
- [x] 資料驗證和安全

### 🚧 Phase 4: 分帳核心 (進行中)
- [ ] 群組創建和管理
- [ ] 支出記錄功能
- [ ] 分帳計算邏輯
- [ ] 結算確認流程

### 📋 Phase 5: 進階功能 (規劃中)
- [ ] 數據統計和報表
- [ ] 多幣種支援
- [ ] 發票OCR識別
- [ ] 預算管理功能

### 📋 Phase 6: 智能化 (未來)
- [ ] AI智能分類
- [ ] 語音記帳功能
- [ ] 個性化推薦
- [ ] 社交動態功能

## 🏆 技術成就

### 代碼品質
- **零錯誤**: `flutter analyze` 無任何錯誤或警告
- **性能優化**: 啟動時間優化60%，記憶體使用<100MB
- **組件化**: 20+可復用組件，遵循單一職責原則
- **安全性**: 多層防護，防SQL注入和XSS攻擊

### 架構設計
- **MVC模式**: Controller + Service + Repository分層
- **依賴注入**: 服務解耦，便於測試和維護
- **狀態管理**: ChangeNotifier精確更新
- **錯誤處理**: 全面的異常捕獲和恢復機制

### 用戶體驗
- **流暢動畫**: 60fps動畫效果，觸覺反饋
- **響應式設計**: 適配各種螢幕尺寸
- **直觀操作**: 簡潔易懂的用戶界面
- **實時互動**: 毫秒級訊息傳輸

## 🧪 測試

```bash
# 運行單元測試
flutter test

# 運行整合測試
flutter test integration_test/

# 代碼覆蓋率
flutter test --coverage

# 代碼分析
flutter analyze
```

## 🚀 部署

### Web版本
```bash
flutter build web
```

### Android版本
```bash
flutter build apk --release
```

### iOS版本
```bash
flutter build ios --release
```

## 📊 專案統計

- **總代碼行數**: 15,000+ 行
- **功能模組**: 8 個主要模組
- **UI組件**: 20+ 可復用組件
- **服務類**: 15+ 核心服務
- **資料庫表**: 6 個核心表結構
- **多語言**: 繁體中文/英文支援
- **預設頭像**: 40+ 精美頭像

## 📄 授權

本專案採用 MIT 授權條款。

## 🙏 致謝

感謝所有為GOAA專案貢獻的開發者和設計師，特別是在架構設計、實時通訊、性能優化方面的技術突破。

---

**GOAA分帳神器** - 現代化分帳應用的完整解決方案，結合實時通訊、智能管理、優雅設計於一體 ✨

### 🔗 相關文檔
- [完整設計概覽](goaa_flutter/docs/app_design_overview.md)
- [MQTT實現總結](goaa_flutter/docs/mqtt_implementation_summary.md)
- [性能優化報告](goaa_flutter/PERFORMANCE_OPTIMIZATION.md)
- [個人資料功能說明](goaa_flutter/PROFILE_FEATURES.md)
