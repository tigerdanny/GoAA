import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

/// 簡化的MQTT測試服務
class MqttTestService extends ChangeNotifier {
  static final MqttTestService _instance = MqttTestService._internal();
  factory MqttTestService() => _instance;
  MqttTestService._internal();

  // MQTT客戶端
  MqttServerClient? _client;
  
  // 連接狀態
  bool _isConnected = false;
  bool _isConnecting = false;
  
  // HiveMQ Cloud配置
  static const String _brokerHost = 'e5ad947c783545e480cd17a9a59672c0.s1.eu.hivemq.cloud';
  static const int _brokerPort = 8883;
  static const String _username = 'goaauser';
  static const String _password = 'goaauser_!QAZ2wsx';
  static const int _keepAlivePeriod = 60;
  
  // 用戶標識
  String? _clientId;
  String? _userId;
  
  // 消息流
  final StreamController<Map<String, dynamic>> _messageStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // 重連機制
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _connectionAttempts = 0;
  bool _shouldReconnect = true;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get clientId => _clientId;
  String? get userId => _userId;
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  /// 初始化MQTT服務
  Future<void> initialize({required String userId}) async {
    debugPrint('🚀 初始化MQTT測試服務...');
    
    _userId = userId;
    _clientId = 'goaa_test_${userId}_${const Uuid().v4().substring(0, 8)}';
    
    debugPrint('📱 客戶端ID: $_clientId');
    debugPrint('👤 用戶ID: $_userId');
    debugPrint('🌐 服務器: $_brokerHost:$_brokerPort');
    
    await _initializeClient();
    
    // 異步啟動連接
    unawaited(_connectAsync());
  }

  /// 初始化MQTT客戶端
  Future<void> _initializeClient() async {
    try {
      _client = MqttServerClient.withPort(_brokerHost, _clientId!, _brokerPort);
      
      // 配置客戶端
      _client!.logging(on: kDebugMode);
      _client!.useWebSocket = false;
      _client!.secure = true; // 使用TLS
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;
      
      // 設置連接消息
      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .authenticateAs(_username, _password)
          .startClean();
      
      // 設置保持活躍時間
      _client!.keepAlivePeriod = _keepAlivePeriod;
      
      debugPrint('✅ MQTT客戶端初始化完成');
    } catch (e) {
      debugPrint('❌ MQTT客戶端初始化失敗: $e');
      rethrow;
    }
  }

  /// 異步連接
  Future<void> _connectAsync() async {
    try {
      await connect();
    } catch (e) {
      debugPrint('❌ MQTT異步連接失敗: $e');
    }
  }

  /// 連接到MQTT服務器
  Future<bool> connect() async {
    if (_client == null) {
      debugPrint('❌ MQTT客戶端未初始化');
      return false;
    }

    if (_isConnected) {
      debugPrint('⚠️ MQTT已經連接');
      return true;
    }

    if (_isConnecting) {
      debugPrint('⚠️ MQTT正在連接中');
      return false;
    }

    _isConnecting = true;
    _connectionAttempts++;
    notifyListeners();

    try {
      debugPrint('🔗 正在連接MQTT服務器... (嘗試 $_connectionAttempts)');
      debugPrint('🔐 使用TLS連接到 $_brokerHost:$_brokerPort');
      
      final status = await _client!.connect();
      
      if (status?.state == MqttConnectionState.connected) {
        debugPrint('✅ MQTT連接成功!');
        _isConnected = true;
        _isConnecting = false;
        _connectionAttempts = 0;
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ MQTT連接失敗: $status');
        _isConnecting = false;
        notifyListeners();
        _scheduleReconnect();
        return false;
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _isConnecting = false;
      notifyListeners();
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
    
    if (_client != null && _isConnected) {
      await _publishOfflineStatus();
      _client!.disconnect();
    }
    
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
    debugPrint('✅ MQTT連接已斷開');
  }

  /// 發布消息
  Future<bool> publishMessage({
    required String topic,
    required Map<String, dynamic> payload,
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    if (!_isConnected) {
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
    if (!_isConnected) {
      debugPrint('⚠️ MQTT未連接，無法訂閱主題');
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
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isConnected && _userId != null) {
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
    if (!_shouldReconnect || _connectionAttempts >= 3) {
      debugPrint('❌ 達到最大重連次數或不需要重連');
      return;
    }

    _reconnectTimer?.cancel();
    
    final delay = Duration(seconds: _connectionAttempts * 10);
    debugPrint('⏰ 將在 ${delay.inSeconds} 秒後重連...');
    
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && !_isConnected && !_isConnecting) {
        connect();
      }
    });
  }

  // ================================
  // MQTT事件處理
  // ================================

  void _onConnected() {
    debugPrint('🎉 MQTT連接已建立');
    _isConnected = true;
    _isConnecting = false;
    notifyListeners();
    
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
    debugPrint('📡 MQTT連接已斷開');
    _isConnected = false;
    _isConnecting = false;
    _heartbeatTimer?.cancel();
    notifyListeners();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    debugPrint('✅ 成功訂閱: $topic');
  }

  void _onSubscribeFail(String topic) {
    debugPrint('❌ 訂閱失敗: $topic');
  }

  /// 設置消息監聽
  void _setupMessageListener() {
    try {
      _client!.updates!.listen((List messageList) {
        for (final mqttReceivedMessage in messageList) {
          if (mqttReceivedMessage.payload != null) {
            final topic = mqttReceivedMessage.topic;
            final publishMessage = mqttReceivedMessage.payload;
            final payload = MqttPublishPayload.bytesToStringAsString(publishMessage.payload.message);
            
            debugPrint('📨 收到MQTT消息 - 主題: $topic');
            debugPrint('📝 消息內容: $payload');
            
            // 發送到消息流
            _messageStreamController.add({
              'topic': topic,
              'payload': payload,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }
        }
      }, onError: (error) {
        debugPrint('❌ MQTT消息監聽錯誤: $error');
      });
    } catch (e) {
      debugPrint('❌ 設置消息監聽失敗: $e');
    }
  }

  /// 訂閱基本主題
  Future<void> _subscribeToBasicTopics() async {
    if (_userId == null) return;

    final basicTopics = [
      'goaa/users/$_userId/test',
      'goaa/system/test',
    ];

    for (final topic in basicTopics) {
      await subscribeToTopic(topic);
    }
  }

  /// 發送測試消息
  Future<void> sendTestMessage() async {
    await publishMessage(
      topic: 'goaa/users/$_userId/test',
      payload: {
        'type': 'test',
        'message': 'Hello from GOAA!',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      },
    );
  }

  /// 釋放資源
  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _messageStreamController.close();
    _client?.disconnect();
    super.dispose();
  }
} 
