import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

/// MQTT連接狀態
enum MqttConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// MQTT消息
class MqttMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;

  MqttMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 簡化的MQTT服務 - 背景運行，全局可用
class MqttServiceSimple extends ChangeNotifier {
  static final MqttServiceSimple _instance = MqttServiceSimple._internal();
  factory MqttServiceSimple() => _instance;
  MqttServiceSimple._internal();

  // MQTT客戶端
  MqttServerClient? _client;
  
  // 連接狀態
  MqttConnectionStatus _connectionState = MqttConnectionStatus.disconnected;
  
  // 配置
  static const String _brokerHost = 'broker.emqx.io';
  static const int _brokerPort = 1883;
  static const String _username = 'testuser';
  static const String _password = 'testpass';
  static const int _keepAlivePeriod = 60;
  static const int _maxConnectionAttempts = 5;
  
  // 用戶標識
  String? _clientId;
  String? _userId;
  
  // 訂閱的主題
  final Set<String> _subscribedTopics = {};
  
  // 消息流
  final StreamController<MqttMessage> _messageStreamController = 
      StreamController<MqttMessage>.broadcast();
  
  // 連接狀態流
  final StreamController<MqttConnectionStatus> _connectionStateController = 
      StreamController<MqttConnectionStatus>.broadcast();
  
  // 重連機制
  Timer? _reconnectTimer;
  int _connectionAttempts = 0;
  bool _shouldReconnect = true;
  
  // 心跳機制
  Timer? _heartbeatTimer;
  
  // Getters
  MqttConnectionStatus get connectionState => _connectionState;
  bool get isConnected => _connectionState == MqttConnectionStatus.connected;
  bool get isConnecting => _connectionState == MqttConnectionStatus.connecting;
  String? get clientId => _clientId;
  String? get userId => _userId;
  
  // 流
  Stream<MqttMessage> get messageStream => _messageStreamController.stream;
  Stream<MqttConnectionStatus> get connectionStateStream => _connectionStateController.stream;
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  /// 初始化MQTT服務
  Future<void> initialize({
    required String userId,
    String? customClientId,
  }) async {
    debugPrint('🚀 初始化MQTT服務...');
    
    _userId = userId;
    _clientId = customClientId ?? 'goaa_${userId}_${const Uuid().v4().substring(0, 8)}';
    
    debugPrint('📱 客戶端ID: $_clientId');
    debugPrint('👤 用戶ID: $_userId');
    
    // 實現初始化邏輯
    try {
      // 創建MQTT客戶端
      _client = MqttServerClient(_brokerHost, _clientId!);
      _client!.port = _brokerPort;
      _client!.keepAlivePeriod = _keepAlivePeriod;
      _client!.connectTimeoutPeriod = 5000;
      _client!.autoReconnect = false; // 我們自己控制重連
      
      // 設置連接消息
      final connMess = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .withWillTopic('goaa/status/$_userId')
          .withWillMessage('offline')
          .withWillQos(MqttQos.atLeastOnce);
      
      if (_username.isNotEmpty && _password.isNotEmpty) {
        connMess.authenticateAs(_username, _password);
      }
      
      _client!.connectionMessage = connMess;
      
      // 設置事件監聽器
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;
      _client!.onUnsubscribed = _onUnsubscribed;
      
      debugPrint('✅ MQTT服務初始化完成');
    } catch (e) {
      debugPrint('❌ MQTT服務初始化失敗: $e');
      rethrow;
    }
  }

  /// 連接到MQTT服務器
  Future<bool> connect() async {
    debugPrint('🔗 連接MQTT服務器...');
    
    if (_client == null) {
      debugPrint('❌ MQTT客戶端未初始化');
      return false;
    }
    
    try {
      _updateConnectionState(MqttConnectionStatus.connecting);
      _connectionAttempts++;
      
      // 實現連接邏輯
      await _client!.connect();
      
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('🎉 MQTT連接成功');
        _connectionAttempts = 0;
        _updateConnectionState(MqttConnectionStatus.connected);
        
        // 設置消息監聽器
        _client!.updates?.listen((List messageList) {
          for (final mqttReceivedMessage in messageList) {
            _handleIncomingMessage(mqttReceivedMessage);
          }
        });
        
        // 訂閱基本主題
        await _subscribeToBasicTopics();
        
        // 發送上線狀態
        await _publishOnlineStatus();
        
        // 開始心跳
        _startHeartbeat();
        
        return true;
      } else {
        debugPrint('❌ MQTT連接失敗: ${_client!.connectionStatus}');
        _updateConnectionState(MqttConnectionStatus.error);
        
        // 安排重連
        if (_connectionAttempts < _maxConnectionAttempts) {
          _scheduleReconnect();
        }
        
        return false;
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _updateConnectionState(MqttConnectionStatus.error);
      
      // 安排重連
      if (_connectionAttempts < _maxConnectionAttempts) {
        _scheduleReconnect();
      }
      
      return false;
    }
  }

  /// 處理收到的消息
  void _handleIncomingMessage(dynamic receivedMessage) {
    try {
      final topic = receivedMessage.topic;
      
      // 使用 bytesToStringAsString 正確解析UTF8編碼的中文內容
      final payload = MqttPublishPayload.bytesToStringAsString(
        (receivedMessage.payload as MqttPublishMessage).payload.message
      );
      
      debugPrint('📨 收到消息: $topic');
      debugPrint('📝 消息內容: $payload');
      
      final message = MqttMessage(
        topic: topic,
        payload: payload,
        timestamp: DateTime.now(),
      );
      
      // 發送到消息流
      _messageStreamController.add(message);
      
      // 根據主題處理消息
      _processMessageByTopic(message);
    } catch (e) {
      debugPrint('❌ 處理消息失敗: $e');
    }
  }

  /// 根據主題處理消息
  void _processMessageByTopic(MqttMessage message) {
    try {
      final payload = json.decode(message.payload) as Map<String, dynamic>;
      final topic = message.topic;
      
      if (topic.startsWith('goaa/friends/')) {
        _processFriendsMessage(topic, payload, message);
      } else if (topic.startsWith('goaa/groups/')) {
        _processGroupsMessage(topic, payload, message);
      } else if (topic.startsWith('goaa/notifications/')) {
        _processNotificationMessage(topic, payload, message);
      } else if (topic.startsWith('goaa/system/')) {
        _processSystemMessage(topic, payload, message);
      }
    } catch (e) {
      debugPrint('❌ 解析消息失敗: $e');
    }
  }

  /// 更新連接狀態
  void _updateConnectionState(MqttConnectionStatus newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      notifyListeners();
    }
  }

  /// 連接成功回調
  void _onConnected() {
    debugPrint('🎉 MQTT連接成功回調');
    _updateConnectionState(MqttConnectionStatus.connected);
  }

  /// 斷開連接回調
  void _onDisconnected() {
    debugPrint('📡 MQTT斷開連接回調');
    _updateConnectionState(MqttConnectionStatus.disconnected);
    
    // 如果需要重連且未達到最大嘗試次數
    if (_shouldReconnect && _connectionAttempts < _maxConnectionAttempts) {
      _scheduleReconnect();
    }
  }

  /// 訂閱成功回調
  void _onSubscribed(String topic) {
    debugPrint('📥 訂閱成功: $topic');
    _subscribedTopics.add(topic);
  }

  /// 訂閱失敗回調
  void _onSubscribeFail(String topic) {
    debugPrint('❌ 訂閱失敗: $topic');
  }

  /// 取消訂閱回調
  void _onUnsubscribed(String? topic) {
    if (topic != null) {
      debugPrint('📤 取消訂閱: $topic');
      _subscribedTopics.remove(topic);
    }
  }

  /// 發布消息
  Future<bool> publishMessage({
    required String topic,
    required Map<String, dynamic> payload,
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    debugPrint('📤 發布消息到 $topic');
    
    if (_client == null || !isConnected) {
      debugPrint('❌ MQTT未連接，無法發布消息');
      return false;
    }
    
    try {
      // 實現發布消息邏輯 - 使用UTF8編碼支持中文
      final jsonPayload = json.encode(payload);
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(jsonPayload);
      
      _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
      
      debugPrint('✅ 消息發布成功');
      return true;
    } catch (e) {
      debugPrint('❌ 發布消息失敗: $e');
      return false;
    }
  }

  /// 發布純文本消息 - 專門處理中文內容
  Future<bool> publishTextMessage({
    required String topic,
    required String message,
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    debugPrint('📤 發布文本消息到 $topic: $message');
    
    if (_client == null || !isConnected) {
      debugPrint('❌ MQTT未連接，無法發布消息');
      return false;
    }
    
    try {
      // 使用UTF8編碼發送中文內容
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(message);
      
      _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
      
      debugPrint('✅ 文本消息發布成功');
      return true;
    } catch (e) {
      debugPrint('❌ 發布文本消息失敗: $e');
      return false;
    }
  }

  /// 訂閱主題
  Future<bool> subscribeToTopic(String topic, {MqttQos qos = MqttQos.atLeastOnce}) async {
    debugPrint('📥 訂閱主題: $topic');
    
    if (_client == null || !isConnected) {
      debugPrint('❌ MQTT未連接，無法訂閱');
      return false;
    }
    
    try {
      // 實現訂閱邏輯
      _client!.subscribe(topic, qos);
      return true;
    } catch (e) {
      debugPrint('❌ 訂閱主題失敗: $e');
      return false;
    }
  }

  /// 取消訂閱
  Future<bool> unsubscribeFromTopic(String topic) async {
    debugPrint('📤 取消訂閱主題: $topic');
    
    if (_client == null || !isConnected) {
      debugPrint('❌ MQTT未連接，無法取消訂閱');
      return false;
    }
    
    try {
      // 實現取消訂閱邏輯
      _client!.unsubscribe(topic);
      _subscribedTopics.remove(topic);
      return true;
    } catch (e) {
      debugPrint('❌ 取消訂閱失敗: $e');
      return false;
    }
  }

  /// 訂閱基本主題
  Future<void> _subscribeToBasicTopics() async {
    debugPrint('📥 訂閱基本主題...');
    
    if (_userId == null) return;
    
    // 實現訂閱基本主題邏輯
    final topics = [
      'goaa/friends/$_userId',
      'goaa/groups/$_userId',
      'goaa/notifications/$_userId',
      'goaa/system/broadcast',
    ];
    
    for (final topic in topics) {
      await subscribeToTopic(topic);
    }
  }

  /// 發送上線狀態
  Future<void> _publishOnlineStatus() async {
    debugPrint('📤 發送上線狀態...');
    
    if (_userId == null) return;
    
    // 實現發送上線狀態邏輯
    await publishMessage(
      topic: 'goaa/status/$_userId',
      payload: {
        'userId': _userId,
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      },
      retain: true,
    );
  }

  /// 發送下線狀態
  Future<void> _publishOfflineStatus() async {
    debugPrint('📤 發送下線狀態...');
    
    if (_userId == null) return;
    
    // 實現發送下線狀態邏輯
    await publishMessage(
      topic: 'goaa/status/$_userId',
      payload: {
        'userId': _userId,
        'status': 'offline',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      },
      retain: true,
    );
  }

  /// 開始心跳
  void _startHeartbeat() {
    debugPrint('💓 開始心跳...');
    
    // 實現心跳邏輯
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected && _userId != null) {
        publishMessage(
          topic: 'goaa/heartbeat/$_userId',
          payload: {
            'userId': _userId,
            'timestamp': DateTime.now().toIso8601String(),
            'clientId': _clientId,
          },
          qos: MqttQos.atMostOnce,
        );
      } else {
        timer.cancel();
      }
    });
  }

  /// 安排重連
  void _scheduleReconnect() {
    debugPrint('🔄 安排重連...');
    
    if (!_shouldReconnect) return;
    
    // 實現重連邏輯
    _reconnectTimer?.cancel();
    
    final delay = Duration(seconds: _connectionAttempts * 2); // 指數退避
    debugPrint('⏰ ${delay.inSeconds}秒後重連 (嘗試 $_connectionAttempts/$_maxConnectionAttempts)');
    
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && _connectionAttempts < _maxConnectionAttempts) {
        connect();
      }
    });
  }

  /// 處理好友相關消息
  void _processFriendsMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('👥 處理好友消息: $topic');
    
    // 實現好友消息處理邏輯
    try {
      final messageType = payload['type'] as String?;
      
      switch (messageType) {
        case 'friend_request':
          debugPrint('📥 收到好友請求');
          break;
        case 'friend_request_accepted':
          debugPrint('✅ 好友請求被接受');
          break;
        case 'friend_request_rejected':
          debugPrint('❌ 好友請求被拒絕');
          break;
        case 'friend_online':
          debugPrint('🟢 好友上線');
          break;
        case 'friend_offline':
          debugPrint('⚫ 好友下線');
          break;
        default:
          debugPrint('❓ 未知好友消息類型: $messageType');
      }
    } catch (e) {
      debugPrint('❌ 處理好友消息失敗: $e');
    }
  }

  /// 處理群組相關消息
  void _processGroupsMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('👪 處理群組消息: $topic');
    
    // 實現群組消息處理邏輯
    try {
      final messageType = payload['type'] as String?;
      
      switch (messageType) {
        case 'group_invite':
          debugPrint('📧 收到群組邀請');
          break;
        case 'group_message':
          debugPrint('💬 收到群組消息');
          break;
        case 'group_member_joined':
          debugPrint('➕ 新成員加入群組');
          break;
        case 'group_member_left':
          debugPrint('➖ 成員離開群組');
          break;
        default:
          debugPrint('❓ 未知群組消息類型: $messageType');
      }
    } catch (e) {
      debugPrint('❌ 處理群組消息失敗: $e');
    }
  }

  /// 處理通知消息
  void _processNotificationMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('🔔 處理通知消息: $topic');
    
    // 實現通知消息處理邏輯
    try {
      final messageType = payload['type'] as String?;
      final title = payload['title'] as String?;
      final body = payload['body'] as String?;
      
      switch (messageType) {
        case 'system_notification':
          debugPrint('🔔 系統通知: $title - $body');
          break;
        case 'friend_notification':
          debugPrint('👥 好友通知: $title - $body');
          break;
        case 'group_notification':
          debugPrint('👪 群組通知: $title - $body');
          break;
        default:
          debugPrint('❓ 未知通知類型: $messageType');
      }
    } catch (e) {
      debugPrint('❌ 處理通知消息失敗: $e');
    }
  }

  /// 處理系統消息
  void _processSystemMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('⚙️ 處理系統消息: $topic');
    
    // 實現系統消息處理邏輯
    try {
      final messageType = payload['type'] as String?;
      
      switch (messageType) {
        case 'system_announcement':
          debugPrint('📢 系統公告: ${payload['message']}');
          break;
        case 'maintenance_notice':
          debugPrint('🔧 維護通知: ${payload['message']}');
          break;
        case 'version_update':
          debugPrint('📱 版本更新: ${payload['message']}');
          break;
        default:
          debugPrint('❓ 未知系統消息類型: $messageType');
      }
    } catch (e) {
      debugPrint('❌ 處理系統消息失敗: $e');
    }
  }

  /// 發送中文測試消息
  Future<void> sendChineseTestMessage() async {
    if (!isConnected || _userId == null) {
      debugPrint('❌ 無法發送測試消息：未連接或用戶ID為空');
      return;
    }

    // 測試JSON格式的中文消息
    await publishMessage(
      topic: 'goaa/test/$_userId/json',
      payload: {
        'type': 'test',
        'message': '你好世界！這是一個中文測試消息。',
        'emoji': '🎉🚀💖',
        'timestamp': DateTime.now().toIso8601String(),
        'from': _userId,
      },
    );

    // 測試純文本中文消息
    await publishTextMessage(
      topic: 'goaa/test/$_userId/text',
      message: '純文本中文消息：歡迎使用GOAA應用程式！🎊',
    );

    debugPrint('✅ 中文測試消息已發送');
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 斷開MQTT連接...');
    
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    _updateConnectionState(MqttConnectionStatus.disconnecting);
    
    try {
      // 實現斷開連接邏輯
      await _publishOfflineStatus();
      
      if (_client != null) {
        _client!.disconnect();
      }
      
      _updateConnectionState(MqttConnectionStatus.disconnected);
      debugPrint('✅ MQTT連接已斷開');
    } catch (e) {
      debugPrint('❌ 斷開連接失敗: $e');
    }
  }

  /// 釋放資源
  @override
  void dispose() {
    disconnect();
    _messageStreamController.close();
    _connectionStateController.close();
    super.dispose();
  }
}
