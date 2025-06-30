import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import '../../database/repositories/user_repository.dart';

/// MQTT連接狀態
enum GoaaMqttConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// MQTT消息
class GoaaMqttMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;
  final int? qos;

  GoaaMqttMessage({
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

  factory GoaaMqttMessage.fromJson(Map<String, dynamic> json) => GoaaMqttMessage(
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
  GoaaMqttConnectionState _connectionState = GoaaMqttConnectionState.disconnected;
  
  // 配置
  static const String _brokerHost = 'broker.hivemq.com';
  static const int _brokerPort = 1883;
  static const int _keepAlivePeriod = 60;
  static const int _maxConnectionAttempts = 5;
  
  // 用戶標識
  String? _clientId;
  String? _userId;
  
  // 訂閱的主題
  final Set<String> _subscribedTopics = {};
  
  // 消息流
  final StreamController<GoaaMqttMessage> _messageStreamController = 
      StreamController<GoaaMqttMessage>.broadcast();
  
  // 連接狀態流
  final StreamController<GoaaMqttConnectionState> _connectionStateController = 
      StreamController<GoaaMqttConnectionState>.broadcast();
  
  // 重連機制
  Timer? _reconnectTimer;
  int _connectionAttempts = 0;
  bool _shouldReconnect = true;
  
  // 心跳機制
  Timer? _heartbeatTimer;
  
  // 搜索回復事件流
  final StreamController<Map<String, dynamic>> _searchResponseController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters
  GoaaMqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == GoaaMqttConnectionState.connected;
  bool get isConnecting => _connectionState == GoaaMqttConnectionState.connecting;
  String? get clientId => _clientId;
  String? get userId => _userId;
  
  // 流
  Stream<GoaaMqttMessage> get messageStream => _messageStreamController.stream;
  Stream<GoaaMqttConnectionState> get connectionStateStream => _connectionStateController.stream;
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
      
      _client!.keepAlivePeriod = _keepAlivePeriod;
      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId!)
          .withWillTopic(willTopic)
          .withWillMessage(willMessage)
          .withWillQos(MqttQos.atLeastOnce)
          .withWillRetain()
          .startClean();
      
      debugPrint('✅ MQTT客戶端初始化完成');
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

    _updateConnectionState(GoaaMqttConnectionState.connecting);
    _connectionAttempts++;

    try {
      debugPrint('🔗 正在連接MQTT服務器... (嘗試 $_connectionAttempts/$_maxConnectionAttempts)');
      
      final connectResult = await _client!.connect();
      
      if (connectResult != null && connectResult.state == MqttConnectionState.connected) {
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
        _updateConnectionState(GoaaMqttConnectionState.error);
        _scheduleReconnect();
        return false;
      }
    } catch (e) {
      debugPrint('❌ MQTT連接異常: $e');
      _updateConnectionState(GoaaMqttConnectionState.error);
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
      _updateConnectionState(GoaaMqttConnectionState.disconnecting);
      
      // 發送下線消息
      await _publishOfflineStatus();
      
      _client!.disconnect();
    }
    
    _updateConnectionState(GoaaMqttConnectionState.disconnected);
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

  /// 取消訂閱
  Future<bool> unsubscribeFromTopic(String topic) async {
    if (!isConnected) {
      debugPrint('⚠️ MQTT未連接，無法取消訂閱');
      return false;
    }

    try {
      _client!.unsubscribe(topic);
      _subscribedTopics.remove(topic);
      debugPrint('📤 取消訂閱主題: $topic');
      return true;
    } catch (e) {
      debugPrint('❌ 取消訂閱失敗: $e');
      return false;
    }
  }

  /// 訂閱基本主題
  Future<void> _subscribeToBasicTopics() async {
    if (_userId == null) return;

    final basicTopics = [
      'goaa/users/$_userId/messages',      // 私人消息
      'goaa/users/$_userId/notifications', // 通知
      'goaa/friends/requests',             // 好友請求
      'goaa/friends/responses',            // 好友響應
      'goaa/friend/search/request',        // 好友搜索請求（全局）
      'goaa/friend/search/response',       // 好友搜索回復（全局）
      'goaa/groups/+/messages',            // 群組消息（萬用字符）
      'goaa/system/announcements',         // 系統公告
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
    
    final delay = Duration(seconds: _connectionAttempts * 5); // 遞增延遲
    debugPrint('⏰ 將在 ${delay.inSeconds} 秒後重連...');
    
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && !isConnected) {
        connect();
      }
    });
  }

  /// 更新連接狀態
  void _updateConnectionState(GoaaMqttConnectionState newState) {
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
    _updateConnectionState(GoaaMqttConnectionState.connected);
    
    // 設置消息監聽
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (final message in messages) {
        _handleIncomingMessage(message);
      }
    });
  }

  void _onDisconnected() {
    debugPrint('📡 MQTT連接斷開');
    _updateConnectionState(GoaaMqttConnectionState.disconnected);
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

  /// 處理收到的消息
  void _handleIncomingMessage(MqttReceivedMessage<MqttMessage?> receivedMessage) {
    final topic = receivedMessage.topic;
    final payload = MqttPublishPayload.bytesToStringAsString(
        (receivedMessage.payload as MqttPublishMessage).payload.message);
    
    debugPrint('📨 收到MQTT消息 - 主題: $topic, 內容長度: ${payload.length}');
    
    final mqttMessage = GoaaMqttMessage(
      topic: topic,
      payload: payload,
      timestamp: DateTime.now(),
    );
    
    // 發送到消息流
    _messageStreamController.add(mqttMessage);
    
    // 根據主題類型進行初步處理
    _processMessageByTopic(mqttMessage);
  }

  /// 根據主題處理消息
  void _processMessageByTopic(GoaaMqttMessage message) {
    try {
      final topic = message.topic;
      final payload = jsonDecode(message.payload) as Map<String, dynamic>;
      
      if (topic.contains('/friends/')) {
        _processFriendsMessage(topic, payload, message);
      } else if (topic.contains('/groups/')) {
        _processGroupsMessage(topic, payload, message);
      } else if (topic.contains('/notifications')) {
        _processNotificationMessage(topic, payload, message);
      } else if (topic.contains('/system/')) {
        _processSystemMessage(topic, payload, message);
      }
    } catch (e) {
      debugPrint('❌ 處理消息失敗: $e');
    }
  }

  /// 處理好友相關消息
  void _processFriendsMessage(String topic, Map<String, dynamic> payload, GoaaMqttMessage message) {
    debugPrint('👥 處理好友消息: $topic');
    
    // 處理好友搜索請求
    if (topic == 'goaa/friend/search/request') {
      _handleFriendSearchRequest(payload);
    }
    // 處理好友搜索回復
    else if (topic == 'goaa/friend/search/response') {
      _handleFriendSearchResponse(payload);
    }
    // 其他好友相關消息
    else {
      // 通知好友控制器處理其他消息
      debugPrint('📧 其他好友消息: $topic');
    }
  }

  /// 處理好友搜索請求（背景自動處理）
  Future<void> _handleFriendSearchRequest(Map<String, dynamic> payload) async {
    try {
      debugPrint('🔍 收到好友搜索請求');
      
      // 解析搜索請求
      final requestId = payload['requestId'] as String?;
      final publisherUuid = payload['publisherUuid'] as String?;
      final searchType = payload['searchType'] as String?;
      final searchValue = payload['searchValue'] as String?;
      
      if (requestId == null || publisherUuid == null || searchType == null || searchValue == null) {
        debugPrint('❌ 搜索請求數據不完整');
        return;
      }
      
      // 跳過自己發出的搜索請求
      if (publisherUuid == _userId) {
        debugPrint('🔄 跳過自己的搜索請求');
        return;
      }
      
      debugPrint('🔍 處理搜索請求: $searchType = $searchValue (來自: $publisherUuid)');
      
      // 獲取當前用戶信息進行匹配
      final currentUserResult = await _checkLocalUserMatch(searchType, searchValue);
      
      if (currentUserResult != null) {
        debugPrint('✅ 本地用戶匹配成功，發送回復');
        
        // 發送搜索回復
        await publishMessage(
          topic: 'goaa/friend/search/response',
          payload: {
            'requestId': requestId,
            'responderUuid': _userId,
            'searcherUuid': publisherUuid,
            'responderName': currentUserResult['name'],
            'responderUserCode': currentUserResult['userCode'],
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        
        debugPrint('📤 已發送搜索回復給: $publisherUuid');
      } else {
        debugPrint('❌ 本地用戶不匹配搜索條件');
      }
      
    } catch (e) {
      debugPrint('❌ 處理好友搜索請求失敗: $e');
    }
  }

  /// 處理好友搜索回復（轉發給搜索服務）
  void _handleFriendSearchResponse(Map<String, dynamic> payload) {
    try {
      debugPrint('📥 收到好友搜索回復');
      
      final searcherUuid = payload['searcherUuid'] as String?;
      
      // 只處理發給自己的回復
      if (searcherUuid == _userId) {
        debugPrint('📨 這是發給我的搜索回復');
        // 這裡可以通過全局事件或單例服務轉發給搜索服務
        _forwardSearchResponseToService(payload);
      } else {
        debugPrint('📤 這不是發給我的搜索回復，忽略');
      }
      
    } catch (e) {
      debugPrint('❌ 處理好友搜索回復失敗: $e');
    }
  }

  /// 檢查本地用戶是否匹配搜索條件
  Future<Map<String, dynamic>?> _checkLocalUserMatch(String searchType, String searchValue) async {
    try {
      // 導入數據庫服務和用戶倉庫
      final userRepository = UserRepository();
      final currentUser = await userRepository.getCurrentUser();
      
      if (currentUser == null) {
        debugPrint('❌ 沒有當前用戶數據');
        return null;
      }
      
      bool isMatch = false;
      
      switch (searchType) {
        case 'name':
          isMatch = currentUser.name.toLowerCase().contains(searchValue.toLowerCase());
          break;
        case 'email':
          isMatch = currentUser.email?.toLowerCase() == searchValue.toLowerCase();
          break;
        case 'phone':
          isMatch = currentUser.phone == searchValue;
          break;
        default:
          debugPrint('❌ 不支援的搜索類型: $searchType');
          return null;
      }
      
      if (isMatch) {
        return {
          'name': currentUser.name,
          'userCode': currentUser.userCode,
          'email': currentUser.email,
          'phone': currentUser.phone,
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 檢查用戶匹配失敗: $e');
      return null;
    }
  }

  /// 轉發搜索回復給搜索服務（通過全局事件）
  void _forwardSearchResponseToService(Map<String, dynamic> payload) {
    // 創建一個專門的搜索回復事件流
    _searchResponseController.add(payload);
  }

  /// 搜索回復流（供搜索服務監聽）
  Stream<Map<String, dynamic>> get searchResponseStream => _searchResponseController.stream;

  /// 處理群組相關消息
  void _processGroupsMessage(String topic, Map<String, dynamic> payload, GoaaMqttMessage message) {
    debugPrint('👪 處理群組消息: $topic');
    // 通知群組控制器處理
  }

  /// 處理通知消息
  void _processNotificationMessage(String topic, Map<String, dynamic> payload, GoaaMqttMessage message) {
    debugPrint('🔔 處理通知消息: $topic');
    // 顯示通知
  }

  /// 處理系統消息
  void _processSystemMessage(String topic, Map<String, dynamic> payload, GoaaMqttMessage message) {
    debugPrint('⚙️ 處理系統消息: $topic');
    // 處理系統公告等
  }

  /// 釋放資源
  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _messageStreamController.close();
    _connectionStateController.close();
    _searchResponseController.close();
    _client?.disconnect();
    super.dispose();
  }
} 
