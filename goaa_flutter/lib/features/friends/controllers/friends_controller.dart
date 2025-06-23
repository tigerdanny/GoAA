import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:goaa_flutter/core/services/mqtt_service.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';
import 'package:goaa_flutter/core/services/user_id_service.dart';
import '../../../core/services/friend_request_service.dart';

/// 好友管理控制器
class FriendsController extends ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final UserIdService _userIdService = UserIdService();
  
  // 狀態
  List<OnlineUser> _onlineUsers = [];
  List<OnlineUser> _searchResults = [];
  final List<String> _friends = []; // 從數據庫加載實際好友列表
  final List<GoaaMqttMessage> _friendRequests = [];
  
  bool _isSearching = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _hasFriends = false;
  bool _friendRequestsListenerActive = false; // 好友請求監聽器狀態
  
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
  bool get friendRequestsListenerActive => _friendRequestsListenerActive;
  
  /// 啟動全局好友請求監聽（應在應用啟動時調用）
  /// 這個方法應該在應用啟動時就調用，不依賴於是否進入好友頁面
  static Future<void> startGlobalFriendRequestsListener() async {
    try {
      // 使用獨立的好友請求服務
      final friendRequestService = FriendRequestService();
      await friendRequestService.startService();
      debugPrint('✅ 全局好友請求監聽服務已啟動');
    } catch (e) {
      debugPrint('❌ 全局好友請求監聽服務啟動失敗: $e');
    }
  }

  /// 初始化好友列表（從數據庫加載）
  Future<void> initializeFriends() async {
    // 1. 確保好友請求監聽器已啟動（如果還沒啟動的話）
    if (!_friendRequestsListenerActive) {
      await _setupFriendRequestsListener();
    }
    
    // 2. 從數據庫加載實際好友列表
    // 暫時使用空列表，實際實現時需要從 UserRepository 或 FriendRepository 加載
    _friends.clear();
    _hasFriends = _friends.isNotEmpty;
    
    // 3. 只有在有好友的情況下才連接 MQTT 處理好友上線/下線狀態
    if (_hasFriends) {
      await _connectMqttForFriends();
    }
    
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

  /// 設置好友請求監聽器（獨立且隨時監聽）
  /// 這個監聽器完全獨立於好友列表和 MQTT 連接狀態
  /// 可以使用推送通知、WebSocket 或其他輕量級方式
  Future<void> _setupFriendRequestsListener() async {
    if (_friendRequestsListenerActive) {
      debugPrint('📬 好友請求監聽器已在運行中');
      return;
    }
    
    try {
      debugPrint('📬 啟動獨立的好友請求監聽服務...');
      
      // 方案1: 使用推送通知服務（推薦）
      // await _setupPushNotificationForFriendRequests();
      
      // 方案2: 使用輕量級 WebSocket 連接
      // await _setupWebSocketForFriendRequests();
      
      // 方案3: 使用定時輪詢（備用方案）
      // await _setupPollingForFriendRequests();
      
      // 暫時的實現：直接監聽數據庫變化或使用本地通知
      await _setupLocalFriendRequestsMonitor();
      
      _friendRequestsListenerActive = true;
      debugPrint('✅ 好友請求監聽服務已啟動（獨立運行）');
    } catch (e) {
      debugPrint('❌ 好友請求監聽服務啟動失敗: $e');
      _friendRequestsListenerActive = false;
      // 即使失敗也不影響其他功能
    }
  }
  
  /// 設置本地好友請求監控（臨時實現）
  Future<void> _setupLocalFriendRequestsMonitor() async {
    // 這裡可以：
    // 1. 監聽本地數據庫的好友請求表變化
    // 2. 設置定時檢查
    // 3. 使用 Stream 監聽數據變化
    debugPrint('🔄 本地好友請求監控已設置');
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
