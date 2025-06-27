import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

/// 簡單的MQTT服務
class MqttSimple extends ChangeNotifier {
  static final MqttSimple _instance = MqttSimple._internal();
  factory MqttSimple() => _instance;
  MqttSimple._internal();

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
  
  // 用戶標識
  String? _clientId;
  String? _userId;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get clientId => _clientId;

  /// 初始化MQTT服務
  Future<void> initialize({required String userId}) async {
    debugPrint('🚀 初始化MQTT簡單服務...');
    
    _userId = userId;
    _clientId = 'goaa_${userId}_${const Uuid().v4().substring(0, 8)}';
    
    debugPrint('📱 客戶端ID: $_clientId');
    debugPrint('🌐 服務器: $_brokerHost:$_brokerPort');
    
    await _createClient();
    
    // 異步連接，不阻塞初始化
    unawaited(_connectInBackground());
  }

  /// 創建客戶端
  Future<void> _createClient() async {
    try {
      _client = MqttServerClient.withPort(_brokerHost, _clientId!, _brokerPort);
      
      // 配置
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 60;
      _client!.useWebSocket = false;
      _client!.secure = true; // TLS
      
      // 事件處理
      _client!.onConnected = () {
        debugPrint('🎉 MQTT已連接');
        _isConnected = true;
        _isConnecting = false;
        notifyListeners();
        _onConnected();
      };
      
      _client!.onDisconnected = () {
        debugPrint('📡 MQTT已斷開');
        _isConnected = false;
        _isConnecting = false;
        notifyListeners();
      };
      
      // 設置連接消息
      final connectMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .authenticateAs(_username, _password)
          .startClean();
      
      // 設置保持活躍時間
      _client!.keepAlivePeriod = 60;
      
      _client!.connectionMessage = connectMessage;
      
      debugPrint('✅ MQTT客戶端創建完成');
    } catch (e) {
      debugPrint('❌ 創建MQTT客戶端失敗: $e');
    }
  }

  /// 背景連接
  Future<void> _connectInBackground() async {
    if (_client == null || _isConnecting || _isConnected) return;
    
    _isConnecting = true;
    notifyListeners();
    
    try {
      debugPrint('🔗 嘗試連接MQTT...');
      final status = await _client!.connect();
      
      if (status?.state != MqttConnectionState.connected) {
        debugPrint('❌ MQTT連接失敗: $status');
        _isConnecting = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// 連接成功後的處理
  void _onConnected() {
    // 發送上線狀態
    _publishOnlineStatus();
    
    // 訂閱測試主題
    _subscribeToTopics();
  }

  /// 發布上線狀態
  void _publishOnlineStatus() {
    if (!_isConnected || _userId == null) return;
    
    try {
      final payload = jsonEncode({
        'status': 'online',
        'timestamp': DateTime.now().toIso8601String(),
        'clientId': _clientId,
      });
      
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(payload);  // 使用UTF8編碼支持中文
      
      _client!.publishMessage(
        'goaa/users/$_userId/status',
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
      
      debugPrint('📤 已發送上線狀態');
    } catch (e) {
      debugPrint('❌ 發送上線狀態失敗: $e');
    }
  }

  /// 訂閱主題
  void _subscribeToTopics() {
    if (!_isConnected || _userId == null) return;
    
    try {
      _client!.subscribe('goaa/users/$_userId/test', MqttQos.atLeastOnce);
      _client!.subscribe('goaa/system/test', MqttQos.atLeastOnce);
      debugPrint('📥 已訂閱測試主題');
    } catch (e) {
      debugPrint('❌ 訂閱主題失敗: $e');
    }
  }

  /// 發送測試消息
  Future<void> sendTestMessage() async {
    if (!_isConnected || _userId == null) {
      debugPrint('⚠️ MQTT未連接，無法發送測試消息');
      return;
    }
    
    try {
      final payload = jsonEncode({
        'type': 'test',
        'message': 'Hello from GOAA!',
        'timestamp': DateTime.now().toIso8601String(),
        'from': _clientId,
      });
      
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(payload);  // 使用UTF8編碼支持中文
      
      _client!.publishMessage(
        'goaa/users/$_userId/test',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      
      debugPrint('📤 已發送測試消息');
    } catch (e) {
      debugPrint('❌ 發送測試消息失敗: $e');
    }
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 斷開MQTT連接...');
    
    if (_client != null && _isConnected) {
      try {
        // 發送離線狀態
        if (_userId != null) {
          final payload = jsonEncode({
            'status': 'offline',
            'timestamp': DateTime.now().toIso8601String(),
            'clientId': _clientId,
          });
          
          final builder = MqttClientPayloadBuilder();
          builder.addUTF8String(payload);  // 使用UTF8編碼支持中文
          
          _client!.publishMessage(
            'goaa/users/$_userId/status',
            MqttQos.atLeastOnce,
            builder.payload!,
            retain: true,
          );
        }
        
        _client!.disconnect();
        
      } catch (e) {
        debugPrint('❌ 斷開連接失敗: $e');
      }
    }
    
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  /// 釋放資源
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
} 
