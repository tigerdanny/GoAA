# 🚀 GoAA Flutter 遷移專案計劃

## 🎯 專案概述
將Android原生GoAA分帳應用遷移至Flutter，實現跨平台統一體驗。

## 📱 應用功能對照表

| 功能模組 | Android現狀 | Flutter實現 | 設計建議 |
|---------|------------|-------------|----------|
| 啟動畫面 | Splash Screen API | Flutter Splash Screen | 保持品牌一致性，優化動畫 |
| 用戶認證 | Biometric + Password | local_auth + secure_storage | 增加社交登入選項 |
| 個人資料 | Avatar + Profile | 同功能重構 | 改進頭像選擇器UX |
| 群組管理 | Groups + Members | 同功能重構 | 添加群組主題色彩 |
| 分帳計算 | Expense + Settlement | 同功能重構 | 視覺化分帳流程 |
| 資料管理 | Room Database | SQLite/Drift | 雲端同步功能 |

## 🏗️ Flutter專案結構

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # 應用常數
│   │   ├── route_constants.dart        # 路由常數
│   │   └── asset_constants.dart        # 資源路徑
│   ├── theme/
│   │   ├── app_theme.dart             # 主題配置
│   │   ├── app_colors.dart            # 顏色系統
│   │   ├── app_text_styles.dart       # 文字樣式
│   │   └── app_dimensions.dart        # 尺寸規範
│   ├── utils/
│   │   ├── extensions.dart            # 擴展方法
│   │   ├── validators.dart            # 表單驗證
│   │   └── formatters.dart            # 數據格式化
│   └── widgets/
│       ├── common/
│       │   ├── custom_app_bar.dart    # 自定義導航欄
│       │   ├── loading_widget.dart    # 載入組件
│       │   └── error_widget.dart      # 錯誤顯示
│       └── buttons/
│           ├── primary_button.dart    # 主要按鈕
│           └── icon_button.dart       # 圖標按鈕
├── features/
│   ├── splash/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── splash_page.dart
│   │   │   └── widgets/
│   │   │       └── animated_logo.dart
│   │   └── logic/
│   │       └── splash_cubit.dart
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── logic/
│   ├── profile/
│   │   └── [同樣的架構]
│   ├── groups/
│   │   └── [同樣的架構]
│   ├── expenses/
│   │   └── [同樣的架構]
│   └── settlement/
│       └── [同樣的架構]
├── data/
│   ├── models/
│   ├── repositories/
│   └── local/
│       ├── database/
│       └── storage/
└── main.dart
```

## 🎨 設計系統遷移

### 1. **顏色系統優化**
```dart
class AppColors {
  // 主色調 - 保持原有深藍系統
  static const Color primary = Color(0xFF2BBAC5);
  static const Color primaryVariant = Color(0xFF1B5E7E);
  static const Color secondary = Color(0xFFF5A623);
  
  // 新增語義化顏色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 中性色階
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  // ... 更多色階
}
```

### 2. **文字系統升級**
```dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // 新增數字顯示專用樣式
  static const TextStyle currency = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

### 3. **組件設計系統**
```dart
class AppDimensions {
  // 間距系統 (8pt grid)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  
  // 圓角系統
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  
  // 陰影系統
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
```

## 🛠️ 技術架構建議

### 狀態管理
- **推薦**: `flutter_bloc` (Cubit/Bloc pattern)
- **原因**: 與現有Android架構(ViewModel)相似，易於遷移

### 依賴注入
- **推薦**: `get_it` + `injectable`
- **原因**: 類似Android的Hilt，結構清晰

### 本地存儲
- **推薦**: `drift` (SQLite) + `hive` (Key-Value)
- **原因**: 保持數據結構一致性

### 網路請求
- **推薦**: `dio` + `retrofit_dio`
- **原因**: 類似Android的Retrofit

## 📊 關鍵功能增強建議

### 1. **更好的頭像系統**
```dart
class AvatarWidget extends StatelessWidget {
  final String? avatarId;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;
  
  // 支援多種來源：網路圖片、本地資源、文字頭像
  // 優雅的載入狀態和錯誤處理
  // 可自定義邊框和陰影
}
```

### 2. **分帳視覺化**
```dart
class ExpenseVisualization extends StatelessWidget {
  // 使用 fl_chart 創建美觀的圓餅圖
  // 顯示每個人的支出比例
  // 互動式圖表，點擊查看詳情
}
```

### 3. **手勢操作增強**
```dart
// 左滑刪除費用項目
// 長按快速編輯
// 下拉刷新數據
// 上滑載入更多
```

## 🎯 用戶體驗改進

### 1. **微互動設計**
- 按鈕點擊回馈
- 頁面切換動畫
- 數字滾動效果
- 成功操作慶祝動畫

### 2. **無障礙設計**
- 語義化標籤
- 對比度優化
- 字體大小適配
- 語音播報支援

### 3. **國際化準備**
```dart
// 使用 flutter_localizations
// 準備多語言資源
// 文字方向適配(RTL)
// 貨幣格式本地化
```

## 📱 平台特定優化

### iOS設計適配
- 使用Cupertino風格組件
- 適配iOS導航模式
- 支援iOS手勢
- 適配安全區域

### Android設計保持
- Material Design 3
- Android Back手勢
- Android分享功能
- 通知系統整合

## 🚀 遷移階段規劃

### Phase 1: 基礎架構 (2週)
- ✅ 專案初始化和架構搭建
- ✅ 設計系統和主題配置
- ✅ 基礎組件庫開發
- ✅ 路由和導航設置

### Phase 2: 核心功能 (4週)
- ✅ 用戶認證系統
- ✅ 個人資料管理
- ✅ 群組功能
- ✅ 基本分帳功能

### Phase 3: 進階功能 (3週)
- ✅ 分帳計算和結算
- ✅ 數據視覺化
- ✅ 通知系統
- ✅ 匯出功能

### Phase 4: 優化和測試 (2週)
- ✅ 性能優化
- ✅ 用戶測試
- ✅ Bug修復
- ✅ App Store準備

## 📦 依賴包建議

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 狀態管理
  flutter_bloc: ^8.1.3
  
  # 依賴注入
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # 網路請求
  dio: ^5.3.2
  retrofit: ^4.0.3
  
  # 本地存儲
  drift: ^2.13.2
  hive_flutter: ^1.1.0
  
  # UI組件
  flutter_svg: ^2.0.8
  cached_network_image: ^3.3.0
  fl_chart: ^0.65.0
  
  # 工具類
  intl: ^0.18.1
  equatable: ^2.0.5
  
  # 安全
  local_auth: ^2.1.6
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  # 代碼生成
  build_runner: ^2.4.7
  injectable_generator: ^2.4.1
  retrofit_generator: ^8.0.4
  
  # 測試
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

## 🎨 視覺設計升級建議

### 1. **卡片設計優化**
- 使用更現代的卡片陰影
- 增加卡片懸停效果
- 優化卡片內容層次

### 2. **色彩心理學應用**
- 綠色：收入/獲得金錢
- 紅色：支出/欠款
- 藍色：中性/平衡
- 橙色：警告/需要注意

### 3. **圖標系統統一**
- 使用一致的圖標風格
- 增加品牌特色圖標
- 優化圖標可識別性

## 📈 性能優化策略

### 1. **圖片優化**
- 使用SVG向量圖標
- 圖片懶加載
- 多尺寸適配

### 2. **動畫性能**
- 使用`AnimatedBuilder`
- 避免不必要的重建
- 合理使用`const`

### 3. **內存管理**
- 及時釋放資源
- 使用對象池
- 監控內存使用

這個遷移計劃不僅保持了原有的功能完整性，還充分利用了Flutter的優勢來提升用戶體驗。建議分階段實施，確保每個階段都有可測試的交付成果。 
