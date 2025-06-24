# 統一的MQTT搜索消息格式

## 概述
為了避免消息格式混亂和資訊冗餘，統一MQTT搜索相關的消息格式為最簡化版本。

## 搜索請求格式
**主題**: `goaa/search/users/request`
**格式**: `-search,<type>,"<value>"`

```json
{
  "type": "userSearchRequest",
  "requestId": "1750748063377",
  "searchType": "name",
  "searchValue": "王丹尼",
  "fromUserId": "uuid-of-requester"
}
```

### 字段說明
- `type`: 固定值 "userSearchRequest"
- `requestId`: 唯一請求ID，用於匹配響應
- `searchType`: 搜索類型 ("name", "email", "phone")
- `searchValue`: 搜索值
- `fromUserId`: 發起搜索的用戶UUID

## 搜索響應格式
**主題**: `goaa/search/users/response/{requesterId}`
**格式**: `-research,<uuid>,name,"<name>"`

```json
{
  "type": "userSearchResponse",
  "requestId": "1750748063377",
  "userId": "uuid-of-responder",
  "userName": "王丹尼",
  "email": "danny@example.com",
  "phone": "0937498866"
}
```

### 字段說明
- `type`: 固定值 "userSearchResponse"
- `requestId`: 對應的搜索請求ID
- `userId`: 響應用戶的UUID
- `userName`: 響應用戶的姓名
- `email`: 響應用戶的郵箱
- `phone`: 響應用戶的電話

## 設計原則

### 1. 最小化資訊
- 移除所有不必要的包裝和嵌套結構
- 只包含核心必要字段
- 避免重複信息

### 2. 直接發送
- 不使用 `GoaaMqttMessage.toJson()` 包裝
- 直接發送扁平化的JSON結構
- 避免雙重嵌套問題

### 3. 統一格式
- 所有搜索相關消息使用相同的結構模式
- 統一使用UUID作為用戶標識
- 統一字段命名規範

## 實現位置

### 搜索請求發送
- **文件**: `lib/features/friends/services/mqtt_user_search_service.dart`
- **方法**: `searchUsers()`
- **行數**: ~140

### 搜索響應發送
- **文件**: `lib/core/services/mqtt/mqtt_app_service.dart`
- **方法**: `_handleUserSearchRequest()`
- **行數**: ~282

### 搜索響應處理
- **文件**: `lib/features/friends/services/mqtt_user_search_service.dart`
- **方法**: `_handleSearchResponse()`
- **行數**: ~170

## 修改記錄
- **2025-01-18**: 統一所有搜索消息格式
- **移除**: 冗餘的包裝結構和不必要的字段
- **簡化**: 消息結構為最小必要信息
- **統一**: 所有搜索相關服務使用相同格式 
