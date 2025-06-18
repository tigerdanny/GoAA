import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'mqtt_models.dart';

/// MQTT 連接管理器
class MqttConnectionManager {
  static const String _broker = 'broker.emqx.io';
  static const int _port = 1883;
  static const int _keepAlivePeriod = 60;
  static const int _connectionTimeout = 10;

  MqttServerClient? _client;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserCode;

  // 流控制器
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<GoaaMqttMessage> _messageController = StreamController<GoaaMqttMessage>.broadcast();

  // 心跳定時器
  Timer? _heartbeatTimer;

  // Getters
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<GoaaMqttMessage> get messageStream => _messageController.stream;
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  /// 連接到 MQTT 服務器
  Future<bool> connect({
    required String userId,
    required String userName,
    required String userCode,
  }) async {
    try {
      _currentUserId = userId;
      _currentUserName = userName;
      _currentUserCode = userCode;

      // 創建客戶端
      _client = MqttServerClient.withPort(_broker, userId, _port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = _keepAlivePeriod;
      _client!.connectTimeoutPeriod = _connectionTimeout;
      _client!.autoReconnect = true;

      // 設置回調
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onUnsubscribed = _onUnsubscribed;

      // 連接
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(userId)
          .withWillTopic('goaa/users/offline')
          .withWillMessage(jsonEncode({
            'userId': userId,
            'userName': userName,
            'timestamp': DateTime.now().toIso8601String(),
          }))
          .withWillQos(MqttQos.atLeastOnce)
          .startClean()
          .withWillRetain();

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (isConnected) {
        _setupSubscriptions();
        _startHeartbeat();
        await _publishUserOnline();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('MQTT 連接失敗: $e');
      return false;
    }
  }

  /// 斷開連接
  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      
      if (isConnected && _currentUserId != null) {
        await _publishUserOffline();
      }
      
      _client?.disconnect();
    } catch (e) {
      debugPrint('MQTT 斷開連接錯誤: $e');
    }
  }

  /// 發佈消息
  Future<void> publishMessage(String topic, Map<String, dynamic> message) async {
    if (!isConnected) {
      throw Exception('MQTT 未連接');
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(message));
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } catch (e) {
      debugPrint('發佈消息失敗: $e');
      rethrow;
    }
  }

  /// 訂閱主題
  Future<void> subscribeToTopic(String topic) async {
    if (!isConnected) return;
    
    try {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    } catch (e) {
      debugPrint('訂閱主題失敗: $e');
    }
  }

  /// 設置訂閱
  void _setupSubscriptions() {
    if (!isConnected || _currentUserId == null) return;

    // 訂閱全局頻道
    subscribeToTopic('goaa/users/online');
    subscribeToTopic('goaa/users/offline');

    // 訂閱個人頻道
    subscribeToTopic('goaa/users/$_currentUserId/requests');
    subscribeToTopic('goaa/users/$_currentUserId/responses');
    subscribeToTopic('goaa/users/$_currentUserId/messages');

    // 設置消息監聽
    _client!.updates!.listen(_onMessageReceived);
  }

  /// 開始心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (isConnected && _currentUserId != null) {
        await _publishHeartbeat();
      }
    });
  }

  /// 發佈用戶上線
  Future<void> _publishUserOnline() async {
    if (_currentUserId == null) return;

    await publishMessage('goaa/users/online', {
      'userId': _currentUserId,
      'userName': _currentUserName,
      'userCode': _currentUserCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈用戶離線
  Future<void> _publishUserOffline() async {
    if (_currentUserId == null) return;

    await publishMessage('goaa/users/offline', {
      'userId': _currentUserId,
      'userName': _currentUserName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈心跳
  Future<void> _publishHeartbeat() async {
    if (_currentUserId == null) return;

    await publishMessage('goaa/users/heartbeat', {
      'userId': _currentUserId,
      'userName': _currentUserName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 連接成功回調
  void _onConnected() {
    debugPrint('MQTT 連接成功');
    _connectionController.add(true);
  }

  /// 連接斷開回調
  void _onDisconnected() {
    debugPrint('MQTT 連接斷開');
    _connectionController.add(false);
    _heartbeatTimer?.cancel();
  }

  /// 訂閱成功回調
  void _onSubscribed(String topic) {
    debugPrint('訂閱成功: $topic');
  }

  /// 取消訂閱回調
  void _onUnsubscribed(String? topic) {
    debugPrint('取消訂閱: $topic');
  }

  /// 消息接收處理
  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      try {
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (message.payload as MqttPublishMessage).payload.message,
        );

        final data = jsonDecode(payload) as Map<String, dynamic>;
        final mqttMessage = _parseMessage(topic, data);
        
        if (mqttMessage != null) {
          _messageController.add(mqttMessage);
        }
      } catch (e) {
        debugPrint('解析消息失敗: $e');
      }
    }
  }

  /// 解析消息
  GoaaMqttMessage? _parseMessage(String topic, Map<String, dynamic> data) {
    try {
      GoaaMqttMessageType type;
      
      if (topic.contains('/online')) {
        type = GoaaMqttMessageType.userOnline;
      } else if (topic.contains('/offline')) {
        type = GoaaMqttMessageType.userOffline;
      } else if (topic.contains('/heartbeat')) {
        type = GoaaMqttMessageType.heartbeat;
      } else if (topic.contains('/requests')) {
        type = GoaaMqttMessageType.friendRequest;
      } else if (topic.contains('/responses')) {
        if (data['action'] == 'accept') {
          type = GoaaMqttMessageType.friendAccept;
        } else {
          type = GoaaMqttMessageType.friendReject;
        }
      } else if (topic.contains('/messages')) {
        type = GoaaMqttMessageType.message;
      } else {
        return null;
      }

      return GoaaMqttMessage(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        fromUserId: data['userId'] ?? data['fromUserId'] ?? '',
        toUserId: data['toUserId'],
        data: data,
        timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      debugPrint('解析消息失敗: $e');
      return null;
    }
  }

  /// 清理資源
  void dispose() {
    _heartbeatTimer?.cancel();
    _connectionController.close();
    _messageController.close();
    _client?.disconnect();
  }
} 
