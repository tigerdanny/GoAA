import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:goaa_flutter/core/services/mqtt_service.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';

/// 聊天消息模型
class ChatMessage {
  final String id;
  final String message;
  final String senderId;
  final String? senderName;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderId,
    this.senderName,
    required this.timestamp,
    required this.isMe,
  });
}

/// 聊天控制器
class ChatController extends ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final String friendUserId;
  final String friendUserName;
  
  // 消息列表
  final List<ChatMessage> _messages = [];
  
  // 連接狀態
  bool _isConnected = false;
  
  // 訂閱
  StreamSubscription<GoaaMqttMessage>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  ChatController({
    required this.friendUserId,
    required this.friendUserName,
  }) {
    _setupSubscriptions();
  }

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;

  /// 設置訂閱
  void _setupSubscriptions() {
    // 監聽消息
    _messageSubscription = _mqttService.messageStream.listen((message) {
      if (message.type == GoaaMqttMessageType.message &&
          (message.fromUserId == friendUserId || message.toUserId == friendUserId)) {
        _addMessage(ChatMessage(
          id: message.id,
          message: message.data['message'] ?? '',
          senderId: message.fromUserId,
          senderName: message.data['userName'],
          timestamp: message.timestamp,
          isMe: message.fromUserId == _mqttService.currentUserId,
        ));
      }
    });

    // 監聽連接狀態
    _connectionSubscription = _mqttService.connectionStream.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });

    // 設置初始連接狀態
    _isConnected = _mqttService.isConnected;
  }

  /// 發送消息
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || !_isConnected) return;

    // 立即添加到本地列表
    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      senderId: _mqttService.currentUserId ?? '',
      senderName: 'Me',
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    _addMessage(chatMessage);

    // 發送到 MQTT
    try {
      await _mqttService.sendMessageToFriend(friendUserId, message);
    } catch (e) {
      debugPrint('發送消息失敗: $e');
      // 可以在這裡添加錯誤處理，比如標記消息為發送失敗
    }
  }

  /// 添加消息
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  /// 清除聊天記錄
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
} 
