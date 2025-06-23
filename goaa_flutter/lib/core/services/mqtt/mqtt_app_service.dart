import 'package:flutter/foundation.dart';
import 'dart:async';
import 'mqtt_connection_manager.dart';
import 'mqtt_models.dart';
import 'mqtt_topics.dart';
import '../user_id_service.dart';

/// APP 級別的 MQTT 服務
/// 負責管理整個應用的 MQTT 連接和消息分發
class MqttAppService {
  static final MqttAppService _instance = MqttAppService._internal();
  factory MqttAppService() => _instance;
  MqttAppService._internal();

  final MqttConnectionManager _mqttManager = MqttConnectionManager();
  final UserIdService _userIdService = UserIdService();

  // 狀態流控制器
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<GoaaMqttMessage> _friendsMessageController = StreamController<GoaaMqttMessage>.broadcast();
  final StreamController<GoaaMqttMessage> _expensesMessageController = StreamController<GoaaMqttMessage>.broadcast();
  final StreamController<List<OnlineUser>> _onlineUsersController = StreamController<List<OnlineUser>>.broadcast();

  // 在線用戶列表
  final Map<String, OnlineUser> _onlineUsers = {};
  
  // 消息訂閱
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<GoaaMqttMessage>? _messageSubscription;

  // 公開的流
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<GoaaMqttMessage> get friendsMessageStream => _friendsMessageController.stream;
  Stream<GoaaMqttMessage> get expensesMessageStream => _expensesMessageController.stream;
  Stream<List<OnlineUser>> get onlineUsersStream => _onlineUsersController.stream;

  // 狀態獲取器
  bool get isConnected => _mqttManager.isConnected;
  List<OnlineUser> get onlineUsers => _onlineUsers.values.toList();

  /// 初始化 MQTT 服務
  Future<void> initialize() async {
    try {
      debugPrint('🚀 初始化 MQTT App 服務...');
      
      // 獲取用戶信息
      final userId = await _userIdService.getUserId();
      final userCode = await _userIdService.getUserCode();
      final userName = 'User_${userId.substring(0, 8)}';

      // 設置連接監聽
      _setupConnectionListener();
      
      // 設置消息監聽
      _setupMessageListener();

      // 連接到 MQTT
      final connected = await _mqttManager.connect(
        userId: userId,
        userName: userName,
        userCode: userCode,
      );

      if (connected) {
        debugPrint('✅ MQTT App 服務初始化成功');
      } else {
        debugPrint('❌ MQTT App 服務初始化失敗');
      }
    } catch (e) {
      debugPrint('❌ MQTT App 服務初始化異常: $e');
    }
  }

  /// 設置連接狀態監聽
  void _setupConnectionListener() {
    _connectionSubscription?.cancel();
    _connectionSubscription = _mqttManager.connectionStream.listen((isConnected) {
      debugPrint('📡 MQTT 連接狀態: ${isConnected ? "已連接" : "已斷開"}');
      _connectionStatusController.add(isConnected);
      
      if (!isConnected) {
        // 連接斷開時清空在線用戶列表
        _onlineUsers.clear();
        _onlineUsersController.add([]);
      }
    });
  }

  /// 設置消息監聽
  void _setupMessageListener() {
    _messageSubscription?.cancel();
    _messageSubscription = _mqttManager.messageStream.listen((message) {
      _handleMessage(message);
    });
  }

  /// 處理接收到的消息
  void _handleMessage(GoaaMqttMessage message) {
    debugPrint('📨 收到消息: ${message.type.name} from ${message.fromUserId}');

    // 根據消息群組分發到不同的流
    if (message.group == 'friends') {
      _handleFriendsMessage(message);
      _friendsMessageController.add(message);
    } else if (message.group == 'expenses') {
      _handleExpensesMessage(message);
      _expensesMessageController.add(message);
    }
  }

  /// 處理好友群組消息
  void _handleFriendsMessage(GoaaMqttMessage message) {
    switch (message.type) {
      case GoaaMqttMessageType.userOnline:
        _handleUserOnline(message);
        break;
      case GoaaMqttMessageType.userOffline:
        _handleUserOffline(message);
        break;
      case GoaaMqttMessageType.heartbeat:
        _handleUserHeartbeat(message);
        break;
      case GoaaMqttMessageType.friendRequest:
      case GoaaMqttMessageType.friendAccept:
      case GoaaMqttMessageType.friendReject:
        // 這些消息直接轉發給好友控制器處理
        break;
      default:
        break;
    }
  }

  /// 處理帳務群組消息
  void _handleExpensesMessage(GoaaMqttMessage message) {
    // 帳務消息處理邏輯
    debugPrint('💰 處理帳務消息: ${message.type.name}');
  }

  /// 處理用戶上線
  void _handleUserOnline(GoaaMqttMessage message) {
    final data = message.data;
    final user = OnlineUser(
      userId: message.fromUserId,
      userName: data['userName'] ?? '',
      userCode: data['userCode'] ?? '',
      avatar: data['avatar'],
      lastSeen: message.timestamp,
    );
    
    _onlineUsers[user.userId] = user;
    _onlineUsersController.add(onlineUsers);
    debugPrint('👋 用戶上線: ${user.userName}');
  }

  /// 處理用戶離線
  void _handleUserOffline(GoaaMqttMessage message) {
    final userId = message.fromUserId;
    final user = _onlineUsers.remove(userId);
    if (user != null) {
      _onlineUsersController.add(onlineUsers);
      debugPrint('👋 用戶離線: ${user.userName}');
    }
  }

  /// 處理用戶心跳
  void _handleUserHeartbeat(GoaaMqttMessage message) {
    final userId = message.fromUserId;
    final existingUser = _onlineUsers[userId];
    if (existingUser != null) {
      // 更新最後活躍時間
      _onlineUsers[userId] = OnlineUser(
        userId: existingUser.userId,
        userName: existingUser.userName,
        userCode: existingUser.userCode,
        avatar: existingUser.avatar,
        lastSeen: message.timestamp,
      );
      _onlineUsersController.add(onlineUsers);
    }
  }

  /// 發送好友請求
  Future<void> sendFriendRequest({
    required String toUserId,
    required String message,
  }) async {
    if (!isConnected) {
      throw Exception('MQTT 未連接');
    }

    final userId = await _userIdService.getUserId();
    final userCode = await _userIdService.getUserCode();
    final userName = 'User_${userId.substring(0, 8)}';

    // 發送好友請求到目標用戶的個人請求主題
    await _mqttManager.publishMessage(MqttTopics.friendsUserRequests(toUserId), {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fromUserId': userId,
      'fromUserName': userName,
      'fromUserCode': userCode,
      'toUserId': toUserId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 回應好友請求
  Future<void> respondToFriendRequest({
    required String requestId,
    required String fromUserId,
    required bool accept,
  }) async {
    if (!isConnected) {
      throw Exception('MQTT 未連接');
    }

    final userId = await _userIdService.getUserId();
    final userCode = await _userIdService.getUserCode();
    final userName = 'User_${userId.substring(0, 8)}';

    // 發送好友回應到原請求者的個人回應主題
    await _mqttManager.publishMessage(MqttTopics.friendsUserResponses(fromUserId), {
      'id': requestId,
      'fromUserId': fromUserId,
      'toUserId': userId,
      'toUserName': userName,
      'toUserCode': userCode,
      'action': accept ? 'accept' : 'reject',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 訂閱帳務群組
  Future<void> subscribeToExpensesGroup(String groupId) async {
    await _mqttManager.subscribeToExpensesGroup(groupId);
  }

  /// 取消訂閱帳務群組
  Future<void> unsubscribeFromExpensesGroup(String groupId) async {
    await _mqttManager.unsubscribeFromExpensesGroup(groupId);
  }

  /// 重新連接
  Future<void> reconnect() async {
    await disconnect();
    await initialize();
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 斷開 MQTT App 服務...');
    
    _connectionSubscription?.cancel();
    _messageSubscription?.cancel();
    
    await _mqttManager.disconnect();
    
    _onlineUsers.clear();
    _onlineUsersController.add([]);
    _connectionStatusController.add(false);
  }

  /// 清理資源
  void dispose() {
    _connectionSubscription?.cancel();
    _messageSubscription?.cancel();
    
    _connectionStatusController.close();
    _friendsMessageController.close();
    _expensesMessageController.close();
    _onlineUsersController.close();
    
    _mqttManager.dispose();
  }
}
