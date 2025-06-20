# MQTT群組分離功能實現

## 概述
將MQTT中的好友資訊及帳務資訊分為不同的群組，以便更好地組織消息結構，提升系統的可維護性和擴展性。

## 主題結構重新設計

### 1. 好友功能群組 (`goaa/friends`)
- **全局主題:**
  - `goaa/friends/users/online` - 用戶上線通知
  - `goaa/friends/users/offline` - 用戶離線通知
  - `goaa/friends/users/heartbeat` - 心跳消息

- **個人主題:**
  - `goaa/friends/users/{userId}/requests` - 好友請求
  - `goaa/friends/users/{userId}/responses` - 好友響應
  - `goaa/friends/users/{userId}/status` - 用戶狀態

### 2. 帳務功能群組 (`goaa/expenses`)
- **群組主題:**
  - `goaa/expenses/groups/{groupId}/shares` - 分帳分享
  - `goaa/expenses/groups/{groupId}/updates` - 帳務更新
  - `goaa/expenses/groups/{groupId}/settlements` - 結算通知
  - `goaa/expenses/groups/{groupId}/members` - 群組成員變更

- **個人主題:**
  - `goaa/expenses/users/{userId}/notifications` - 帳務通知
  - `goaa/expenses/users/{userId}/invitations` - 群組邀請
  - `goaa/expenses/users/{userId}/settlements` - 個人結算
  - `goaa/expenses/users/{userId}/updates` - 個人帳務更新

### 3. 系統功能群組 (`goaa/system`)
- **系統主題:**
  - `goaa/system/announcements` - 系統公告
  - `goaa/system/maintenance` - 系統維護
  - `goaa/system/users/{userId}/session` - 用戶會話

## 新增文件

### 1. `mqtt_topics.dart`
- 集中管理所有MQTT主題常量
- 提供主題匹配工具方法
- 支持從主題中提取用戶ID和群組ID
- 提供按功能群組獲取訂閱主題的方法

### 2. 新增的消息類型
```dart
// 帳務功能群組
expenseUpdate,        // 帳務更新
expenseSettlement,    // 結算通知
expenseNotification,  // 帳務通知
groupInvitation,      // 群組邀請

// 系統功能群組
systemAnnouncement,   // 系統公告
systemMaintenance,    // 系統維護
```

## 修改的文件

### 1. `mqtt_models.dart`
- 新增 `group` 字段到 `GoaaMqttMessage` 類
- 擴展 `GoaaMqttMessageType` 枚舉
- 更新 `fromJson` 和 `toJson` 方法

### 2. `mqtt_connection_manager.dart`
- 重構訂閱邏輯為分群組訂閱
- 新增 `subscribeToExpensesGroup` 和 `unsubscribeFromExpensesGroup` 方法
- 更新消息解析邏輯以支持群組識別
- 使用新的主題結構發布消息

### 3. `mqtt_service.dart`
- 更新所有發布消息的方法以使用新主題
- 新增帳務功能群組相關方法
- 新增系統功能群組相關方法
- 更新消息過濾邏輯

### 4. `friends_controller.dart`
- 新增群組過濾邏輯，只處理好友功能群組的消息



## 主要功能

### 1. 主題管理工具
- `MqttTopics.isFriendsGroupTopic()` - 檢查是否為好友群組主題
- `MqttTopics.isExpensesGroupTopic()` - 檢查是否為帳務群組主題
- `MqttTopics.isSystemGroupTopic()` - 檢查是否為系統群組主題
- `MqttTopics.getTopicGroup()` - 獲取主題所屬群組

### 2. 訂閱管理
- `_setupFriendsSubscriptions()` - 設置好友功能訂閱
- `_setupExpensesSubscriptions()` - 設置帳務功能訂閱
- `_setupSystemSubscriptions()` - 設置系統功能訂閱

### 3. 動態群組管理
- `subscribeToExpensesGroup(groupId)` - 訂閱帳務群組
- `unsubscribeFromExpensesGroup(groupId)` - 取消訂閱帳務群組

### 4. 新增的帳務功能API
- `publishExpenseShare()` - 發佈帳務分享
- `publishExpenseUpdate()` - 發佈帳務更新
- `publishSettlementNotification()` - 發佈結算通知
- `sendGroupInvitation()` - 發送群組邀請

## 優勢

1. **清晰的組織結構**: 不同功能的消息有明確的分類
2. **擴展性**: 可以輕鬆添加新的功能群組
3. **性能優化**: 只訂閱需要的功能群組主題
4. **安全性**: 不同群組的消息互不干擾
5. **維護性**: 便於管理和調試不同功能的消息

## 使用示例

### 發送好友請求
```dart
await mqttService.sendFriendRequest(targetUserId, userData);
// 發送到: goaa/friends/users/{targetUserId}/requests
```

### 發佈帳務分享
```dart
await mqttService.publishExpenseShare(groupId, expenseData);
// 發送到: goaa/expenses/groups/{groupId}/shares
```

### 動態訂閱帳務群組
```dart
await mqttService.subscribeToExpensesGroup(groupId);
// 訂閱所有該群組的帳務相關主題
```

## 注意事項

1. 所有控制器都已更新為只處理相應群組的消息
2. 舊的主題結構已完全替換為新的群組結構
3. 消息過濾基於 `message.group` 字段
4. 系統自動處理不同群組的消息路由
5. **聊天功能已完全移除** - 不再支持好友間的實時聊天 
