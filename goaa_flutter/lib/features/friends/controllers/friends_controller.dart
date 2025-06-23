import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/services/mqtt/mqtt_app_service.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../../../core/database/repositories/friend_repository.dart';
import '../../../core/database/repositories/user_repository.dart';

/// 好友功能控制器
/// 負責管理好友列表、在線狀態、好友請求等功能
class FriendsController extends ChangeNotifier {
  final MqttAppService _mqttAppService = MqttAppService();
  final FriendRepository _friendRepository = FriendRepository();
  final UserRepository _userRepository = UserRepository();

  // 狀態變量
  final List<String> _friends = [];
  final List<OnlineUser> _onlineUsers = [];
  final List<GoaaMqttMessage> _friendRequests = [];
  final List<dynamic> _searchResults = [];
  bool _hasFriends = false;
  bool _isSearching = false;

  // 訂閱
  StreamSubscription<List<OnlineUser>>? _onlineUsersSubscription;
  StreamSubscription<GoaaMqttMessage>? _friendMessagesSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Getters
  List<String> get friends => List.unmodifiable(_friends);
  List<OnlineUser> get onlineUsers => List.unmodifiable(_onlineUsers);
  List<GoaaMqttMessage> get friendRequests => List.unmodifiable(_friendRequests);
  List<dynamic> get searchResults => List.unmodifiable(_searchResults);
  bool get hasFriends => _hasFriends;
  bool get isSearching => _isSearching;
  bool get isConnected => _mqttAppService.isConnected;

  FriendsController() {
    _initializeController();
  }

  /// 初始化控制器
  void _initializeController() {
    debugPrint('🎮 初始化好友控制器...');
    
    // 加載本地好友數據
    _loadFriendsData();
    
    // 設置 MQTT 監聽器
    _setupMqttListeners();
    
    debugPrint('✅ 好友控制器初始化完成');
  }

  /// 加載好友數據
  void _loadFriendsData() {
    // 實際實現時需要從 UserRepository 或 FriendRepository 加載
    // 這裡暫時使用模擬數據
    _friends.clear();
    _hasFriends = _friends.isNotEmpty;
    
    debugPrint('📂 加載好友數據: ${_friends.length} 個好友');
  }

  /// 設置 MQTT 監聽器
  void _setupMqttListeners() {
    debugPrint('📡 設置 MQTT 監聽器...');

    // 監聽在線用戶
    _onlineUsersSubscription = _mqttAppService.onlineUsersStream.listen(
      (users) {
        _onlineUsers.clear();
        _onlineUsers.addAll(users);
        notifyListeners();
        debugPrint('👥 在線用戶更新: ${users.length} 個用戶');
      },
      onError: (error) {
        debugPrint('❌ 在線用戶監聽錯誤: $error');
      },
    );

    // 監聽好友消息
    _friendMessagesSubscription = _mqttAppService.friendsMessageStream.listen(
      (message) {
        _handleFriendMessage(message);
      },
      onError: (error) {
        debugPrint('❌ 好友消息監聽錯誤: $error');
      },
    );

    // 監聽連接狀態
    _connectionSubscription = _mqttAppService.connectionStatusStream.listen(
      (connected) {
        notifyListeners(); // 更新 UI 顯示連接狀態
        debugPrint('🔗 MQTT 連接狀態: ${connected ? "已連接" : "已斷開"}');
      },
      onError: (error) {
        debugPrint('❌ 連接狀態監聽錯誤: $error');
      },
    );

    debugPrint('✅ MQTT 監聽器設置完成');
  }

  /// 處理好友消息
  void _handleFriendMessage(GoaaMqttMessage message) {
    debugPrint('📨 收到好友消息: ${message.type}');
    
    switch (message.type) {
      case GoaaMqttMessageType.friendRequest:
        // 第一階段：簡單好友請求通知
        _friendRequests.add(message);
        debugPrint('📬 收到好友請求: ${message.fromUserId} (${message.data['fromUserName']})');
        notifyListeners();
        break;
        
      case GoaaMqttMessageType.friendAccept:
        // 第二階段：處理好友接受和完整信息
        final stage = message.data['stage'] as String?;
        if (stage == 'info_share') {
          // 收到完整好友信息，保存到數據庫
          _saveFriendToDatabase(message);
        }
        
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

  /// 保存好友信息到數據庫
  Future<void> _saveFriendToDatabase(GoaaMqttMessage message) async {
    try {
      final userInfo = message.data['userInfo'] as Map<String, dynamic>?;
      if (userInfo == null) return;

      debugPrint('💾 保存好友信息到數據庫: ${userInfo['userName']}');
      debugPrint('   UUID: ${userInfo['userCode']}');
      debugPrint('   Email: ${userInfo['email']}');
      debugPrint('   Phone: ${userInfo['phone']}');
      
      // 獲取當前用戶ID
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ 無法獲取當前用戶信息');
        return;
      }

      // 保存好友信息到本地數據庫
      final success = await _friendRepository.saveFriend(
        currentUserId: currentUser.id,
        friendUserId: userInfo['userId'] ?? '',
        friendUserCode: userInfo['userCode'] ?? '',
        friendName: userInfo['userName'] ?? '',
        friendEmail: userInfo['email']?.isEmpty == true ? null : userInfo['email'],
        friendPhone: userInfo['phone']?.isEmpty == true ? null : userInfo['phone'],
        friendAvatar: userInfo['avatar']?.isEmpty == true ? null : userInfo['avatar'],
        friendAvatarSource: userInfo['avatarSource']?.isEmpty == true ? null : userInfo['avatarSource'],
      );

      if (success) {
        debugPrint('✅ 好友信息保存成功');
      } else {
        debugPrint('❌ 好友信息保存失敗');
      }
      
    } catch (e) {
      debugPrint('❌ 保存好友信息失敗: $e');
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
      
      // 實際實現時需要調用搜索 API
      // final results = await _friendSearchService.searchUsers(query);
      // _searchResults = results;
      
      // 暫時的模擬實現
      await Future.delayed(const Duration(milliseconds: 500));
      _searchResults.clear(); // 暫時返回空結果
      
      debugPrint('📊 搜索結果: ${_searchResults.length} 個用戶');
    } catch (e) {
      debugPrint('❌ 搜索用戶失敗: $e');
      _searchResults.clear();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 清空搜索結果
  void clearSearch() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }

  /// 發送好友請求
  Future<bool> sendFriendRequest(String targetUserId) async {
    try {
      debugPrint('📤 發送好友請求給: $targetUserId');
      
      await _mqttAppService.sendFriendRequest(
        toUserId: targetUserId,
        message: '好友請求',
      );

      debugPrint('✅ 好友請求發送成功');
      return true;
    } catch (e) {
      debugPrint('❌ 發送好友請求異常: $e');
      return false;
    }
  }

  /// 接受好友請求
  Future<bool> acceptFriendRequest(GoaaMqttMessage request) async {
    try {
      debugPrint('✅ 接受好友請求: ${request.fromUserId}');
      
      await _mqttAppService.respondToFriendRequest(
        requestId: request.id,
        fromUserId: request.fromUserId,
        accept: true,
      );

      // 添加到本地好友列表
      if (!_friends.contains(request.fromUserId)) {
        _friends.add(request.fromUserId);
        _hasFriends = true;
      }
      
      // 從請求列表中移除
      _friendRequests.remove(request);
      notifyListeners();
      
      debugPrint('✅ 好友請求接受成功');
      return true;
    } catch (e) {
      debugPrint('❌ 接受好友請求異常: $e');
      return false;
    }
  }

  /// 拒絕好友請求
  Future<bool> rejectFriendRequest(GoaaMqttMessage request) async {
    try {
      debugPrint('❌ 拒絕好友請求: ${request.fromUserId}');
      
      await _mqttAppService.respondToFriendRequest(
        requestId: request.id,
        fromUserId: request.fromUserId,
        accept: false,
      );

      // 從請求列表中移除
      _friendRequests.remove(request);
      notifyListeners();
      
      debugPrint('✅ 好友請求拒絕成功');
      return true;
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
    _friendRepository.dispose();
    
    super.dispose();
  }
}
