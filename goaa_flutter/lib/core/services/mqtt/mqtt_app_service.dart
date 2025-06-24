import 'package:flutter/foundation.dart';
import 'dart:async';
import 'mqtt_connection_manager.dart';
import 'mqtt_models.dart';
import 'mqtt_topics.dart' as topics;
import '../user_id_service.dart';
import '../../database/repositories/user_repository.dart';

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

  /// 安全截取字符串，避免RangeError
  String _safeSubstring(String input, int start, int end) {
    if (input.isEmpty) return '';
    final actualEnd = end > input.length ? input.length : end;
    final actualStart = start > actualEnd ? actualEnd : start;
    return input.substring(actualStart, actualEnd);
  }

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
    debugPrint('📨 [${message.type.identifier}] ${message.type.description} - 來自: ${_safeSubstring(message.fromUserId, 0, 8)}');

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
      case GoaaMqttMessageType.userSearchRequest:
        // 🔧 全局處理用戶搜索請求，無需進入好友頁面
        _handleUserSearchRequest(message);
        break;
      case GoaaMqttMessageType.friendRequest:
      case GoaaMqttMessageType.friendAccept:
      case GoaaMqttMessageType.friendReject:
      case GoaaMqttMessageType.userSearchResponse:
        // 這些消息直接轉發給好友控制器處理
        break;
      default:
        break;
    }
  }

  /// 處理帳務群組消息
  void _handleExpensesMessage(GoaaMqttMessage message) {
    // 帳務消息處理邏輯
    debugPrint('💰 [${message.type.identifier}] ${message.type.description}');
  }

  /// 處理用戶上線
  void _handleUserOnline(GoaaMqttMessage message) {
    final data = message.data;
    final user = OnlineUser(
      userId: message.fromUserId,
      userName: data['userName'] ?? '',
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
        avatar: existingUser.avatar,
        lastSeen: message.timestamp,
      );
      _onlineUsersController.add(onlineUsers);
    }
  }

  /// 🔧 全局處理用戶搜索請求（無需進入好友頁面）
  Future<void> _handleUserSearchRequest(GoaaMqttMessage message) async {
    try {
      debugPrint('🔍 [GLOBAL] 收到用戶搜索請求');
      debugPrint('   消息完整結構: ${message.toJson()}');
      debugPrint('   消息數據字段: ${message.data}');
      debugPrint('   消息數據類型: ${message.data.runtimeType}');
      debugPrint('   消息數據鍵值: ${message.data.keys.toList()}');
      
      final userRepository = UserRepository();
      final currentUser = await userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ [GLOBAL] 無法獲取當前用戶信息');
        return;
      }
      
      // 檢查數據結構
      final dataField = message.data['data'];
      if (dataField != null) {
        debugPrint('   檢測到嵌套data字段: $dataField');
        final nestedData = dataField as Map<String, dynamic>;
        final requestId = nestedData['requestId'] as String?;
        final searchType = nestedData['searchType'] as String?;
        final searchValue = nestedData['searchValue'] as String?;
        final fromUserId = nestedData['fromUserId'] as String?;
        
        debugPrint('   嵌套解析 - requestId: $requestId');
        debugPrint('   嵌套解析 - searchType: $searchType');
        debugPrint('   嵌套解析 - searchValue: $searchValue');
        debugPrint('   嵌套解析 - fromUserId: $fromUserId');
        
        // 如果嵌套數據存在，使用嵌套數據
        if (requestId != null && searchType != null && searchValue != null && fromUserId != null) {
          await _processSearchRequest(currentUser, requestId, searchType, searchValue, fromUserId);
          return;
        }
      }
      
      // 嘗試直接從message.data讀取
      final requestId = message.data['requestId'] as String?;
      final searchType = message.data['searchType'] as String?;
      final searchValue = message.data['searchValue'] as String?;
      final fromUserId = message.data['fromUserId'] as String?;
      
      debugPrint('   直接解析 - requestId: $requestId');
      debugPrint('   直接解析 - searchType: $searchType');
      debugPrint('   直接解析 - searchValue: $searchValue');
      debugPrint('   直接解析 - fromUserId: $fromUserId');
      
      if (requestId == null || searchType == null || searchValue == null || fromUserId == null) {
        debugPrint('❌ [GLOBAL] 搜索請求格式錯誤');
        debugPrint('   缺少字段: requestId=${requestId == null}, searchType=${searchType == null}, searchValue=${searchValue == null}, fromUserId=${fromUserId == null}');
        return;
      }
      
      await _processSearchRequest(currentUser, requestId, searchType, searchValue, fromUserId);
      
    } catch (e) {
      debugPrint('❌ [GLOBAL] 處理搜索請求失敗: $e');
    }
  }

  /// 處理搜索請求的核心邏輯
  Future<void> _processSearchRequest(
    dynamic currentUser, 
    String requestId, 
    String searchType, 
    String searchValue, 
    String fromUserId
  ) async {
    // 不要回應自己的搜索請求
    if (fromUserId == currentUser.userCode) {
      debugPrint('⏭️ [GLOBAL] 跳過自己的搜索請求');
      return;
    }
    
    debugPrint('🔍 [GLOBAL] 處理搜索請求來自: $fromUserId');
    debugPrint('   搜索條件: -search,$searchType,"$searchValue"');
    
    // 檢查是否匹配搜索條件
    final isMatch = _checkSearchMatch(currentUser, searchType, searchValue);
    
    if (isMatch) {
      debugPrint('✅ [GLOBAL] 匹配搜索條件');
      
      // 發布搜索響應到MQTT - 最簡化格式
      await _mqttManager.publishMessage(
        topics.MqttTopics.userSearchResponse(fromUserId),
        {
          'type': 'userSearchResponse',
          'requestId': requestId,
          'userId': currentUser.userCode,
          'userName': currentUser.name,
          'email': currentUser.email,
          'phone': currentUser.phone,
        },
      );
      
      debugPrint('📤 [GLOBAL] 已發送搜索響應給: $fromUserId，用戶: ${currentUser.name}');
    } else {
      debugPrint('❌ [GLOBAL] 不匹配搜索條件');
    }
  }

  /// 檢查搜索匹配
  bool _checkSearchMatch(dynamic currentUser, String searchType, String searchValue) {
    final searchValueLower = searchValue.toLowerCase().trim();
    
    debugPrint('🔍 [MATCH] 開始匹配檢查');
    debugPrint('   當前用戶名: "${currentUser.name}"');
    debugPrint('   搜索類型: $searchType');
    debugPrint('   搜索值: "$searchValue"');
    debugPrint('   搜索值(小寫): "$searchValueLower"');
    
    switch (searchType) {
      case 'name':
        final userName = (currentUser.name ?? '').toLowerCase();
        debugPrint('   用戶名(小寫): "$userName"');
        final contains1 = userName.contains(searchValueLower);
        final contains2 = searchValueLower.contains(userName);
        debugPrint('   用戶名包含搜索值: $contains1');
        debugPrint('   搜索值包含用戶名: $contains2');
        final result = contains1 || contains2;
        debugPrint('   最終匹配結果: $result');
        return result;
      
      case 'email':
        final userEmail = (currentUser.email ?? '').toLowerCase();
        debugPrint('   用戶郵箱(小寫): "$userEmail"');
        final result = userEmail == searchValueLower;
        debugPrint('   最終匹配結果: $result');
        return result;
      
      case 'phone':
        final userPhone = (currentUser.phone ?? '').replaceAll(RegExp(r'[\s\-\(\)]'), '');
        final cleanSearchPhone = searchValue.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        debugPrint('   用戶電話(清理後): "$userPhone"');
        debugPrint('   搜索電話(清理後): "$cleanSearchPhone"');
        final result = userPhone == cleanSearchPhone;
        debugPrint('   最終匹配結果: $result');
        return result;
      
      default:
        debugPrint('   未知搜索類型，返回false');
        return false;
    }
  }

  /// 發送好友請求（第一階段：簡單通知）
  Future<void> sendFriendRequest({
    required String toUserId,
    required String message,
  }) async {
    if (!isConnected) {
      throw Exception('MQTT 未連接');
    }

    final userId = await _userIdService.getUserId();
    final userName = 'User_${userId.substring(0, 8)}';

    // 第一階段：只發送基本信息（姓名或UUID）
    await _mqttManager.publishMessage(topics.MqttTopics.friendsUserRequests(toUserId), {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fromUserId': userId,
      'fromUserName': userName,
      'toUserId': toUserId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'stage': 'request', // 標記為請求階段
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
    final userName = 'User_${userId.substring(0, 8)}';

    if (accept) {
      // 第二階段：同意時發送完整個人信息
      await _sendCompleteUserInfo(requestId, fromUserId, userId, userName);
    } else {
      // 拒絕時只發送簡單回應
      await _mqttManager.publishMessage(topics.MqttTopics.friendsUserResponses(fromUserId), {
        'id': requestId,
        'fromUserId': fromUserId,
        'toUserId': userId,
        'toUserName': userName,
        'action': 'reject',
        'timestamp': DateTime.now().toIso8601String(),
        'stage': 'response',
      });
    }
  }

  /// 發送完整用戶信息（第二階段）
  Future<void> _sendCompleteUserInfo(
    String requestId,
    String fromUserId,
    String userId,
    String userName,
  ) async {
    final userCode = await _userIdService.getUserCode();
    
    // 獲取當前用戶的完整信息
    final userRepository = UserRepository();
    final currentUser = await userRepository.getCurrentUser();
    
    // 發送完整個人信息到原請求者
    await _mqttManager.publishMessage(topics.MqttTopics.friendsUserResponses(fromUserId), {
      'id': requestId,
      'fromUserId': fromUserId,
      'toUserId': userId,
      'action': 'accept',
      'stage': 'info_share',
      'timestamp': DateTime.now().toIso8601String(),
      // 完整個人信息
      'userInfo': {
        'userId': userId,
        'userCode': userCode,
        'userName': currentUser?.name ?? userName,
        'email': currentUser?.email ?? '',
        'phone': currentUser?.phone ?? '',
        'avatar': currentUser?.avatarType ?? '',
        'avatarSource': currentUser?.avatarSource ?? '',
      },
    });
  }

  /// 手動訂閱好友功能群組
  Future<void> subscribeToFriendsGroup() async {
    await _mqttManager.subscribeToFriendsGroup();
  }

  /// 手動訂閱帳務功能群組
  Future<void> subscribeToExpensesGroups([List<String> groupIds = const []]) async {
    await _mqttManager.subscribeToAllExpensesGroups(groupIds);
  }

  /// 訂閱特定帳務群組
  Future<void> subscribeToExpensesGroup(String groupId) async {
    await _mqttManager.subscribeToExpensesGroup(groupId);
  }

  /// 取消訂閱帳務群組
  Future<void> unsubscribeFromExpensesGroup(String groupId) async {
    await _mqttManager.unsubscribeFromExpensesGroup(groupId);
  }

  /// 發布消息到指定主題
  Future<void> publishMessage(String topic, Map<String, dynamic> message) async {
    if (!isConnected) {
      throw Exception('MQTT 未連接');
    }
    
    await _mqttManager.publishMessage(topic, message);
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
