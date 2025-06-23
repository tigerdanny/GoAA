import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:goaa_flutter/core/services/mqtt_service.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';
import 'package:goaa_flutter/core/services/user_id_service.dart';

/// 好友管理控制器
class FriendsController extends ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final UserIdService _userIdService = UserIdService();
  
  // 狀態
  List<OnlineUser> _onlineUsers = [];
  List<OnlineUser> _searchResults = [];
  final List<String> _friends = []; // TODO: 從數據庫加載實際好友列表
  final List<GoaaMqttMessage> _friendRequests = [];
  
  bool _isSearching = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _hasFriends = false;
  
  // 訂閱
  StreamSubscription<List<OnlineUser>>? _onlineUsersSubscription;
  StreamSubscription<GoaaMqttMessage>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  
  // Getters
  List<OnlineUser> get onlineUsers => _onlineUsers;
  List<OnlineUser> get searchResults => _searchResults;
  List<String> get friends => _friends;
  List<GoaaMqttMessage> get friendRequests => _friendRequests;
  bool get isSearching => _isSearching;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get hasFriends => _hasFriends;
  
  /// 初始化好友列表（從數據庫加載）
  Future<void> initializeFriends() async {
    // TODO: 從數據庫加載實際好友列表
    // 暫時使用空列表，實際實現時需要從 UserRepository 或 FriendRepository 加載
    _friends.clear();
    _hasFriends = _friends.isNotEmpty;
    
    // 只有在有好友的情況下才連接 MQTT
    if (_hasFriends) {
      await _connectMqttForFriends();
    }
    
    // 無論是否有好友，都需要監聽好友請求
    await _setupFriendRequestsListener();
    
    notifyListeners();
  }

  /// 獲取已成為好友的在線用戶
  List<OnlineUser> getFriendUsers() {
    return _onlineUsers.where((user) => _friends.contains(user.userId)).toList();
  }
  
  /// 為好友功能連接 MQTT（僅在有好友時調用）
  Future<void> _connectMqttForFriends() async {
    _isConnecting = true;
    notifyListeners();

    try {
      // 獲取用戶信息
      final userId = await _userIdService.getUserId();
      final userName = 'User_${userId.substring(0, 8)}';
      final userCode = await _userIdService.getUserCode();

      // 連接 MQTT 服務
      final connected = await _mqttService.connect(
        userId: userId,
        userName: userName,
        userCode: userCode,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('MQTT 連接超時 (5秒)');
          return false;
        },
      );

      if (connected) {
        _setupSubscriptions();
        _isConnected = true;
        debugPrint('✅ MQTT 已連接，開始監聽好友狀態');
      } else {
        _isConnected = false;
        debugPrint('❌ MQTT 連接失敗，好友上線狀態不可用');
      }
    } catch (e) {
      debugPrint('MQTT 連接失敗: $e');
      _isConnected = false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// 設置好友請求監聽器（無論是否有好友都需要）
  Future<void> _setupFriendRequestsListener() async {
    try {
      // TODO: 設置只監聽好友請求的輕量級連接
      // 這裡可以使用不同的連接方式，或者使用推送通知
      debugPrint('📬 開始監聽好友請求...');
    } catch (e) {
      debugPrint('設置好友請求監聽失敗: $e');
    }
  }
  
  /// 設置訂閱
  void _setupSubscriptions() {
    // 監聽在線用戶
    _onlineUsersSubscription = _mqttService.onlineUsersStream.listen((users) {
      _onlineUsers = users;
      notifyListeners();
    });

    // 監聽消息
    _messageSubscription = _mqttService.messageStream.listen(_handleMqttMessage);

    // 監聽連接狀態
    _connectionSubscription = _mqttService.connectionStream.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });
  }
  
  /// 處理 MQTT 消息
  void _handleMqttMessage(GoaaMqttMessage message) {
    // 只處理好友功能群組的消息
    if (message.group != 'friends') return;
    
    switch (message.type) {
      case GoaaMqttMessageType.friendRequest:
        _friendRequests.add(message);
        notifyListeners();
        break;
        
      case GoaaMqttMessageType.friendAccept:
        if (!_friends.contains(message.fromUserId)) {
          _friends.add(message.fromUserId);
          notifyListeners();
        }
        break;
        
      case GoaaMqttMessageType.friendReject:
        // 處理好友拒絕
        break;
        
      default:
        break;
    }
  }
  
  /// 搜索用戶
  void searchUsers(String query) {
    _isSearching = true;
    notifyListeners();
    
    // 模擬搜索延遲
    Future.delayed(const Duration(milliseconds: 300), () {
      if (query.trim().isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = _mqttService.searchOnlineUsers(query);
      }
      _isSearching = false;
      notifyListeners();
    });
  }
  
  /// 清除搜索結果
  void clearSearch() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }
  
  /// 發送好友請求
  Future<void> sendFriendRequest(OnlineUser user) async {
    await _mqttService.sendFriendRequest(user.userId, {
      'userName': user.userName,
      'userCode': user.userCode,
    });
  }
  
  /// 接受好友請求
  Future<void> acceptFriendRequest(String fromUserId) async {
    await _mqttService.acceptFriendRequest(fromUserId);
    
    // 從請求列表中移除
    _friendRequests.removeWhere((req) => req.fromUserId == fromUserId);
    
    // 添加到好友列表
    if (!_friends.contains(fromUserId)) {
      _friends.add(fromUserId);
    }
    
    notifyListeners();
  }
  
  /// 拒絕好友請求
  Future<void> rejectFriendRequest(String fromUserId) async {
    await _mqttService.rejectFriendRequest(fromUserId);
    
    // 從請求列表中移除
    _friendRequests.removeWhere((req) => req.fromUserId == fromUserId);
    notifyListeners();
  }
  
  /// 重新連接（僅在有好友時）
  Future<void> reconnect() async {
    if (!_isConnected && !_isConnecting && _hasFriends) {
      await _connectMqttForFriends();
    }
  }
  
  @override
  void dispose() {
    _onlineUsersSubscription?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
} 
