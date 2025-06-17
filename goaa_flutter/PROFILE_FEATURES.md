# 個人檔案系統功能說明

## 功能概覽

已完成的個人檔案系統包含以下功能：

### 1. 頭像管理
- ✅ **相機拍攝**：支持使用相機拍攝頭像
- ✅ **相簿選擇**：從設備相簿中選擇照片
- ✅ **圖片裁剪**：自動裁剪為正方形頭像
- ✅ **預設頭像**：提供40個預設頭像（貓貓、狗狗、男生、女生各10張）
- ✅ **隨機選擇**：隨機選擇預設頭像功能

### 2. 用戶資訊管理
- ✅ **唯一用戶ID**：每個安裝都有唯一的32位用戶ID
- ✅ **用戶代碼**：8位字母數字組合，用於邀請和分享
- ✅ **設備指紋**：基於設備信息生成唯一標識
- ✅ **持久化存儲**：使用SharedPreferences保存ID

### 3. 表單驗證
- ✅ **使用者名稱驗證**：
  - 必填欄位
  - 最多10個繁體中文字符
  - 防SQL注入和XSS攻擊
  - 過濾危險字符
- ✅ **電子郵件驗證**：選填，支持標準電子郵件格式
- ✅ **手機號碼驗證**：選填，支持台灣手機號碼格式

### 4. 用戶界面
- ✅ **現代化設計**：遵循Material Design規範
- ✅ **響應式布局**：適配不同屏幕尺寸
- ✅ **流暢動畫**：觸覺反饋和視覺效果
- ✅ **多語言支持**：繁體中文和英文

## 技術架構

### 核心服務

1. **AvatarService** (`lib/core/services/avatar_service.dart`)
   - 頭像選擇和管理
   - 圖片裁剪和保存
   - 預設頭像資源管理

2. **UserIdService** (`lib/core/services/user_id_service.dart`)
   - 唯一用戶ID生成
   - 設備指紋生成
   - ID持久化管理

3. **ValidationService** (`lib/core/services/validation_service.dart`)
   - 表單欄位驗證
   - 安全性檢查
   - 輸入清理

### UI組件

1. **ProfileScreen** (`lib/features/profile/profile_screen.dart`)
   - 主要的個人檔案頁面
   - 資料載入和保存邏輯

2. **AvatarWidget** (`lib/features/profile/widgets/avatar_widget.dart`)
   - 頭像顯示組件
   - 支持本地檔案和資源圖片

3. **ProfileForm** (`lib/features/profile/widgets/profile_form.dart`)
   - 個人資料表單
   - 整合驗證邏輯

4. **UserInfoDisplay** (`lib/features/profile/widgets/user_info_display.dart`)
   - 用戶ID和代碼顯示
   - 複製到剪貼簿功能

## 使用方法

### 1. 從側邊選單進入
```dart
// 在側邊選單中點擊「個人檔案」即可進入
drawer_components.DrawerMenuItem(
  icon: Icons.account_circle_outlined,
  title: '個人檔案',
  subtitle: '編輯個人資料',
  onTap: () => DrawerNavigationService.navigateToProfile(context),
),
```

### 2. 程式化導航
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfileScreen()),
);
```

## 資料庫整合

系統已與現有的Drift資料庫完全整合：
- 使用現有的Users表結構
- 支持頭像類型和自定義頭像路徑
- 自動生成和更新時間戳

## 安全特性

- **SQL注入防護**：過濾SQL關鍵字
- **XSS防護**：過濾腳本標籤
- **輸入清理**：移除危險字符
- **長度限制**：防止緩衝區溢出
- **格式驗證**：確保資料完整性

## 依賴項

新增的依賴項：
```yaml
dependencies:
  image_cropper: ^8.0.2      # 圖片裁剪
  uuid: ^4.5.1               # UUID生成
  device_info_plus: ^10.1.2  # 設備信息
```

## 未來擴展

可以進一步擴展的功能：
- 頭像同步到雲端
- 多設備登入管理
- 社交媒體整合
- 更多預設頭像主題
- 頭像濾鏡和編輯功能 
