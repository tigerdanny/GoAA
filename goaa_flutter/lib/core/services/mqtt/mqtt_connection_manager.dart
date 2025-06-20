import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'mqtt_models.dart';
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

      // 連接消息配置（包含認證信息）
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(userId)
          .withWillTopic(MqttTopics.friendsUserOffline)
          .withWillMessage(jsonEncode({
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
        _setupSubscriptions(); // 默認只訂閱好友功能，帳務功能需要另外訂閱
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

  /// 設置系統功能訂閱
  void _setupSystemSubscriptions() {
    if (!isConnected || _currentUserId == null) return;

    // 訂閱系統功能相關主題
    final systemTopics = MqttTopics.getSystemSubscriptionTopics(_currentUserId!);
    for (final topic in systemTopics) {
      subscribeToTopic(topic);
    }
  }

  /// 設置所有訂閱
  void _setupSubscriptions({List<String> userGroupIds = const []}) {
    if (!isConnected || _currentUserId == null) return;

    // 設置各功能群組的訂閱
    _setupFriendsSubscriptions();
    _setupExpensesSubscriptions(userGroupIds);
    _setupSystemSubscriptions();

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

  /// 發佈用戶上線（好友功能群組）
  Future<void> _publishUserOnline() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendsUserOnline, {
      'userId': _currentUserId,
      'userName': _currentUserName,
      'userCode': _currentUserCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈用戶離線（好友功能群組）
  Future<void> _publishUserOffline() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendsUserOffline, {
      'userId': _currentUserId,
      'userName': _currentUserName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 發佈心跳（好友功能群組）
  Future<void> _publishHeartbeat() async {
    if (_currentUserId == null) return;

    await publishMessage(MqttTopics.friendsUserHeartbeat, {
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
      String group = MqttTopics.getTopicGroup(topic) ?? 'unknown';
      
      // 根據主題群組和路徑確定消息類型
      if (MqttTopics.isFriendsGroupTopic(topic)) {
        // 好友功能群組消息解析
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
        } else {
          return null;
        }
      } else if (MqttTopics.isExpensesGroupTopic(topic)) {
        // 帳務功能群組消息解析
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
        if (topic.contains('/announcements')) {
          type = GoaaMqttMessageType.systemAnnouncement;
        } else if (topic.contains('/maintenance')) {
          type = GoaaMqttMessageType.systemMaintenance;
        } else {
          return null;
        }
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
        group: group,
      );
    } catch (e) {
      debugPrint('解析消息失敗: $e');
      return null;
    }
  }

  /// 訂閱帳務群組（當用戶加入群組時調用）
  Future<void> subscribeToExpensesGroup(String groupId) async {
    if (!isConnected) return;

    await subscribeToTopic(MqttTopics.expensesGroupShares(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupUpdates(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupSettlements(groupId));
    await subscribeToTopic(MqttTopics.expensesGroupMembers(groupId));
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
