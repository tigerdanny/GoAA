# 🎯 GOAA 分帳神器 - Flutter版本

![GOAA Logo](logo.png)

## 🌟 專案概述

GOAA是一個現代化的分帳應用，已成功從Android原生遷移至Flutter跨平台架構。提供直觀的用戶界面和強大的分帳功能，支援多平台部署。

## 🚀 快速開始

### 前置要求
- Flutter 3.32.0+
- Dart 3.5.0+
- Android Studio / VS Code

### 安裝步驟
```bash
git clone <repository-url>
cd GOAA
flutter pub get
cd goaa_flutter
flutter run
```

## ✨ 核心特色

### 🎨 設計系統
- ✅ **Material Design 3** - 最新設計規範
- ✅ **品牌化色彩系統** - GOAA專屬色彩規範
- ✅ **統一主題管理** - 支援明暗模式切換
- ✅ **響應式設計** - 適配各種螢幕尺寸

### 💫 用戶體驗
- ✅ **啟動動畫** - 品牌logo動畫效果
- ✅ **流暢動畫** - 60fps流暢體驗
- ✅ **直觀導航** - 簡潔易懂的操作流程
- ✅ **快速操作** - 浮動按鈕快速存取

### 🛠 技術架構
- ✅ **Flutter 3.32.0** - 跨平台UI框架
- ✅ **BLoC狀態管理** - 可預測的狀態管理
- ✅ **依賴注入** - get_it + injectable
- ✅ **本地儲存** - Drift + SQLite
- ✅ **雲端同步** - Firebase整合
- ✅ **路由管理** - go_router

## 📁 專案結構

```
GOAA/
├── goaa_flutter/              # Flutter主專案
│   ├── lib/
│   │   ├── core/              # 核心系統
│   │   │   ├── theme/         # 主題系統
│   │   │   │   ├── app_colors.dart
│   │   │   │   ├── app_theme.dart
│   │   │   │   └── app_dimensions.dart
│   │   │   ├── constants/     # 常數定義
│   │   │   ├── utils/         # 工具類
│   │   │   └── services/      # 服務層
│   │   ├── features/          # 功能模組
│   │   │   ├── splash/        # 啟動畫面
│   │   │   ├── home/          # 首頁
│   │   │   ├── groups/        # 群組管理
│   │   │   ├── expenses/      # 支出記錄
│   │   │   └── settlement/    # 結算功能
│   │   ├── shared/            # 共用組件
│   │   │   ├── widgets/       # UI組件
│   │   │   ├── models/        # 數據模型
│   │   │   └── repositories/  # 數據倉庫
│   │   └── main.dart          # 應用入口
│   ├── assets/                # 資源文件
│   │   ├── images/            # 圖片資源
│   │   ├── icons/             # 圖標資源
│   │   └── data/              # 靜態數據
│   ├── test/                  # 測試文件
│   └── pubspec.yaml           # 依賴配置
├── docs/                      # 專案文檔
├── DESIGN_PROPOSAL.md         # 設計提案
├── MIGRATION_PLAN.md          # 遷移計劃
└── README.md                  # 專案說明
```

## 🎨 設計系統

### 色彩系統
- **主色調**: 深海藍 (#1B5E7E) - 信任、專業
- **次要色**: 活力橘 (#FF6B35) - 友善、溫暖  
- **強調色**: 翠綠 (#4CAF50) - 金錢、成功

### 組件庫
- `AppColors` - 統一色彩管理
- `AppTheme` - 主題配置
- `AppDimensions` - 尺寸規範

## 🚧 開發路線圖

### Phase 1: 基礎架構 ✅
- [x] Flutter專案建立
- [x] 設計系統實現
- [x] 基礎頁面框架
- [x] 主題系統

### Phase 2: 核心功能 🚧
- [ ] 用戶認證系統
- [ ] 群組管理功能
- [ ] 支出記錄功能
- [ ] 分帳計算邏輯

### Phase 3: 進階功能 📋
- [ ] 結算確認流程
- [ ] 數據同步機制
- [ ] 通知推送系統
- [ ] 報表分析功能

### Phase 4: 優化發布 📋
- [ ] 性能優化
- [ ] 測試覆蓋
- [ ] 多語言支援
- [ ] 平台發布

## 🧪 測試

```bash
# 運行單元測試
flutter test

# 運行整合測試
flutter test integration_test/

# 代碼覆蓋率
flutter test --coverage
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

## 📄 授權

本專案採用 MIT 授權條款。

## 🙏 致謝

感謝所有為GOAA專案貢獻的開發者和設計師。

---

**GOAA分帳神器** - 讓分帳變得簡單優雅 ✨
