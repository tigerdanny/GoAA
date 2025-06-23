import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/mqtt/mqtt_app_service.dart';
import '../../../core/services/mqtt/mqtt_models.dart';

/// 好友管理控制器
/// 不再直接管理 MQTT 連接，而是監聽全局 MQTT APP 服務的好友事件
class FriendsController extends ChangeNotifier {
  final MqttAppService _mqttAppService = MqttAppService();
  
  // 狀態
  List<OnlineUser> _onlineUsers = [];
  List<OnlineUser> _searchResults = [];
  final List<String> _friends = []; // 從數據庫加載實際好友列表
  final List<GoaaMqttMessage> _friendRequests = [];
  
  bool _isSearching = false;
  bool _hasFriends = false;
  
  // 訂閱
  StreamSubscription<List<OnlineUser>>? _onlineUsersSubscription;
  StreamSubscription<GoaaMqttMessage>? _friendMessagesSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  
  // Getters
  List<OnlineUser> get onlineUsers => _onlineUsers;
  List<OnlineUser> get searchResults => _searchResults;
  List<String> get friends => _friends;
  List<GoaaMqttMessage> get friendRequests => _friendRequests;
  bool get isSearching => _isSearching;
  bool get hasFriends => _hasFriends;
  
  // 從 MQTT APP 服務獲取連接狀態
  bool get isConnecting => _mqttAppService.isConnecting;
  bool get isConnected => _mqttAppService.isConnected;

  /// 初始化好友列表和監聽
  Future<void> initializeFriends() async {
    debugPrint('🚀 初始化好友控制器...');
    
    // 1. 從數據庫加載實際好友列表
    await _loadFriendsFromDatabase();
    
    // 2. 設置 MQTT APP 服務監聽
    _setupMqttAppServiceListeners();
    
    debugPrint('✅ 好友控制器初始化完成');
    notifyListeners();
  }

  /// 從數據庫加載好友列表
  Future<void> _loadFriendsFromDatabase() async {
    try {
      // TODO: 實際實現時需要從 UserRepository 或 FriendRepository 加載
      // final friendsList = await _friendRepository.getAllFriends();
      // _friends.clear();
      // _friends.addAll(friendsList);
      
      _friends.clear(); // 暫時使用空列表
      _hasFriends = _friends.isNotEmpty;
      
      debugPrint('📊 加載好友列表: ${_friends.length} 個好友');
    } catch (e) {
      debugPrint('❌ 加載好友列表失敗: $e');
    }
  }

  /// 設置 MQTT APP 服務監聽器
  void _setupMqttAppServiceListeners() {
    debugPrint('📡 設置 MQTT APP 服務監聽器...');
    
    // 監聽在線用戶變化
    _onlineUsersSubscription = _mqttAppService.onlineUsersStream.listen(
      (users) {
        _onlineUsers = users;
        notifyListeners();
        debugPrint('👥 在線用戶更新: ${users.length} 個用戶');
      },
      onError: (error) {
        debugPrint('❌ 在線用戶監聽錯誤: $error');
      },
    );

    // 監聽好友消息
    _friendMessagesSubscription = _mqttAppService.friendMessagesStream.listen(
      (message) {
        _handleFriendMessage(message);
      },
      onError: (error) {
        debugPrint('❌ 好友消息監聽錯誤: $error');
      },
    );

    // 監聽連接狀態變化
    _connectionSubscription = _mqttAppService.connectionStream.listen(
      (connected) {
        notifyListeners(); // 更新 UI 顯示連接狀態
        debugPrint('🔗 MQTT 連接狀態: ${connected ? "已連接" : "已斷開"}');
      },
      onError: (error) {
        debugPrint('❌ 連接狀態監聽錯誤: $error');
      },
    );

    debugPrint('✅ MQTT APP 服務監聽器設置完成');
  }

  /// 處理好友消息
  void _handleFriendMessage(GoaaMqttMessage message) {
    debugPrint('📨 收到好友消息: ${message.type}');
    
    switch (message.type) {
      case GoaaMqttMessageType.friendRequest:
        _friendRequests.add(message);
        debugPrint('📬 收到好友請求: ${message.fromUserId}');
        notifyListeners();
        break;
        
      case GoaaMqttMessageType.friendAccept:
        if (!_friends.contains(message.fromUserId)) {
          _friends.add(message.fromUserId);
          _hasFriends = true;
          debugPrint('✅ 好友請求被接受: ${message.fromUserId}');
          notifyListeners();
        }
        break;
        
      case GoaaMqttMessageType.friendReject:
        debugPrint('❌ 好友請求被拒絕: ${message.fromUserId}');
        // 可以在這裡處理拒絕邏輯
        break;
        
      default:
        debugPrint('⚠️ 未處理的好友消息類型: ${message.type}');
    }
  }

  /// 獲取已成為好友的在線用戶
  List<OnlineUser> getFriendUsers() {
    return _onlineUsers.where((user) => _friends.contains(user.userId)).toList();
  }

  /// 搜索用戶
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      debugPrint('🔍 搜索用戶: $query');
      
      // TODO: 實際實現時需要調用搜索 API
      // final results = await _friendSearchService.searchUsers(query);
      // _searchResults = results;
      
      // 暫時的模擬實現
      await Future.delayed(const Duration(milliseconds: 500));
      _searchResults = []; // 暫時返回空結果
      
      debugPrint('📊 搜索結果: ${_searchResults.length} 個用戶');
    } catch (e) {
      debugPrint('❌ 搜索用戶失敗: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 發送好友請求
  Future<bool> sendFriendRequest(String targetUserId) async {
    try {
      debugPrint('📤 發送好友請求給: $targetUserId');
      
      final message = GoaaMqttMessage(
        type: GoaaMqttMessageType.friendRequest,
        group: 'friends',
        fromUserId: '', // 會在 MQTT 服務中自動填充
        toUserId: targetUserId,
        content: '好友請求',
        timestamp: DateTime.now(),
      );

      final success = await _mqttAppService.sendFriendMessage(message);
      
      if (success) {
        debugPrint('✅ 好友請求發送成功');
      } else {
        debugPrint('❌ 好友請求發送失敗');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ 發送好友請求異常: $e');
      return false;
    }
  }

  /// 接受好友請求
  Future<bool> acceptFriendRequest(GoaaMqttMessage request) async {
    try {
      debugPrint('✅ 接受好友請求: ${request.fromUserId}');
      
      final message = GoaaMqttMessage(
        type: GoaaMqttMessageType.friendAccept,
        group: 'friends',
        fromUserId: '', // 會在 MQTT 服務中自動填充
        toUserId: request.fromUserId,
        content: '接受好友請求',
        timestamp: DateTime.now(),
      );

      final success = await _mqttAppService.sendFriendMessage(message);
      
      if (success) {
        // 添加到本地好友列表
        if (!_friends.contains(request.fromUserId)) {
          _friends.add(request.fromUserId);
          _hasFriends = true;
        }
        
        // 從請求列表中移除
        _friendRequests.remove(request);
        notifyListeners();
        
        debugPrint('✅ 好友請求接受成功');
      } else {
        debugPrint('❌ 好友請求接受失敗');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ 接受好友請求異常: $e');
      return false;
    }
  }

  /// 拒絕好友請求
  Future<bool> rejectFriendRequest(GoaaMqttMessage request) async {
    try {
      debugPrint('❌ 拒絕好友請求: ${request.fromUserId}');
      
      final message = GoaaMqttMessage(
        type: GoaaMqttMessageType.friendReject,
        group: 'friends',
        fromUserId: '', // 會在 MQTT 服務中自動填充
        toUserId: request.fromUserId,
        content: '拒絕好友請求',
        timestamp: DateTime.now(),
      );

      final success = await _mqttAppService.sendFriendMessage(message);
      
      if (success) {
        // 從請求列表中移除
        _friendRequests.remove(request);
        notifyListeners();
        
        debugPrint('✅ 好友請求拒絕成功');
      } else {
        debugPrint('❌ 好友請求拒絕失敗');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ 拒絕好友請求異常: $e');
      return false;
    }
  }

  /// 手動重連（委託給 MQTT APP 服務）
  Future<void> reconnect() async {
    debugPrint('🔄 請求重新連接 MQTT...');
    await _mqttAppService.reconnect();
  }

  /// 清理資源
  @override
  void dispose() {
    debugPrint('🧹 清理好友控制器資源...');
    
    _onlineUsersSubscription?.cancel();
    _friendMessagesSubscription?.cancel();
    _connectionSubscription?.cancel();
    
    super.dispose();
  }
}
