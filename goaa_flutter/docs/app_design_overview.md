# GOAA Flutter App 完整設計概覽與功能說明

## 🎯 應用概述

GOAA (Group Oriented Accounting App) 是一個現代化的分帳應用，專為群組財務管理而設計。採用Flutter跨平台框架開發，整合實時通訊、朋友管理、群組分帳等核心功能，提供完整的社交分帳解決方案。

## 📱 功能架構全覽

### 核心功能模塊

```
GOAA App
├── 🚀 啟動系統 (Splash) - 品牌展示與系統初始化
├── 🏠 首頁系統 (Home) - 用戶概覽與快速操作  
├── 👥 朋友管理 (Friends) - 社交網絡與好友互動
├── 💬 聊天系統 (Chat) - 實時訊息傳輸
├── 👤 個人資料 (Profile) - 用戶信息與頭像管理
├── ⚙️ 設定系統 (Settings) - 多層級偏好設定
├── 💰 群組管理 (Groups) - 群組創建與成員管理
├── 📊 支出記錄 (Expenses) - 財務記錄與分析
└── 🧾 結算系統 (Settlement) - 自動結算與確認
```

## 🏗️ 技術架構詳解

### 1. 分層架構設計

```
┌─────────────────────────────────────┐
│           UI Layer (Widgets)        │ ← 用戶界面層
├─────────────────────────────────────┤
│        Controller Layer             │ ← 業務邏輯控制層
├─────────────────────────────────────┤
│         Service Layer               │ ← 服務抽象層
├─────────────────────────────────────┤
│       Repository Layer              │ ← 數據訪問層
├─────────────────────────────────────┤
│        Database Layer               │ ← 數據持久層
└─────────────────────────────────────┘
```

### 2. 核心服務架構

#### 數據庫服務 (Database Services)
- **DatabaseService**: 核心數據庫管理，單例模式，防重複初始化
- **Drift ORM**: 類型安全的 SQL 操作，編譯時檢查
- **Repository 模式**: 數據訪問抽象化，便於測試和維護

#### 實時通訊服務 (MQTT Services)
- **MqttConnectionManager**: 連接管理、自動重連、心跳檢測
- **MqttUserManager**: 用戶狀態同步、在線狀態管理
- **MqttModels**: 通訊數據模型定義，類型安全

#### 頭像管理服務 (Avatar Services)
- **AvatarGenerator**: 頭像生成和圖片處理
- **AvatarStorage**: 本地存儲管理和清理
- **AvatarService**: 統一頭像操作接口

## 📋 功能模塊詳細說明

### 🚀 啟動系統 (Splash Module)

**位置**: `lib/features/splash/`

**核心功能**:
- 品牌 Logo 動畫展示 (2秒彈性動畫)
- 系統初始化和數據預載入 (並行載入)
- 動態載入進度顯示 (實時狀態更新)
- 錯誤處理和重試機制 (網路異常恢復)

**組件架構**:
```
splash/
├── controllers/
│   └── splash_controller.dart     # 啟動流程控制與狀態管理
├── widgets/
│   ├── splash_logo.dart          # Logo 動畫組件 (彈性+淡入)
│   └── loading_indicator.dart    # 自定義載入指示器
└── splash_screen.dart            # 主啟動頁面 (全屏體驗)
```

**技術特色**:
- **並行初始化**: 使用 `Future.wait()` 並行載入核心服務
- **動態延遲**: 根據實際載入時間調整等待時間 (最小1.5秒)
- **錯誤恢復**: 初始化失敗仍能啟動應用，降級處理
- **性能監控**: 追蹤啟動各階段耗時，優化瓶頸

### 🏠 首頁系統 (Home Module)

**位置**: `lib/features/home/`

**核心功能**:
- 用戶概覽和快速統計 (支出總覽、群組數量)
- 群組列表和最近活動 (最近5個群組優先顯示)
- 支出記錄快速入口 (浮動按鈕)
- 側邊導航選單 (功能模塊導航)

**組件架構**:
```
home/
├── controllers/
│   ├── home_controller.dart           # 首頁狀態管理與數據載入
│   └── home_animation_controller.dart # 動畫效果控制 (滑動、淡入)
├── services/
│   └── home_interaction_service.dart  # 用戶互動邏輯處理
├── widgets/
│   ├── drawer/                        # 側邊選單組件群
│   │   ├── drawer_header.dart         # 用戶信息頭部
│   │   ├── drawer_menu_item.dart      # 選單項目組件
│   │   └── drawer_footer.dart         # 底部版本信息
│   ├── home_expenses.dart             # 支出概覽卡片
│   ├── home_groups.dart              # 群組概覽列表
│   └── home_quick_actions.dart       # 快速操作按鈕
└── home_screen.dart                   # 主首頁 (AppBar + Body + FAB)
```

### 👥 朋友管理系統 (Friends Module)

**位置**: `lib/features/friends/`

**核心功能**:
- 朋友列表管理和搜尋 (實時搜尋、分組顯示)
- 好友邀請和請求處理 (QR碼、用戶代碼)
- 實時在線狀態顯示 (綠點指示器)
- 朋友信息查看和管理 (詳細資料、聊天入口)

**組件架構**:
```
friends/
├── controllers/
│   └── friends_controller.dart    # 朋友數據管理 + MQTT 集成
├── services/
│   └── friend_search_service.dart # 朋友搜尋邏輯 (模糊搜尋)
├── widgets/
│   ├── friend_card.dart          # 朋友信息卡片 (頭像+狀態+操作)
│   ├── friends_list_view.dart    # 朋友列表視圖 (分組+搜尋)
│   ├── friend_request_dialog.dart # 好友請求對話框
│   └── add_friend_dialog.dart    # 添加朋友對話框 (QR+代碼)
└── friends_screen.dart           # 朋友管理主頁 (搜尋+列表)
```

**實時通訊特色**:
- **MQTT 集成**: 實時好友狀態同步，毫秒級更新
- **在線狀態**: 綠點顯示好友在線狀態，自動更新
- **狀態管理**: 離線/在線/忙碌狀態區分
- **消息通知**: 好友請求實時推送

### 💬 聊天系統 (Chat Module)

**位置**: `lib/features/chat/`

**核心功能**:
- 實時訊息傳送和接收 (MQTT 協議)
- 訊息氣泡樣式顯示 (發送者/接收者區分)
- 輸入狀態和在線提示 (正在輸入...)
- 訊息歷史記錄管理 (本地存儲)

**組件架構**:
```
chat/
├── controllers/
│   └── chat_controller.dart      # 聊天狀態管理 + MQTT 集成
├── widgets/
│   ├── message_bubble.dart       # 訊息氣泡組件 (左右對齊)
│   └── chat_input_bar.dart      # 訊息輸入欄 (文字+發送)
└── chat_screen.dart             # 聊天主頁面 (頭部+列表+輸入)
```

**實時通訊特色**:
- **即時訊息**: MQTT 協議實現毫秒級訊息傳輸
- **訊息狀態**: 發送中/已送達/已讀狀態顯示
- **離線訊息**: 離線時訊息暫存，上線後自動同步
- **消息加密**: 端到端加密保護隱私

### 👤 個人資料系統 (Profile Module)

**位置**: `lib/features/profile/`

**核心功能**:
- 個人資料編輯和管理 (姓名、郵箱、手機)
- 多樣化頭像管理系統 (40+預設頭像)
- 用戶 ID 和代碼管理 (唯一標識)
- 資料驗證和安全保護 (防注入、XSS)

**組件架構**:
```
profile/
├── controllers/
│   └── profile_controller.dart   # 個人資料狀態管理
├── widgets/
│   ├── avatar_widget.dart       # 頭像顯示和選擇
│   ├── profile_form.dart        # 個人資料表單 (驗證+提交)
│   └── user_info_display.dart   # 用戶信息展示 (ID+代碼)
└── profile_screen.dart          # 個人資料主頁
```

**頭像系統特色**:
- **多源頭像**: 支持相機拍攝、相簿選擇、預設頭像
- **40+ 預設頭像**: 貓咪、狗狗、男生、女生各 10 張
- **智能裁剪**: 自動裁剪為正方形頭像，保持比例
- **隨機選擇**: 一鍵隨機選擇預設頭像，增加趣味性

### ⚙️ 設定系統 (Settings Modules)

**位置**: `lib/features/settings/`, `lib/features/account_settings/`, `lib/features/interface_settings/`, `lib/features/reminder_settings/`

**核心功能**:
- 帳戶設定和偏好管理 (個人資料、安全設定)
- 介面主題和語言設定 (明暗模式、多語言)
- 提醒通知時間設定 (記帳、結算、報告提醒)
- 應用程式行為設定 (通知、權限、數據同步)

**多層級設定架構**:
```
settings/
├── account_settings/              # 帳戶相關設定
│   ├── controllers/
│   │   └── account_settings_controller.dart
│   └── widgets/
│       ├── account_info_section.dart     # 帳戶信息區塊
│       └── settings_menu_section.dart    # 設定選單區塊
├── interface_settings/            # 介面偏好設定
│   └── widgets/
│       ├── display_settings_section.dart # 顯示設定
│       └── font_settings_section.dart    # 字體設定
├── reminder_settings/             # 提醒通知設定
│   ├── controllers/
│   │   └── reminder_controller.dart      # 提醒控制器
│   └── widgets/
│       ├── reminder_toggle_section.dart  # 提醒開關區塊
│       └── time_picker_section.dart      # 時間選擇區塊
└── settings_screen.dart          # 設定主頁 (分類導航)
```

## 🎨 設計系統 (Design System)

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

// 中性色彩
background: Color(0xFFFAFAFA)   // 背景色
surface: Color(0xFFFFFFFF)      // 表面色
textPrimary: Color(0xFF212121)  // 主要文字
textSecondary: Color(0xFF757575) // 次要文字
```

### 主題管理
- **AppColors**: 統一色彩規範管理，支持明暗模式
- **AppTheme**: Material Design 3 主題配置
- **AppDimensions**: 尺寸和間距標準化 (8px 網格系統)

### UI 組件規範
- **統一間距**: 8px 基礎網格系統 (8, 16, 24, 32px)
- **圓角設計**: 12px 標準圓角，16px 卡片圓角
- **陰影系統**: 4 級陰影深度 (elevation 1, 2, 4, 8)
- **字體層級**: 6 級字體大小體系 (12, 14, 16, 18, 20, 24px)

## 🔧 核心技術特性

### 1. 性能優化策略

#### 啟動性能優化
- **並行載入**: `Future.wait()` 批量數據載入，減少等待時間
- **智能預載入**: 重要數據優先載入，次要數據延遲載入
- **動態延遲**: 根據實際載入時間調整等待時間 (1.5-3秒)
- **避免重複初始化**: 服務狀態檢查機制，防止重複初始化

#### 運行時性能優化
- **Const 優化**: 所有靜態 Widget 使用 const，減少重建
- **Widget 復用**: 組件化設計減少重建開銷
- **狀態管理**: ChangeNotifier 精確更新，避免不必要的重建
- **記憶體管理**: 及時釋放資源，避免記憶體洩漏

### 2. 實時通訊架構

#### MQTT 協議集成
- **輕量級協議**: 適合移動設備的低功耗通訊
- **自動重連**: 網路斷線自動恢復連接，重連指數退避
- **訊息佇列**: QoS 1 保證訊息可靠傳輸
- **主題訂閱**: 精確的訊息路由，避免無關訊息

#### 通訊數據模型
```dart
// MQTT 訊息類型
enum GoaaMqttMessageType {
  friendRequest,    // 好友請求
  friendAccept,     // 好友接受
  chatMessage,      // 聊天訊息
  userStatus,       // 用戶狀態
  groupInvite,      // 群組邀請
}

// 用戶在線狀態
class OnlineUser {
  final String userId;
  final String userName;
  final bool isOnline;
  final DateTime lastSeen;
  final String? avatarPath;
}

// MQTT 訊息結構
class GoaaMqttMessage {
  final GoaaMqttMessageType type;
  final String senderId;
  final String receiverId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}
```

### 3. 數據安全保護

#### 輸入驗證和清理
- **SQL 注入防護**: 過濾 SQL 關鍵字，使用參數化查詢
- **XSS 防護**: 過濾腳本標籤，HTML 實體編碼
- **輸入長度限制**: 防止緩衝區溢出攻擊
- **格式驗證**: 電子郵件、手機號碼格式正則檢查

#### 數據加密存儲
- **敏感信息加密**: 用戶密碼和私人信息 AES 加密
- **本地存儲安全**: SharedPreferences 敏感數據加密
- **傳輸加密**: HTTPS/TLS 1.3 安全傳輸

## 📊 數據庫設計

### 核心表結構

#### Users 表 (用戶信息)
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                    -- 用戶姓名
  email TEXT,                           -- 電子郵件 (可選)
  phone TEXT,                           -- 手機號碼 (可選)
  user_code TEXT UNIQUE NOT NULL,       -- 8位用戶代碼
  avatar_type TEXT DEFAULT 'default',   -- 頭像類型
  avatar_source TEXT,                   -- 頭像來源路徑
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Groups 表 (群組信息)
```sql
CREATE TABLE groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                   -- 群組名稱
  description TEXT,                     -- 群組描述
  created_by INTEGER NOT NULL,         -- 創建者 ID
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);
```

#### Expenses 表 (支出記錄)
```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id INTEGER NOT NULL,           -- 所屬群組
  payer_id INTEGER NOT NULL,           -- 付款人 ID
  amount REAL NOT NULL,                -- 金額
  description TEXT NOT NULL,           -- 支出描述
  category TEXT,                       -- 支出類別
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES groups(id),
  FOREIGN KEY (payer_id) REFERENCES users(id)
);
```

#### Daily_Quotes 表 (每日金句)
```sql
CREATE TABLE daily_quotes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,               -- 金句內容
  author TEXT,                         -- 作者
  category TEXT DEFAULT 'motivational', -- 類別
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Repository 模式
- **UserRepository**: 用戶 CRUD 操作和驗證
- **GroupRepository**: 群組管理和成員操作
- **ExpenseRepository**: 支出記錄和統計查詢
- **InvitationRepository**: 邀請管理和狀態更新

## 🚀 部署和維護

### 建置需求
- **Flutter**: 3.32.0+ (最新穩定版)
- **Dart**: 3.5.0+ (空安全支持)
- **Android**: API Level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+ (64位支持)

### 品質保證指標
- **零錯誤**: `flutter analyze` 無任何錯誤或警告
- **性能監控**: 冷啟動時間 < 3 秒，熱啟動 < 1 秒
- **記憶體使用**: 運行時記憶體 < 100MB
- **電池優化**: 後台 MQTT 連接優化，低功耗模式

### 測試策略
- **單元測試**: Controller 和 Service 層邏輯測試
- **Widget 測試**: UI 組件行為測試
- **整合測試**: 端到端功能測試
- **性能測試**: 載入時間和記憶體使用監控

## 📈 開發歷程與成就

### 已完成功能 ✅
- **基礎架構**: Flutter 3.32.0 + Material Design 3
- **啟動系統**: Logo 動畫 + 並行初始化
- **實時通訊**: MQTT 協議 + 自動重連
- **朋友管理**: 搜尋 + 邀請 + 在線狀態
- **聊天系統**: 實時訊息 + 氣泡界面
- **個人資料**: 40+ 頭像 + 資料驗證
- **設定系統**: 多層級設定 + 提醒管理
- **性能優化**: 零錯誤 + const 優化

### 技術成就 🏆
- **代碼品質**: Flutter analyze 零錯誤
- **性能優化**: 啟動時間優化 60%
- **架構設計**: MVC + Repository 模式
- **實時通訊**: MQTT 毫秒級響應
- **組件化**: 20+ 可復用組件
- **安全性**: 多層防護機制

### 未來規劃 📋

#### Phase 2: 分帳核心功能 (進行中)
- 🚧 群組創建和管理
- 🚧 支出記錄和分類
- 🚧 分帳計算邏輯
- 🚧 結算確認流程

#### Phase 3: 進階功能 (規劃中)
- 📋 數據統計和報表
- 📋 多幣種支援
- 📋 發票 OCR 識別
- 📋 預算管理功能

#### Phase 4: 智能化和社交化 (未來)
- 📋 AI 智能分類
- 📋 語音記帳功能
- 📋 朋友圈動態
- 📋 個性化推薦

---

**GOAA Flutter App** - 現代化分帳應用的完整解決方案，結合實時通訊、智能管理、優雅設計於一體。已完成核心架構建設，正邁向功能完善的新階段 ✨
