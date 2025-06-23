import 'dart:async';
import 'dart:math';
import 'mqtt/mqtt_models.dart';
import 'mqtt/mqtt_connection_manager.dart';
import 'mqtt/mqtt_user_manager.dart';
import 'mqtt/mqtt_topics.dart';

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
      'group': 'friends',
    };

    await _connectionManager.publishMessage(
      MqttTopics.friendsUserRequests(targetUserId),
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
      'group': 'friends',
    };

    await _connectionManager.publishMessage(
      MqttTopics.friendsUserResponses(fromUserId),
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
      'group': 'friends',
    };

    await _connectionManager.publishMessage(
      MqttTopics.friendsUserResponses(fromUserId),
      messageData,
    );
  }



  /// 搜索在線用戶
  List<OnlineUser> searchOnlineUsers(String query) {
    return _userManager.searchOnlineUsers(query);
  }

  // ==================== 帳務功能群組方法 ====================

  /// 發佈帳務分享
  Future<void> publishExpenseShare(String groupId, Map<String, dynamic> expenseData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.expenseShare.name,
      'fromUserId': _currentUserId!,
      'groupId': groupId,
      'data': expenseData,
      'timestamp': DateTime.now().toIso8601String(),
      'group': 'expenses',
    };

    await _connectionManager.publishMessage(
      MqttTopics.expensesGroupShares(groupId),
      messageData,
    );
  }

  /// 發佈帳務更新
  Future<void> publishExpenseUpdate(String groupId, Map<String, dynamic> updateData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.expenseUpdate.name,
      'fromUserId': _currentUserId!,
      'groupId': groupId,
      'data': updateData,
      'timestamp': DateTime.now().toIso8601String(),
      'group': 'expenses',
    };

    await _connectionManager.publishMessage(
      MqttTopics.expensesGroupUpdates(groupId),
      messageData,
    );
  }

  /// 發佈結算通知
  Future<void> publishSettlementNotification(String groupId, Map<String, dynamic> settlementData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.expenseSettlement.name,
      'fromUserId': _currentUserId!,
      'groupId': groupId,
      'data': settlementData,
      'timestamp': DateTime.now().toIso8601String(),
      'group': 'expenses',
    };

    await _connectionManager.publishMessage(
      MqttTopics.expensesGroupSettlements(groupId),
      messageData,
    );
  }

  /// 發送群組邀請
  Future<void> sendGroupInvitation(String targetUserId, String groupId, Map<String, dynamic> groupData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.groupInvitation.name,
      'fromUserId': _currentUserId!,
      'toUserId': targetUserId,
      'data': {
        'groupId': groupId,
        'groupData': groupData,
        'inviterName': _currentUserName,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'group': 'expenses',
    };

    await _connectionManager.publishMessage(
      MqttTopics.expensesUserInvitations(targetUserId),
      messageData,
    );
  }

  /// 訂閱帳務群組（用戶加入群組時）
  Future<void> subscribeToExpensesGroup(String groupId) async {
    await _connectionManager.subscribeToExpensesGroup(groupId);
  }

  /// 取消訂閱帳務群組（用戶退出群組時）
  Future<void> unsubscribeFromExpensesGroup(String groupId) async {
    await _connectionManager.unsubscribeFromExpensesGroup(groupId);
  }

  // ==================== 系統功能群組方法 ====================

  /// 發佈系統公告
  Future<void> publishSystemAnnouncement(Map<String, dynamic> announcementData) async {
    if (!isConnected || _currentUserId == null) return;

    final messageData = {
      'id': _generateMessageId(),
      'type': GoaaMqttMessageType.systemAnnouncement.name,
      'fromUserId': _currentUserId!,
      'data': announcementData,
      'timestamp': DateTime.now().toIso8601String(),
      'group': 'system',
    };

    await _connectionManager.publishMessage(
      MqttTopics.systemAnnouncements,
      messageData,
    );
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
      // 好友功能群組 - 轉發到應用層
      case GoaaMqttMessageType.friendRequest:
      case GoaaMqttMessageType.friendAccept:
      case GoaaMqttMessageType.friendReject:
      case GoaaMqttMessageType.friendInfoShare:
        return true;
        
      // 帳務功能群組 - 轉發到應用層
      case GoaaMqttMessageType.expenseShare:
      case GoaaMqttMessageType.expenseUpdate:
      case GoaaMqttMessageType.expenseSettlement:
      case GoaaMqttMessageType.expenseNotification:
      case GoaaMqttMessageType.groupInvitation:
        return true;
        
      // 系統功能群組 - 轉發到應用層
      case GoaaMqttMessageType.systemAnnouncement:
      case GoaaMqttMessageType.systemMaintenance:
        return true;
        
      // 基礎系統消息 - 不轉發（由用戶管理器處理）
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
