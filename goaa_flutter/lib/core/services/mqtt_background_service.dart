import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

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

/// MQTT背景服務 - 獨立運行，全局可用
class MqttBackgroundService extends ChangeNotifier {
  static final MqttBackgroundService _instance = MqttBackgroundService._internal();
  factory MqttBackgroundService() => _instance;
  MqttBackgroundService._internal();

  // MQTT客戶端
  MqttServerClient? _client;
  
  // 連接狀態
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  
  // 配置
  static const String _brokerHost = 'e5ad947c783545e480cd17a9a59672c0.s1.eu.hivemq.cloud';
  static const int _brokerPort = 8883;
  static const String _username = 'goaauser';
  static const String _password = 'goaauser_!QAZ2wsx';
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
  final StreamController<MqttConnectionState> _connectionStateController = 
      StreamController<MqttConnectionState>.broadcast();
  
  // 重連機制
  Timer? _reconnectTimer;
  int _connectionAttempts = 0;
  bool _shouldReconnect = true;
  
  // 心跳機制
  Timer? _heartbeatTimer;
  
  // Getters
  MqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == MqttConnectionState.connected;
  bool get isConnecting => _connectionState == MqttConnectionState.connecting;
  String? get clientId => _clientId;
  String? get userId => _userId;
  
  // 流
  Stream<MqttMessage> get messageStream => _messageStreamController.stream;
  Stream<MqttConnectionState> get connectionStateStream => _connectionStateController.stream;
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  /// 初始化MQTT服務
  Future<void> initialize({
    required String userId,
    String? customClientId,
  }) async {
    debugPrint('🚀 初始化MQTT背景服務...');
    
    _userId = userId;
    _clientId = customClientId ?? 'goaa_${userId}_${const Uuid().v4().substring(0, 8)}';
    
    debugPrint('📱 客戶端ID: $_clientId');
    debugPrint('👤 用戶ID: $_userId');
    
    await _initializeClient();
    
    // 異步啟動連接，不阻塞初始化流程
    unawaited(_startConnection());
  }

  /// 初始化MQTT客戶端
  Future<void> _initializeClient() async {
    try {
      _client = MqttServerClient.withPort(_brokerHost, _clientId!, _brokerPort);
      
      // 配置客戶端
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = _keepAlivePeriod;
      _client!.useWebSocket = false;
      _client!.secure = true; // 使用TLS加密
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;
      _client!.onUnsubscribed = _onUnsubscribed;
      
      // 設置連接消息，包含用戶名和密碼
      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .withWillTopic('goaa/users/$_userId/status')
          .withWillMessage(jsonEncode({
            'status': 'offline',
            'timestamp': DateTime.now().toIso8601String(),
            'clientId': _clientId,
          }))
          .withWillQos(MqttQos.atLeastOnce)
          .withWillRetain()
          .authenticateAs(_username, _password) // 添加認證
          .startClean();
      
      debugPrint('✅ MQTT客戶端初始化完成 (安全連接)');
    } catch (e) {
      debugPrint('❌ MQTT客戶端初始化失敗: $e');
      rethrow;
    }
  }

  /// 啟動連接（異步）
  Future<void> _startConnection() async {
    try {
      await connect();
    } catch (e) {
      debugPrint('❌ MQTT初始連接失敗: $e');
      // 不拋出異常，讓重連機制處理
    }
  }

  /// 連接到MQTT服務器
  Future<bool> connect() async {
    if (_client == null) {
      debugPrint('❌ MQTT客戶端未初始化');
      return false;
    }

    if (isConnected) {
      debugPrint('⚠️ MQTT已經連接');
      return true;
    }

    _updateConnectionState(MqttConnectionState.connecting);
    _connectionAttempts++;

    try {
      debugPrint('🔗 正在連接MQTT服務器... (嘗試 $_connectionAttempts/$_maxConnectionAttempts)');
      
      final status = await _client!.connect();
      
      if (status != null && status.state == MqttConnectionState.connected) {
        debugPrint('✅ MQTT連接成功');
        _connectionAttempts = 0;
        return true;
      } else {
        debugPrint('❌ MQTT連接失敗: $status');
        _updateConnectionState(MqttConnectionState.disconnected);
        _scheduleReconnect();
        return false;
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _updateConnectionState(MqttConnectionState.disconnected);
      _scheduleReconnect();
      return false;
    }
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 正在斷開MQTT連接...');
    
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    if (_client != null && isConnected) {
      _updateConnectionState(MqttConnectionState.disconnecting);
      
      // 發送下線消息
      await _publishOfflineStatus();
      
      _client!.disconnect();
    }
    
    _updateConnectionState(MqttConnectionState.disconnected);
    debugPrint('✅ MQTT連接已斷開');
  }

  /// 發布消息
  Future<bool> publishMessage({
    required String topic,
    required Map<String, dynamic> payload,
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    if (!isConnected) {
      debugPrint('⚠️ MQTT未連接，無法發布消息');
      return false;
    }

    try {
      final message = jsonEncode(payload);
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(message);  // 使用UTF8編碼支持中文
      
      _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
      
      debugPrint('📤 發布消息到 $topic: ${message.length} 字節');
      return true;
    } catch (e) {
      debugPrint('❌ 發布消息失敗: $e');
      return false;
    }
  }

  /// 訂閱主題
  Future<bool> subscribeToTopic(String topic, {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (!isConnected) {
      debugPrint('⚠️ MQTT未連接，將在連接後訂閱主題: $topic');
      return false;
    }

    try {
      _client!.subscribe(topic, qos);
      debugPrint('📥 訂閱主題: $topic');
      return true;
    } catch (e) {
      debugPrint('❌ 訂閱主題失敗: $e');
      return false;
    }
  }

  /// 訂閱基本主題
  Future<void> _subscribeToBasicTopics() async {
    if (_userId == null) return;

    final basicTopics = [
      'goaa/users/$_userId/messages',
      'goaa/users/$_userId/notifications',
      'goaa/friends/requests',
      'goaa/friends/responses',
      'goaa/system/announcements',
    ];

    for (final topic in basicTopics) {
      await subscribeToTopic(topic);
    }
  }

  /// 發送上線狀態
  Future<void> _publishOnlineStatus() async {
    if (_userId == null) return;

    await publishMessage(
      topic: 'goaa/users/$_userId/status',
      payload: {
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
        'version': '1.0.0',
      },
      retain: true,
    );
  }

  /// 發送下線狀態
  Future<void> _publishOfflineStatus() async {
    if (_userId == null) return;

    await publishMessage(
      topic: 'goaa/users/$_userId/status',
      payload: {
        'status': 'offline',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      },
      retain: true,
    );
  }

  /// 開始心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (isConnected && _userId != null) {
        publishMessage(
          topic: 'goaa/users/$_userId/heartbeat',
          payload: {
            'timestamp': DateTime.now().toIso8601String(),
            'clientId': _clientId,
          },
        );
      }
    });
  }

  /// 安排重連
  void _scheduleReconnect() {
    if (!_shouldReconnect || _connectionAttempts >= _maxConnectionAttempts) {
      debugPrint('❌ 達到最大重連次數或不需要重連');
      return;
    }

    _reconnectTimer?.cancel();
    
    final delay = Duration(seconds: _connectionAttempts * 5);
    debugPrint('⏰ 將在 ${delay.inSeconds} 秒後重連...');
    
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && !isConnected) {
        connect();
      }
    });
  }

  /// 更新連接狀態
  void _updateConnectionState(MqttConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      notifyListeners();
      debugPrint('🔄 MQTT連接狀態: $newState');
    }
  }

  // ================================
  // MQTT事件處理
  // ================================

  void _onConnected() {
    debugPrint('🎉 MQTT連接建立');
    _updateConnectionState(MqttConnectionState.connected);
    
    // 設置消息監聽
    _setupMessageListener();
    
    // 發送上線消息
    _publishOnlineStatus();
    
    // 開始心跳
    _startHeartbeat();
    
    // 訂閱基本主題
    _subscribeToBasicTopics();
  }

  void _onDisconnected() {
    debugPrint('📡 MQTT連接斷開');
    _updateConnectionState(MqttConnectionState.disconnected);
    _heartbeatTimer?.cancel();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    _subscribedTopics.add(topic);
    debugPrint('✅ 成功訂閱: $topic');
  }

  void _onSubscribeFail(String topic) {
    debugPrint('❌ 訂閱失敗: $topic');
  }

  void _onUnsubscribed(String? topic) {
    if (topic != null) {
      _subscribedTopics.remove(topic);
      debugPrint('✅ 成功取消訂閱: $topic');
    }
  }

  /// 設置消息監聽
  void _setupMessageListener() {
    try {
      // 使用簡化的消息監聽方式
      _client!.updates!.listen((List messageList) {
        for (final mqttReceivedMessage in messageList) {
          if (mqttReceivedMessage.payload != null) {
            final topic = mqttReceivedMessage.topic;
            final publishMessage = mqttReceivedMessage.payload;
            final payload = MqttPublishPayload.bytesToStringAsString(publishMessage.payload.message);
            
            debugPrint('📨 收到MQTT消息 - 主題: $topic, 內容長度: ${payload.length}');
            
            final message = MqttMessage(
              topic: topic,
              payload: payload,
              timestamp: DateTime.now(),
            );
            
            // 發送到消息流
            _messageStreamController.add(message);
            
            // 處理消息
            _processMessage(message);
          }
        }
      }, onError: (error) {
        debugPrint('❌ MQTT消息監聽錯誤: $error');
      });
    } catch (e) {
      debugPrint('❌ 設置消息監聽失敗: $e');
    }
  }

  /// 處理消息
  void _processMessage(MqttMessage message) {
    try {
      final topic = message.topic;
      
      // 嘗試解析JSON，如果失敗則作為純文本處理
      Map<String, dynamic>? payload;
      try {
        payload = jsonDecode(message.payload) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('⚠️ 無法解析JSON消息，作為純文本處理: $topic');
        payload = {'raw': message.payload};
      }
      
      if (topic.contains('/friends/')) {
        _processFriendsMessage(topic, payload, message);
      } else if (topic.contains('/groups/')) {
        _processGroupsMessage(topic, payload, message);
      } else if (topic.contains('/notifications')) {
        _processNotificationMessage(topic, payload, message);
      } else if (topic.contains('/system/')) {
        _processSystemMessage(topic, payload, message);
      } else {
        debugPrint('📝 收到未分類消息: $topic');
      }
    } catch (e) {
      debugPrint('❌ 處理消息失敗: $e');
    }
  }

  /// 處理好友相關消息
  void _processFriendsMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('👥 處理好友消息: $topic');
    // 通知好友控制器處理
  }

  /// 處理群組相關消息
  void _processGroupsMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('👪 處理群組消息: $topic');
    // 通知群組控制器處理
  }

  /// 處理通知消息
  void _processNotificationMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('🔔 處理通知消息: $topic');
    // 顯示通知
  }

  /// 處理系統消息
  void _processSystemMessage(String topic, Map<String, dynamic> payload, MqttMessage message) {
    debugPrint('⚙️ 處理系統消息: $topic');
    
    // 實現系統消息處理邏輯
    try {
      final messageType = payload['type'] as String?;
      final messageContent = payload['message'] as String?;
      final priority = payload['priority'] as String? ?? 'normal';
      
      switch (messageType) {
        case 'system_announcement':
          debugPrint('📢 系統公告: $messageContent');
          _handleSystemAnnouncement(messageContent, priority);
          break;
          
        case 'maintenance_notice':
          debugPrint('🔧 維護通知: $messageContent');
          _handleMaintenanceNotice(messageContent, payload);
          break;
          
        case 'version_update':
          debugPrint('📱 版本更新通知: $messageContent');
          _handleVersionUpdate(payload);
          break;
          
        case 'server_status':
          debugPrint('🖥️ 服務器狀態: $messageContent');
          _handleServerStatus(payload);
          break;
          
        case 'user_limit_warning':
          debugPrint('⚠️ 用戶限制警告: $messageContent');
          _handleUserLimitWarning(messageContent);
          break;
          
        default:
          debugPrint('❓ 未知系統消息類型: $messageType');
          debugPrint('📝 消息內容: $messageContent');
      }
    } catch (e) {
      debugPrint('❌ 處理系統消息失敗: $e');
    }
  }
  
  /// 處理系統公告
  void _handleSystemAnnouncement(String? message, String priority) {
    if (message == null || message.isEmpty) return;
    
    debugPrint('📢 處理系統公告 (優先級: $priority): $message');
    
    // 根據優先級處理公告
    switch (priority) {
      case 'urgent':
        debugPrint('🚨 緊急公告，需要立即顯示');
        break;
      case 'important':
        debugPrint('⚠️ 重要公告，需要用戶注意');
        break;
      default:
        debugPrint('📝 普通公告，正常顯示');
    }
    
    // 這裡可以發送事件給UI層顯示公告
  }
  
  /// 處理維護通知
  void _handleMaintenanceNotice(String? message, Map<String, dynamic> payload) {
    if (message == null) return;
    
    final startTime = payload['start_time'] as String?;
    final endTime = payload['end_time'] as String?;
    final affectedServices = payload['affected_services'] as List?;
    
    debugPrint('🔧 系統維護通知:');
    debugPrint('   消息: $message');
    debugPrint('   開始時間: $startTime');
    debugPrint('   結束時間: $endTime');
    debugPrint('   影響服務: $affectedServices');
    
    // 這裡可以設置維護模式標記
  }
  
  /// 處理版本更新
  void _handleVersionUpdate(Map<String, dynamic> payload) {
    final version = payload['version'] as String?;
    final isRequired = payload['required'] as bool? ?? false;
    final downloadUrl = payload['download_url'] as String?;
    final releaseNotes = payload['release_notes'] as String?;
    
    debugPrint('📱 版本更新信息:');
    debugPrint('   新版本: $version');
    debugPrint('   是否必需: $isRequired');
    debugPrint('   下載地址: $downloadUrl');
    debugPrint('   更新說明: $releaseNotes');
    
    if (isRequired) {
      debugPrint('⚠️ 這是強制更新');
    }
  }
  
  /// 處理服務器狀態
  void _handleServerStatus(Map<String, dynamic> payload) {
    final status = payload['status'] as String?;
    final load = payload['load'] as double?;
    final availableServices = payload['available_services'] as List?;
    
    debugPrint('🖥️ 服務器狀態:');
    debugPrint('   狀態: $status');
    debugPrint('   負載: $load');
    debugPrint('   可用服務: $availableServices');
    
    // 這裡可以根據服務器狀態調整客戶端行為
  }
  
  /// 處理用戶限制警告
  void _handleUserLimitWarning(String? message) {
    if (message == null) return;
    
    debugPrint('⚠️ 用戶限制警告: $message');
    
    // 這裡可以提示用戶注意使用限制
  }

  /// 釋放資源
  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _messageStreamController.close();
    _connectionStateController.close();
    _client?.disconnect();
    super.dispose();
  }
} 
