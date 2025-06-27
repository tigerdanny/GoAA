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
  final int? qos;

  MqttMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
    this.qos,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
    'qos': qos,
  };

  factory MqttMessage.fromJson(Map<String, dynamic> json) => MqttMessage(
    topic: json['topic'] as String,
    payload: json['payload'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    qos: json['qos'] as int?,
  );
}

/// 獨立MQTT服務 - 背景運行，全局可用
class MqttService extends ChangeNotifier {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // MQTT客戶端
  MqttServerClient? _client;
  
  // 連接狀態
  MqttConnectionStatus _connectionState = MqttConnectionStatus.disconnected;
  
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
    
    await _initializeClient();
    await connect();
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
      
      // 設置遺囑消息（當客戶端異常斷開時發送）
      final willTopic = 'goaa/users/$_userId/status';
      final willMessage = jsonEncode({
        'status': 'offline',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      });
      
      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .withWillTopic(willTopic)
          .withWillMessage(willMessage)
          .withWillQos(MqttQos.atLeastOnce)
          .authenticateAs(_username, _password) // 添加認證
          .withWillRetain()
          .startClean();
      
      // 設置保持活躍時間
      _client!.keepAlivePeriod = _keepAlivePeriod;
      
      debugPrint('✅ MQTT客戶端初始化完成 (安全連接)');
    } catch (e) {
      debugPrint('❌ MQTT客戶端初始化失敗: $e');
      rethrow;
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

    _updateConnectionState(MqttConnectionStatus.connecting);
    _connectionAttempts++;

    try {
      debugPrint('🔗 正在連接MQTT服務器... (嘗試 $_connectionAttempts/$_maxConnectionAttempts)');
      
      final connectResult = await _client!.connect();
      
      if (connectResult?.state == MqttConnectionState.connected) {
        debugPrint('✅ MQTT連接成功');
        _connectionAttempts = 0;
        
        // 發送上線消息
        await _publishOnlineStatus();
        
        // 開始心跳
        _startHeartbeat();
        
        // 訂閱基本主題
        await _subscribeToBasicTopics();
        
        return true;
      } else {
        debugPrint('❌ MQTT連接失敗: $connectResult');
        _updateConnectionState(MqttConnectionStatus.error);
        _scheduleReconnect();
        return false;
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _updateConnectionState(MqttConnectionStatus.error);
      _scheduleReconnect();
      return false;
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

  /// 發送上線狀態
  Future<void> _publishOnlineStatus() async {
    if (!isConnected || _userId == null) return;
    
    try {
      final payload = jsonEncode({
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      });
      
      await publishMessage('goaa/users/$_userId/status', payload, retain: true);
      debugPrint('📤 已發送上線狀態');
    } catch (e) {
      debugPrint('❌ 發送上線狀態失敗: $e');
    }
  }

  /// 訂閱基本主題
  Future<void> _subscribeToBasicTopics() async {
    if (!isConnected || _userId == null) return;
    
    try {
      await subscribe('goaa/users/$_userId/requests');
      await subscribe('goaa/users/$_userId/messages');
      await subscribe('goaa/system/announcements');
      debugPrint('📥 已訂閱基本主題');
    } catch (e) {
      debugPrint('❌ 訂閱基本主題失敗: $e');
    }
  }

  /// 開始心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        _sendHeartbeat();
      } else {
        timer.cancel();
      }
    });
  }

  /// 發送心跳
  void _sendHeartbeat() {
    if (!isConnected || _userId == null) return;
    
    try {
      final payload = jsonEncode({
        'type': 'heartbeat',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      });
      
      publishMessage('goaa/users/$_userId/heartbeat', payload);
    } catch (e) {
      debugPrint('❌ 發送心跳失敗: $e');
    }
  }

  /// 安排重連
  void _scheduleReconnect() {
    if (!_shouldReconnect || _connectionAttempts >= _maxConnectionAttempts) {
      debugPrint('⛔ 達到最大重連次數或不需要重連');
      return;
    }

    final delay = Duration(seconds: _connectionAttempts * 2);
    debugPrint('⏰ 將在 ${delay.inSeconds} 秒後重連...');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      if (!isConnected && _shouldReconnect) {
        debugPrint('🔄 執行自動重連...');
        await connect();
      }
    });
  }

  /// 發布消息
  Future<void> publishMessage(String topic, String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) async {
    if (!isConnected || _client == null) {
      debugPrint('⚠️ MQTT未連接，無法發送消息');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      
      _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
      debugPrint('📤 已發送消息到 $topic');
    } catch (e) {
      debugPrint('❌ 發送消息失敗: $e');
    }
  }

  /// 訂閱主題
  Future<void> subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (!isConnected || _client == null) {
      debugPrint('⚠️ MQTT未連接，無法訂閱主題');
      return;
    }

    try {
      _client!.subscribe(topic, qos);
      debugPrint('📥 已訂閱主題: $topic');
    } catch (e) {
      debugPrint('❌ 訂閱主題失敗: $e');
    }
  }



  /// 取消訂閱
  Future<void> unsubscribe(String topic) async {
    if (!isConnected || _client == null) {
      debugPrint('⚠️ MQTT未連接，無法取消訂閱');
      return;
    }

    try {
      _client!.unsubscribe(topic);
      _subscribedTopics.remove(topic);
      debugPrint('📤 已取消訂閱: $topic');
    } catch (e) {
      debugPrint('❌ 取消訂閱失敗: $e');
    }
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 斷開MQTT連接...');
    
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    _updateConnectionState(MqttConnectionStatus.disconnecting);
    
    if (_client != null && isConnected) {
      try {
        // 發送離線狀態
        if (_userId != null) {
          final payload = jsonEncode({
            'status': 'offline',
            'timestamp': DateTime.now().toIso8601String(),
            'clientId': _clientId,
          });
          
          await publishMessage('goaa/users/$_userId/status', payload, retain: true);
        }
        
        _client!.disconnect();
      } catch (e) {
        debugPrint('❌ 斷開連接失敗: $e');
      }
    }
    
    _updateConnectionState(MqttConnectionStatus.disconnected);
  }

  /// 清理資源
  @override
  void dispose() {
    disconnect();
    _messageStreamController.close();
    _connectionStateController.close();
    super.dispose();
  }
}
