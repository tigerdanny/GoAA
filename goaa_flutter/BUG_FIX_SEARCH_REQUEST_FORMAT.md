# 搜索請求格式錯誤修復報告

## 問題描述

從用戶提供的日誌中發現，系統收到了新格式的搜索請求消息，但處理程序還在尋找舊格式的字段，導致搜索請求無法正確處理。

### 錯誤日誌分析
```
I/flutter (21077): 🔍 [GLOBAL] 收到用戶搜索請求
I/flutter (21077):    消息數據: {requestId: 1750736183325, searchType: name, searchValue: 王丹尼, ...}
I/flutter (21077):    requestId: null
I/flutter (21077):    searchCriteria: null  // ❌ 尋找舊格式字段
I/flutter (21077):    requesterInfo: null
I/flutter (21077): ❌ [GLOBAL] 搜索請求格式錯誤
```

### 問題根因
1. **格式不匹配**: 消息包含新格式 `{searchType: "name", searchValue: "王丹尼"}`，但處理器尋找舊格式 `{searchCriteria: {...}}`
2. **重複處理**: 好友控制器和全局服務都在處理搜索請求，造成"未處理的消息類型"警告

## 修復方案

### 1. 更新全局搜索處理方法 (`mqtt_app_service.dart`)

#### 修復前:
```dart
final searchCriteria = message.data['searchCriteria'] as Map<String, dynamic>?;
if (requestId == null || searchCriteria == null || requesterInfo == null) {
  // 格式錯誤
}
final matchScore = _calculateMatchScore(currentUser, searchCriteria);
```

#### 修復後:
```dart
final searchType = message.data['searchType'] as String?;
final searchValue = message.data['searchValue'] as String?;
if (requestId == null || searchType == null || searchValue == null || requesterInfo == null) {
  // 格式檢查
}
final isMatch = _checkSearchMatch(currentUser, searchType, searchValue);
```

### 2. 更新匹配邏輯

#### 舊的計算匹配度方法:
```dart
double _calculateMatchScore(dynamic currentUser, Map<String, dynamic> searchCriteria) {
  // 複雜的權重計算
}
```

#### 新的檢查匹配方法:
```dart
bool _checkSearchMatch(dynamic currentUser, String searchType, String searchValue) {
  switch (searchType) {
    case 'name': return userName.contains(searchValueLower);
    case 'email': return userEmail == searchValueLower;
    case 'phone': return userPhone == cleanSearchPhone;
  }
}
```

### 3. 修復好友控制器消息處理 (`friends_controller.dart`)

#### 修復前:
```dart
default:
  debugPrint('⚠️ 未處理的好友消息類型: ${message.type}'); // ❌ 搜索請求被報告為未處理
```

#### 修復後:
```dart
case GoaaMqttMessageType.userSearchRequest:
  debugPrint('🔍 搜索請求已由全局服務處理');
  break;
case GoaaMqttMessageType.userSearchResponse:
  debugPrint('📨 搜索響應已由搜索服務處理');
  break;
default:
  debugPrint('⚠️ 未處理的好友消息類型: ${message.type}');
```

### 4. 更新響應格式

#### 修復前:
```dart
'userInfo': {
  'matchScore': matchScore, // 舊的匹配度
}
```

#### 修復後:
```dart
'responseFormat': '-research,${currentUser.userCode},name,"${currentUser.name}"',
'userInfo': {
  // 完整用戶信息，無匹配度
}
```

## 修復結果

### 預期的新日誌輸出:
```
I/flutter: 🔍 [GLOBAL] 收到用戶搜索請求
I/flutter:    requestId: 1750736183325
I/flutter:    searchType: name
I/flutter:    searchValue: 王丹尼
I/flutter:    requesterInfo: {userId: c5bb6c43..., userName: Danny}
I/flutter: 🔍 [GLOBAL] 處理搜索請求來自: Danny
I/flutter:    搜索條件: -search,name,"王丹尼"
I/flutter: ✅ [GLOBAL] 匹配搜索條件
I/flutter: 📤 [GLOBAL] 已發送搜索響應: -research,GA001234...,name,"用戶姓名" 給: Danny
I/flutter: 🔍 搜索請求已由全局服務處理 (好友控制器)
```

## 技術要點

### 1. 消息格式統一
- 搜索請求: `{searchType: "name", searchValue: "王丹尼"}`
- 搜索響應: `{responseFormat: "-research,uuid,name,\"王丹尼\""}`

### 2. 避免重複處理
- 全局服務負責處理搜索請求和發送響應
- 好友控制器只是確認消息已被處理
- 搜索服務負責收集響應結果

### 3. 匹配邏輯簡化
- 從複雜的權重計算改為簡單的布爾匹配
- 更快的處理速度
- 更清晰的匹配邏輯

## 測試驗證

- ✅ 代碼編譯成功
- ✅ 消息格式適配完成
- ✅ 重複處理問題解決
- ✅ 搜索匹配邏輯更新

## 總結

此次修復解決了搜索請求格式不匹配的關鍵問題，確保了新格式的搜索消息能夠被正確處理。同時清理了重複的消息處理邏輯，提高了系統的穩定性和可維護性。 
