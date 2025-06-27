# MQTT 中文消息處理指南

## 概述
在GOAA Flutter應用程式中正確處理MQTT中文消息的方法。

## 核心原則

### 📤 發送消息
使用 `addUTF8String("中文內容")` 方法：

```dart
// 發送JSON格式消息（推薦）
Future<bool> publishMessage({
  required String topic,
  required Map<String, dynamic> payload,
  // ...其他參數
}) async {
  final jsonPayload = json.encode(payload);
  final builder = MqttClientPayloadBuilder();
  builder.addUTF8String(jsonPayload);  // ✅ 使用UTF8編碼
  
  _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
}

// 發送純文本消息
Future<bool> publishTextMessage({
  required String topic,
  required String message,
  // ...其他參數
}) async {
  final builder = MqttClientPayloadBuilder();
  builder.addUTF8String(message);  // ✅ 直接發送中文文本
  
  _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
}
```

### 📥 接收消息
使用 `bytesToStringAsString(...)` 方法：

```dart
void _handleIncomingMessage(dynamic receivedMessage) {
  final topic = receivedMessage.topic;
  
  // ✅ 使用 bytesToStringAsString 正確解析UTF8編碼的中文內容
  final payload = MqttPublishPayload.bytesToStringAsString(
    (receivedMessage.payload as MqttPublishMessage).payload.message
  );
  
  debugPrint('📨 收到消息: $topic');
  debugPrint('📝 消息內容: $payload');  // 中文內容會正確顯示
}
```

## 實際使用示例

### 發送中文消息
```dart
// JSON格式中文消息
await mqttService.publishMessage(
  topic: 'goaa/chat/room1',
  payload: {
    'type': 'message',
    'content': '你好！歡迎使用GOAA！',
    'emoji': '🎉🚀💖',
    'sender': 'user123',
    'timestamp': DateTime.now().toIso8601String(),
  },
);

// 純文本中文消息
await mqttService.publishTextMessage(
  topic: 'goaa/notification/user123',
  message: '系統通知：您有新的好友請求！👥',
);
```

### 接收中文消息處理
```dart
// 監聽消息流
mqttService.messageStream.listen((MqttMessage message) {
  try {
    // 嘗試解析為JSON
    final payload = json.decode(message.payload) as Map<String, dynamic>;
    final content = payload['content'] as String?;
    
    if (content != null) {
      print('收到中文消息: $content');  // 正確顯示中文
    }
  } catch (e) {
    // 如果不是JSON，作為純文本處理
    print('收到純文本消息: ${message.payload}');  // 中文也會正確顯示
  }
});
```

## 常見錯誤

### ❌ 錯誤做法
```dart
// 不要使用 addString，可能導致中文亂碼
builder.addString(jsonPayload);  // ❌

// 不要直接使用 payload.toString()
final wrongPayload = receivedMessage.payload.toString();  // ❌
```

### ✅ 正確做法
```dart
// 使用 addUTF8String 確保中文正確編碼
builder.addUTF8String(jsonPayload);  // ✅

// 使用 bytesToStringAsString 正確解碼
final correctPayload = MqttPublishPayload.bytesToStringAsString(
  (receivedMessage.payload as MqttPublishMessage).payload.message
);  // ✅
```

## 測試方法

在 `MqttServiceSimple` 中已提供測試方法：

```dart
// 發送中文測試消息
await mqttService.sendChineseTestMessage();
```

這會發送包含中文內容和emoji的測試消息，用於驗證編碼是否正確。

## 注意事項

1. **始終使用UTF8編碼**：確保中文字符正確傳輸
2. **統一消息格式**：建議使用JSON格式便於解析
3. **錯誤處理**：處理編碼/解碼可能出現的異常
4. **測試驗證**：定期測試中文消息的收發功能

## 相關文件

所有MQTT服務文件都已更新以支持中文消息：

- `lib/core/services/mqtt_service_simple.dart` - 簡化MQTT服務實現
- `lib/core/services/mqtt_background_service.dart` - 背景服務實現
- `lib/core/services/mqtt/mqtt_service.dart` - 完整MQTT服務實現
- `lib/core/services/mqtt_service.dart` - 獨立MQTT服務實現
- `lib/core/services/mqtt_simple.dart` - 基礎MQTT服務實現
- `lib/core/services/mqtt_test_service.dart` - MQTT測試服務實現

## 更新記錄

- ✅ 所有`addString()`調用已更新為`addUTF8String()`
- ✅ 所有消息接收都使用`bytesToStringAsString()`
- ✅ 添加了中文測試消息功能
- ✅ 添加了純文本消息發送方法 
