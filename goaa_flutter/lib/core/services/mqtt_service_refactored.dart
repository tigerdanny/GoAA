import 'dart:async';
import 'dart:math';
import 'mqtt/mqtt_models.dart';
import 'mqtt/mqtt_connection_manager.dart';
import 'mqtt/mqtt_user_manager.dart';

/// MQTT 服務類 - 重構版
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal() {
    _connectionManager = MqttConnectionManager();
    _userManager = MqttUserManager(_connectionManager);
    _setupMessageHandling();
  }

  // 組件
  late final MqttConnectionManager _connectionManager;
  late final MqttUserManager _userManager;

  // 當前用戶信息
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserCode;

  // 消息流控制器
  final StreamController<GoaaMqttMessage> _messageController = 
      StreamController<GoaaMqttMessage>.broadcast();

  // Getters
  bool get isConnected => _connectionManager.isConnected;
  String? get currentUserId => _currentUserId;
  List<OnlineUser> get onlineUsers => _userManager.onlineUsers;

  // Streams
  Stream<GoaaMqttMessage> get messageStream => _messageController.stream;
  Stream<List<OnlineUser>> get onlineUsersStream => _userManager.onlineUsersStream;
  Stream<bool> get connectionStream => _connectionManager.connectionStream;

  /// 連接到 MQTT 服務器
  Future<bool> connect({
    required String userId,
    required String userName,
    required String userCode,
  }) async {
    _currentUserId = userId;
    _currentUserName = userName;
    _currentUserCode = userCode;

    return await _connectionManager.connect(
      userId: userId,
      userName: userName,
      userCode: userCode,
    );
  }

  /// 斷開連接
  Future<void> disconnect() async {
    await _connectionManager.disconnect();
    _currentUserId = null;
    _currentUserName = null;
    _currentUserCode = null;
  }

  /// 發送好友請求
  Future<void> sendFriendRequest(String targetUserId, Map<String, dynamic> userData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.friendRequest.name,
      'fromUserId': _currentUserId!,
      'toUserId': targetUserId,
      'data': {
        'userName': _currentUserName,
        'userCode': _currentUserCode,
        'userData': userData,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _connectionManager.publishMessage(
      'goaa/users/$targetUserId/requests',
      messageData,
    );
  }

  /// 接受好友請求
  Future<void> acceptFriendRequest(String fromUserId) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.friendAccept.name,
      'fromUserId': _currentUserId!,
      'toUserId': fromUserId,
      'data': {
        'action': 'accept',
        'userName': _currentUserName,
        'userCode': _currentUserCode,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _connectionManager.publishMessage(
      'goaa/users/$fromUserId/responses',
      messageData,
    );
  }

  /// 拒絕好友請求
  Future<void> rejectFriendRequest(String fromUserId) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.friendReject.name,
      'fromUserId': _currentUserId!,
      'toUserId': fromUserId,
      'data': {
        'action': 'reject',
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _connectionManager.publishMessage(
      'goaa/users/$fromUserId/responses',
      messageData,
    );
  }

  /// 發送消息給好友
  Future<void> sendMessageToFriend(String friendUserId, String message, {String? type}) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.message.name,
      'fromUserId': _currentUserId!,
      'toUserId': friendUserId,
      'data': {
        'message': message,
        'messageType': type ?? 'text',
        'userName': _currentUserName,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _connectionManager.publishMessage(
      'goaa/users/$friendUserId/messages',
      messageData,
    );
  }

  /// 搜索在線用戶
  List<OnlineUser> searchOnlineUsers(String query) {
    return _userManager.searchOnlineUsers(query);
  }

  /// 設置消息處理
  void _setupMessageHandling() {
    _connectionManager.messageStream.listen((message) {
      // 忽略自己發送的消息
      if (message.fromUserId == _currentUserId) return;

      // 用戶管理器已經處理了用戶相關消息，這裡只處理應用層消息
      if (_shouldForwardToApp(message.type)) {
        _messageController.add(message);
      }
    });
  }

  /// 判斷是否應該轉發到應用層
  bool _shouldForwardToApp(GoaaMqttMessageType type) {
    switch (type) {
      case GoaaMqttMessageType.friendRequest:
      case GoaaMqttMessageType.friendAccept:
      case GoaaMqttMessageType.friendReject:
      case GoaaMqttMessageType.message:
      case GoaaMqttMessageType.expenseShare:
        return true;
      case GoaaMqttMessageType.userOnline:
      case GoaaMqttMessageType.userOffline:
      case GoaaMqttMessageType.heartbeat:
        return false;
    }
  }

  /// 生成消息 ID
  String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  /// 清理資源
  void dispose() {
    _messageController.close();
    _connectionManager.dispose();
    _userManager.dispose();
  }
} 
