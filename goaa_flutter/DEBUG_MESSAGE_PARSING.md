# 消息解析問題調試與修復

## 問題現象

根據用戶提供的日誌，發現搜索請求消息的解析存在問題：

### 原始日誌
```
I/flutter ( 1150):    消息數據: {id: 1750737149076, type: userSearchRequest, fromUserId: c5bb6c4326e54d74a21680b607f38bb7, toUserId: all, data: {requestId: 1750737149076, searchType: name, searchValue: 王丹尼, requesterInfo: {userId: c5bb6c4326e54d74a21680b607f38bb7, userName: Danny}}, timestamp: 2025-06-24T11:52:29.076275, group: friends}

I/flutter ( 1150):    requestId: null
I/flutter ( 1150):    searchType: null
I/flutter ( 1150):    searchValue: null
I/flutter ( 1150):    requesterInfo: null
I/flutter ( 1150): ❌ [GLOBAL] 搜索請求格式錯誤
```

### 問題分析
1. **數據結構不匹配**: 消息顯示包含正確的 `data` 字段，但解析時所有字段為 `null`
2. **數據庫查詢**: 出現了意外的 `Drift: Sent SELECT * FROM "users"` 查詢
3. **雙層嵌套**: 可能存在 `message.data.data` 的雙層嵌套結構

## 調試方案

為了診斷問題，我添加了詳細的調試日誌：

### 1. 消息結構診斷
```dart
debugPrint('🔍 [GLOBAL] 收到用戶搜索請求');
debugPrint('   消息完整結構: ${message.toJson()}');
debugPrint('   消息數據字段: ${message.data}');
debugPrint('   消息數據類型: ${message.data.runtimeType}');
debugPrint('   消息數據鍵值: ${message.data.keys.toList()}');
```

### 2. 嵌套數據檢測
```dart
// 檢查數據結構
final dataField = message.data['data'];
if (dataField != null) {
  debugPrint('   檢測到嵌套data字段: $dataField');
  final nestedData = dataField as Map<String, dynamic>;
  final requestId = nestedData['requestId'] as String?;
  final searchType = nestedData['searchType'] as String?;
  final searchValue = nestedData['searchValue'] as String?;
  final requesterInfo = nestedData['requesterInfo'] as Map<String, dynamic>?;
  
  // 使用嵌套數據處理
  if (requestId != null && searchType != null && searchValue != null && requesterInfo != null) {
    await _processSearchRequest(currentUser, requestId, searchType, searchValue, requesterInfo);
    return;
  }
}
```

### 3. 備用解析方案
```dart
// 嘗試直接從message.data讀取
final requestId = message.data['requestId'] as String?;
final searchType = message.data['searchType'] as String?;
final searchValue = message.data['searchValue'] as String?;
final requesterInfo = message.data['requesterInfo'] as Map<String, dynamic>?;

debugPrint('   直接解析 - requestId: $requestId');
debugPrint('   直接解析 - searchType: $searchType');
debugPrint('   直接解析 - searchValue: $searchValue');
debugPrint('   直接解析 - requesterInfo: $requesterInfo');
```

## 修復實現

### 1. 統一處理邏輯
創建 `_processSearchRequest` 方法，將搜索處理邏輯提取出來：

```dart
Future<void> _processSearchRequest(
  dynamic currentUser, 
  String requestId, 
  String searchType, 
  String searchValue, 
  Map<String, dynamic> requesterInfo
) async {
  // 核心搜索邏輯
}
```

### 2. 雙路徑支持
- **路徑1**: 檢測嵌套 `data` 字段並優先使用
- **路徑2**: 直接從 `message.data` 讀取字段
- **容錯**: 支持兩種數據結構，提高兼容性

### 3. 增強調試
- 完整的消息結構輸出
- 數據類型和鍵值檢查
- 分步驟的解析結果顯示
- 清晰的錯誤定位

## 預期結果

修復後的日誌應該顯示：

### 成功解析情況
```
I/flutter: 🔍 [GLOBAL] 收到用戶搜索請求
I/flutter:    消息完整結構: {...}
I/flutter:    消息數據字段: {...}
I/flutter:    消息數據類型: _InternalLinkedHashMap<String, dynamic>
I/flutter:    消息數據鍵值: [id, type, fromUserId, toUserId, data, timestamp, group]
I/flutter:    檢測到嵌套data字段: {requestId: 1750737149076, searchType: name, ...}
I/flutter:    嵌套解析 - requestId: 1750737149076
I/flutter:    嵌套解析 - searchType: name
I/flutter:    嵌套解析 - searchValue: 王丹尼
I/flutter:    嵌套解析 - requesterInfo: {userId: c5bb6c43..., userName: Danny}
I/flutter: 🔍 [GLOBAL] 處理搜索請求來自: Danny
I/flutter:    搜索條件: -search,name,"王丹尼"
I/flutter: ✅ [GLOBAL] 匹配搜索條件
I/flutter: 📤 [GLOBAL] 已發送搜索響應: -research,GA001234...,name,"用戶姓名" 給: Danny
```

### 備用解析情況
如果沒有嵌套結構，則使用直接解析：
```
I/flutter:    直接解析 - requestId: 1750737149076
I/flutter:    直接解析 - searchType: name
I/flutter:    直接解析 - searchValue: 王丹尼
I/flutter:    直接解析 - requesterInfo: {userId: c5bb6c43..., userName: Danny}
```

## 技術要點

### 1. 消息結構診斷
- 使用 `message.toJson()` 查看完整結構
- 檢查 `message.data.runtimeType` 確認數據類型
- 列出 `message.data.keys` 查看可用字段

### 2. 防御性編程
- 多路徑解析支持
- 空值檢查和類型轉換
- 詳細的錯誤日誌

### 3. 向後兼容
- 保持對舊消息格式的支持
- 漸進式錯誤處理
- 不中斷現有功能

## 測試驗證

- ✅ 代碼編譯成功
- ✅ 雙路徑解析邏輯就緒
- ✅ 詳細調試日誌添加
- ⏳ 等待實際運行驗證

這個修復應該能夠解決消息解析問題，並提供足夠的調試信息來定位根本原因。 
