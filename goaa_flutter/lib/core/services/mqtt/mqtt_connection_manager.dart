import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'mqtt_models.dart' hide MqttConnectionState;
import 'mqtt_topics.dart';

/// MQTT 連接管理器
class MqttConnectionManager {
  // HiveMQ 雲端服務配置
  static const String _broker = 'e5ad947c783545e480cd17a9a59672c0.s1.eu.hivemq.cloud';
  static const int _port = 8883;
  static const String _username = 'goaauser';
  static const String _password = 'goaauser_!QAZ2wsx';
  static const int _keepAlivePeriod = 60;
  static const int _connectionTimeout = 15;

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

  /// 安全截取字符串，避免RangeError
  String _safeSubstring(String input, int start, int end) {
    if (input.isEmpty) return '';
    final actualEnd = end > input.length ? input.length : end;
    final actualStart = start > actualEnd ? actualEnd : start;
    return input.substring(actualStart, actualEnd);
  }

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

      // 創建客戶端（使用用戶UUID作為 Client ID）
      _client = MqttServerClient.withPort(_broker, userId, _port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = _keepAlivePeriod;
      _client!.connectTimeoutPeriod = _connectionTimeout;
      _client!.autoReconnect = true;
      
      // 啟用安全連接 (TLS/SSL)
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;

      // 設置回調
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onUnsubscribed = _onUnsubscribed;

      // 連接消息配置（包含認證信息和遺囑消息）
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(userId)
          .withWillTopic(MqttTopics.friendUserStatus(userId))
          .withWillMessage(jsonEncode({
            'action': 'offline',
            'userId': userId,
            'userName': userName,
            'timestamp': DateTime.now().toIso8601String(),
          }))
          .withWillQos(MqttQos.atLeastOnce)
          .startClean()
          .withWillRetain()
          .authenticateAs(_username, _password);

      _client!.connectionMessage = connMessage;

      await _client!.connect(_username, _password);

      if (isConnected) {
        // 首先确保在服务器上创建必要的群组主题
        await _ensureGroupsExist();
        _setupMessageListener(); // 只設置消息監聽，不自動訂閱群組
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
      // 🔧 使用UTF-8專用方法發送中文消息
      builder.addUTF8String(jsonEncode(message));
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      
      debugPrint('📤 發送MQTT消息到主題: $topic');
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

  /// 設置好友功能訂閱
  void _setupFriendsSubscriptions() {
    if (!isConnected || _currentUserId == null) return;

    // 訂閱好友功能相關主題
    final friendsTopics = MqttTopics.getFriendsSubscriptionTopics(_currentUserId!);
    for (final topic in friendsTopics) {
      subscribeToTopic(topic);
    }
  }

  /// 設置帳務功能訂閱
  void _setupExpensesSubscriptions(List<String> groupIds) {
    if (!isConnected || _currentUserId == null) return;

    // 訂閱帳務功能相關主題
    final expensesTopics = MqttTopics.getExpensesSubscriptionTopics(_currentUserId!, groupIds);
    for (final topic in expensesTopics) {
      subscribeToTopic(topic);
    }
  }

  /// 確保服務器上存在必要的群組主題
  Future<void> _ensureGroupsExist() async {
    if (!isConnected || _currentUserId == null) return;
    
    try {
      // 發布自己的上線狀態到個人狀態主題
      await _publishUserOnline();
      
      debugPrint('✅ MQTT個人狀態主題初始化完成');
    } catch (e) {
      debugPrint('⚠️ MQTT個人狀態主題初始化失敗: $e');
    }
  }

  /// 設置消息監聽（不自動訂閱群組）
  void _setupMessageListener() {
    if (!isConnected || _currentUserId == null) return;

    // 只設置消息監聽，不自動訂閱群組
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

  /// 發佈用戶上線狀態到個人狀態主題
  Future<void> _publishUserOnline() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendUserStatus(_currentUserId!), {
      'action': 'online',
      'userId': _currentUserId,
      'userName': _currentUserName,
      'userCode': _currentUserCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈用戶離線狀態到個人狀態主題
  Future<void> _publishUserOffline() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendUserStatus(_currentUserId!), {
      'action': 'offline',
      'userId': _currentUserId,
      'userName': _currentUserName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈心跳到個人狀態主題
  Future<void> _publishHeartbeat() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendUserStatus(_currentUserId!), {
      'action': 'heartbeat',
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
        // 🔧 只處理publish消息，忽略ack等控制消息
        if (message.payload is! MqttPublishMessage) {
          debugPrint('⏭️ 跳過非publish消息: ${message.payload.runtimeType}');
          continue;
        }
        
        final topic = message.topic;
        final publishMessage = message.payload as MqttPublishMessage;
        
        // 🔧 使用MQTT專用的UTF-8解碼方法
        final payload = MqttPublishPayload.bytesToStringAsString(publishMessage.payload.message);

        debugPrint('📨 收到MQTT消息 - 主題: $topic, 內容長度: ${payload.length}');
        
        // 檢查負載是否為有效JSON
        if (payload.trim().isEmpty) {
          debugPrint('⚠️ 負載為空，跳過消息');
          continue;
        }
        
        // 🔧 直接解析JSON（UTF-8解碼已正確處理）
        Map<String, dynamic> data;
        try {
          data = jsonDecode(payload) as Map<String, dynamic>;
        } catch (jsonError) {
          debugPrint('❌ JSON解析失敗: $jsonError');
          debugPrint('   負載內容: ${payload.length > 200 ? '${payload.substring(0, 200)}...' : payload}');
          continue;
        }
        
        final mqttMessage = _parseMessage(topic, data);
        
        if (mqttMessage != null) {
          debugPrint('✅ [${mqttMessage.type.identifier}] ${mqttMessage.type.description} - 來自: ${_safeSubstring(mqttMessage.fromUserId, 0, 8)}');
          _messageController.add(mqttMessage);
        } else {
          debugPrint('⚠️ 消息解析結果為空，主題: $topic');
        }
      } catch (e) {
        debugPrint('❌ 解析消息失敗: $e');
        debugPrint('   主題: ${message.topic}');
        debugPrint('   類型: ${message.payload.runtimeType}');
        
        // 提供更詳細的錯誤信息
        if (message.payload is MqttPublishMessage) {
          final publishMessage = message.payload as MqttPublishMessage;
          final bytes = publishMessage.payload.message;
          debugPrint('   負載字節長度: ${bytes.length}');
          debugPrint('   前10個字節: ${bytes.take(10).toList()}');
        }
      }
    }
  }

  /// 解析消息
  GoaaMqttMessage? _parseMessage(String topic, Map<String, dynamic> data) {
    try {
      GoaaMqttMessageType type;
      String group = MqttTopics.getTopicGroup(topic) ?? 'unknown';
      String fromUserId = '';
      
      // 根據主題群組和路徑確定消息類型
      if (MqttTopics.isFriendsGroupTopic(topic)) {
        // 好友功能群組消息解析
        if (MqttTopics.isFriendStatusTopic(topic)) {
          // 從狀態主題中提取用戶ID
          fromUserId = MqttTopics.extractUserIdFromFriendStatusTopic(topic) ?? '';
          
          // 根據 action 字段確定具體的狀態類型
          final action = data['action'] as String?;
          switch (action) {
            case 'online':
              type = GoaaMqttMessageType.userOnline;
              break;
            case 'offline':
              type = GoaaMqttMessageType.userOffline;
              break;
            case 'heartbeat':
              type = GoaaMqttMessageType.heartbeat;
              break;
            default:
              debugPrint('⚠️ 未知的狀態動作: $action');
              return null;
          }
        } else if (MqttTopics.isFriendRequestTopic(topic)) {
          // 從請求主題中提取用戶ID
          fromUserId = MqttTopics.extractUserIdFromFriendRequestTopic(topic) ?? '';
          
          if (topic.endsWith('/requests')) {
            type = GoaaMqttMessageType.friendRequest;
          } else if (topic.endsWith('/responses')) {
            if (data['action'] == 'accept') {
              type = GoaaMqttMessageType.friendAccept;
            } else {
              type = GoaaMqttMessageType.friendReject;
            }
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else if (MqttTopics.isUserSearchTopic(topic)) {
        // 🔍 用戶搜索功能消息解析（特殊處理）
        group = 'friends'; // 歸類到好友群組
        fromUserId = data['fromUserId'] ?? '';
        
        if (MqttTopics.isUserSearchRequestTopic(topic)) {
          type = GoaaMqttMessageType.userSearchRequest;
          debugPrint('🔍 解析搜索請求: $topic');
        } else if (MqttTopics.isUserSearchResponseTopic(topic)) {
          type = GoaaMqttMessageType.userSearchResponse;
          debugPrint('📨 解析搜索響應: $topic');
        } else {
          debugPrint('⚠️ 未知的用戶搜索主題: $topic');
          return null;
        }
      } else if (MqttTopics.isExpensesGroupTopic(topic)) {
        // 帳務功能群組消息解析
        fromUserId = data['userId'] ?? data['fromUserId'] ?? '';
        if (topic.contains('/shares')) {
          type = GoaaMqttMessageType.expenseShare;
        } else if (topic.contains('/updates')) {
          type = GoaaMqttMessageType.expenseUpdate;
        } else if (topic.contains('/settlements')) {
          type = GoaaMqttMessageType.expenseSettlement;
        } else if (topic.contains('/notifications')) {
          type = GoaaMqttMessageType.expenseNotification;
        } else if (topic.contains('/invitations')) {
          type = GoaaMqttMessageType.groupInvitation;
        } else {
          return null;
        }
      } else if (MqttTopics.isSystemGroupTopic(topic)) {
        // 系統功能群組消息解析
        fromUserId = data['userId'] ?? data['fromUserId'] ?? '';
        if (topic.contains('/announcements')) {
          type = GoaaMqttMessageType.systemAnnouncement;
        } else if (topic.contains('/maintenance')) {
          type = GoaaMqttMessageType.systemMaintenance;
        } else {
          return null;
        }
      } else {
        debugPrint('⚠️ 未知的主題群組: $topic');
        return null;
      }

      return GoaaMqttMessage(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        fromUserId: fromUserId.isNotEmpty ? fromUserId : (data['userId'] ?? data['fromUserId'] ?? ''),
        toUserId: data['toUserId'] ?? '', // 🔧 修復：確保不為null
        data: data,
        timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(), // 🔧 修復：使用tryParse避免解析錯誤
        group: group,
      );
    } catch (e) {
      debugPrint('解析消息失敗: $e');
      return null;
    }
  }

  /// 手動訂閱好友功能群組
  Future<void> subscribeToFriendsGroup() async {
    if (!isConnected || _currentUserId == null) return;
    
    _setupFriendsSubscriptions();
    debugPrint('📝 已訂閱好友功能群組');
  }

  /// 訂閱帳務群組（當用戶加入群組時調用）
  Future<void> subscribeToExpensesGroup(String groupId) async {
    if (!isConnected) return;

    await subscribeToTopic(MqttTopics.expensesGroupShares(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupUpdates(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupSettlements(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupMembers(groupId));
  }

  /// 手動訂閱帳務功能群組（所有帳務相關主題）
  Future<void> subscribeToAllExpensesGroups([List<String> groupIds = const []]) async {
    if (!isConnected || _currentUserId == null) return;
    
    _setupExpensesSubscriptions(groupIds);
    debugPrint('📝 已訂閱帳務功能群組');
  }

  /// 取消訂閱帳務群組（當用戶退出群組時調用）
  Future<void> unsubscribeFromExpensesGroup(String groupId) async {
    if (!isConnected) return;

    _client?.unsubscribe(MqttTopics.expensesGroupShares(groupId));
    _client?.unsubscribe(MqttTopics.expensesGroupUpdates(groupId));
    _client?.unsubscribe(MqttTopics.expensesGroupSettlements(groupId));
    _client?.unsubscribe(MqttTopics.expensesGroupMembers(groupId));
  }

  /// 清理資源
  void dispose() {
    _heartbeatTimer?.cancel();
    _connectionController.close();
    _messageController.close();
    _client?.disconnect();
  }
} 
