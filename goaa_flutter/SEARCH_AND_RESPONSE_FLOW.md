# 好友搜索和響應流程設計

## 概述
本文檔描述了 GoAA Flutter 應用中好友搜索和響應的完整流程，包括搜索請求格式、響應格式和用戶界面設計。

## 重要原則

### 1. UUID 統一使用
- **所有用戶ID一律使用UUID格式**
- `userId` 和 `userCode` 統一使用同一個UUID值
- 響應格式中的uuid部分使用完整的UUID

### 2. 響應即匹配原則
- **只有發送搜索的人才能收到research響應**
- **收到回應即代表有匹配**，無需額外的匹配驗證
- 搜索服務收到任何響應都視為有效匹配結果

## 搜索請求流程

### 1. 搜索請求格式
用戶可以通過三種方式搜索好友：

#### 姓名搜索
```
格式: -search,name,"王丹尼"
實際消息:
{
  "requestId": "時間戳",
  "searchType": "name",
  "searchValue": "王丹尼",
  "requesterInfo": {
    "userId": "a8555520400643aeafb1f30cb03f23f6", // UUID
    "userName": "搜索者姓名"
  }
}
```

#### 信箱搜索
```
格式: -search,email,"xxx@xdgsdmi.com.dd"
實際消息:
{
  "requestId": "時間戳",
  "searchType": "email", 
  "searchValue": "xxx@xdgsdmi.com.dd",
  "requesterInfo": {
    "userId": "a8555520400643aeafb1f30cb03f23f6", // UUID
    "userName": "搜索者姓名"
  }
}
```

#### 手機搜索
```
格式: -search,phone,"0937498866"
實際消息:
{
  "requestId": "時間戳",  
  "searchType": "phone",
  "searchValue": "0937498866",
  "requesterInfo": {
    "userId": "a8555520400643aeafb1f30cb03f23f6", // UUID
    "userName": "搜索者姓名"
  }
}
```

### 2. 搜索匹配邏輯
系統會根據搜索類型進行精確或模糊匹配：

- **姓名匹配**: 支持包含匹配（雙向）
- **信箱匹配**: 精確匹配（不區分大小寫）
- **手機匹配**: 精確匹配（忽略空格、括號、短劃線）

### 3. 自我搜索過濾
- 系統會自動跳過用戶自己的搜索請求
- 比較 `requesterInfo.userId` 與當前用戶的UUID
- 如果相同則跳過處理，避免自己回應自己的搜索

## 搜索響應流程

### 1. 搜索響應格式
當用戶匹配搜索條件時，會發送響應：

```
格式: -research,uuid,name,"王丹尼"
實際消息:
{
  "requestId": "對應的請求ID",
  "responseFormat": "-research,a8555520400643aeafb1f30cb03f23f6,name,\"王丹尼\"",
  "userInfo": {
    "userId": "a8555520400643aeafb1f30cb03f23f6", // 統一使用UUID
    "userName": "王丹尼",
    "email": "wang@example.com",
    "phone": "0912345678"
  }
}
```

### 2. 響應處理邏輯
- **響應目標**: 只發送給搜索發起者（`toUserId` = 搜索請求的 `fromUserId`）
- **響應即匹配**: 搜索服務收到任何響應都直接視為匹配結果
- **無需二次驗證**: 不需要在客戶端再次檢查匹配條件
- **結果收集**: 設置5秒超時等待期，收集所有響應

### 3. MQTT主題設計
- **搜索請求主題**: `goaa/user/search/request` (廣播)
- **搜索響應主題**: `goaa/user/search/response/{requesterId}` (點對點)

## 用戶界面設計

### 1. 搜索結果顯示
- 使用Radio按鈕選擇用戶
- 顯示用戶名稱和部分UUID（前8位）
- 支持選擇後發送好友請求

### 2. 隱私保護
- UUID顯示：只顯示前8個字符，如 `a8555520...`
- 完整UUID僅用於內部處理和MQTT通信
- 用戶界面友好的顯示格式

## 技術實現要點

### 1. UUID一致性
```dart
// 統一使用userCode作為UUID
final responseMessage = GoaaMqttMessage(
  fromUserId: currentUser.userCode, // UUID
  toUserId: requesterId, // UUID
  data: {
    'userInfo': {
      'userId': currentUser.userCode, // 統一使用UUID
      'userName': currentUser.name,
      // 移除重複的userCode字段
    },
  },
);
```

### 2. 響應處理簡化
```dart
void _handleSearchResponse(GoaaMqttMessage message) {
  // 收到響應即代表匹配，直接處理
  final result = UserSearchResult.fromJson(userInfo);
  resultsList.add(result);
  // 無需額外的匹配驗證
}
```

### 3. 自我過濾機制
```dart
// 在全局服務中過濾自己的搜索請求
if (requesterId == currentUser.userCode) {
  debugPrint('⏭️ [GLOBAL] 跳過自己的搜索請求');
  return;
}
```

## 錯誤處理

### 1. 網絡異常
- MQTT連接失敗時返回空結果
- 避免拋出異常導致應用崩潰
- 提供重連機制

### 2. 超時處理
- 搜索請求設置5秒超時
- 超時後返回已收集的結果
- 清理相關資源

### 3. 數據格式錯誤
- 驗證必要字段存在性
- 提供詳細的調試日誌
- 優雅降級處理

## 調試和監控

### 1. 關鍵日誌點
- 搜索請求發送
- 搜索響應接收
- 匹配條件檢查
- UUID一致性驗證

### 2. 性能監控
- 搜索響應時間
- 匹配成功率
- 網絡連接狀態

這個設計確保了搜索功能的可靠性、隱私性和用戶體驗的一致性。

## 流程示例

### 完整搜索流程：
1. 用戶在AddFriendDialog選擇搜索類型並輸入
2. 系統發送 `-search,name,"王丹尼"` 格式的請求
3. 所有匹配的用戶回應 `-research,uuid,name,"王丹尼"` 格式
4. SearchResultsDialog顯示所有匹配結果
5. 用戶選擇一個結果並發送好友請求

### 錯誤處理：
- 網絡連接失敗
- 搜索超時（5秒）
- 無匹配結果
- 輸入格式錯誤

## 更新日誌
- 2024-01-XX: 重新設計搜索請求格式為 `-search,type,"value"`
- 2024-01-XX: 重新設計響應格式為 `-research,uuid,name,"value"`  
- 2024-01-XX: 新增Radio按鈕選擇界面
- 2024-01-XX: 優化UUID顯示（部分隱藏） 
