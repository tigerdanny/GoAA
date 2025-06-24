import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/services/mqtt/mqtt_app_service.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../../../core/database/repositories/friend_repository.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../widgets/add_friend_dialog.dart';
import '../services/mqtt_user_search_service.dart';

/// 等待中的好友請求
class PendingFriendRequest {
  final String id;
  final String targetName;
  final String targetEmail;
  final String targetPhone;
  final DateTime requestTime;
  final String status; // 'pending', 'accepted', 'rejected'

  PendingFriendRequest({
    required this.id,
    required this.targetName,
    required this.targetEmail,
    required this.targetPhone,
    required this.requestTime,
    this.status = 'pending',
  });

  PendingFriendRequest copyWith({
    String? id,
    String? targetName,
    String? targetEmail,
    String? targetPhone,
    DateTime? requestTime,
    String? status,
  }) {
    return PendingFriendRequest(
      id: id ?? this.id,
      targetName: targetName ?? this.targetName,
      targetEmail: targetEmail ?? this.targetEmail,
      targetPhone: targetPhone ?? this.targetPhone,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
    );
  }
}

/// 好友功能控制器
/// 負責管理好友列表、在線狀態、好友請求等功能
class FriendsController extends ChangeNotifier {
  final MqttAppService _mqttAppService = MqttAppService();
  final FriendRepository _friendRepository = FriendRepository();
  final UserRepository _userRepository = UserRepository();
  final MqttUserSearchService _searchService = MqttUserSearchService();

  // 狀態變量
  final List<OnlineUser> _onlineUsers = [];
  final List<GoaaMqttMessage> _friendRequests = [];
  final List<String> _friends = [];
  final List<PendingFriendRequest> _pendingRequests = []; // 等待中的好友請求
  bool _hasFriends = false;
  bool _isSearching = false;
  final List<UserSearchResult> _searchResults = [];

  // 訂閱
  StreamSubscription<List<OnlineUser>>? _onlineUsersSubscription;
  StreamSubscription<GoaaMqttMessage>? _friendMessagesSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Getters
  List<OnlineUser> get onlineUsers => List.unmodifiable(_onlineUsers);
  List<GoaaMqttMessage> get friendRequests => List.unmodifiable(_friendRequests);
  List<String> get friends => List.unmodifiable(_friends);
  List<PendingFriendRequest> get pendingRequests => List.unmodifiable(_pendingRequests);
  bool get hasFriends => _hasFriends;
  bool get isSearching => _isSearching;
  List<UserSearchResult> get searchResults => List.unmodifiable(_searchResults);
  bool get isConnected => _mqttAppService.isConnected;

  /// 初始化好友控制器
  Future<void> initialize() async {
    debugPrint('🎯 初始化好友控制器...');
    
    // 🔧 確保MQTT App服務已初始化
    if (!_mqttAppService.isConnected) {
      debugPrint('⚠️ MQTT服務未連接，嘗試初始化...');
      await _mqttAppService.initialize();
      
      // 等待連接建立（最多等待3秒）
      int attempts = 0;
      while (!_mqttAppService.isConnected && attempts < 6) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (_mqttAppService.isConnected) {
        debugPrint('✅ MQTT服務連接成功');
      } else {
        debugPrint('⚠️ MQTT服務連接超時，但繼續初始化');
      }
    }
    
    // 初始化 MQTT 用戶搜索服務
    await _searchService.initialize();
    
    // 🔧 修復：無論是否有好友都要設置 MQTT 監聽
    // 新用戶需要監聽好友請求，已有好友的用戶需要監聽狀態更新
    _setupMqttListeners();
    
    debugPrint('✅ 好友控制器初始化完成');
  }

  /// 設置 MQTT 監聽器
  void _setupMqttListeners() {
    debugPrint('🔧 設置 MQTT 監聽器...');
    
    // 🔧 確保好友功能群組已訂閱（包括好友請求主題）
    _mqttAppService.subscribeToFriendsGroup();
    
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
        
        // 更新等待中的請求狀態
        _updatePendingRequestStatus(message.fromUserId, 'accepted');
        
        if (!_friends.contains(message.fromUserId)) {
          _friends.add(message.fromUserId);
          _hasFriends = true;
          debugPrint('✅ 好友請求被接受: ${message.fromUserId}');
          notifyListeners();
        }
        break;
        
      case GoaaMqttMessageType.friendReject:
        // 更新等待中的請求狀態
        _updatePendingRequestStatus(message.fromUserId, 'rejected');
        debugPrint('❌ 好友請求被拒絕: ${message.fromUserId}');
        break;
        
      default:
        debugPrint('⚠️ 未處理的好友消息類型: ${message.type}');
    }
  }

  /// 更新等待中請求的狀態
  void _updatePendingRequestStatus(String userId, String status) {
    for (int i = 0; i < _pendingRequests.length; i++) {
      if (_pendingRequests[i].id == userId) {
        _pendingRequests[i] = _pendingRequests[i].copyWith(status: status);
        break;
      }
    }
    notifyListeners();
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

  /// 搜索用戶（通過姓名、信箱、電話）
  Future<void> searchUsers(FriendSearchInfo searchInfo) async {
    if (searchInfo.name.trim().isEmpty && 
        searchInfo.email.trim().isEmpty && 
        searchInfo.phone.trim().isEmpty) {
      _searchResults.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      debugPrint('🔍 開始MQTT用戶搜索: ${searchInfo.name}');
      debugPrint('   Email: ${searchInfo.email}');
      debugPrint('   Phone: ${searchInfo.phone}');
      
      // 使用 MQTT 搜索服務
      final results = await _searchService.searchUsers(searchInfo);
      _searchResults.clear();
      _searchResults.addAll(results);
      
      debugPrint('📊 MQTT搜索結果: ${_searchResults.length} 個用戶');
      for (final result in _searchResults) {
        debugPrint('   - ${result.userName} (${result.userCode}) 匹配度: ${result.matchScore}');
      }
      
    } catch (e) {
      debugPrint('❌ MQTT搜索用戶失敗: $e');
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

  /// 發送好友請求（通過搜索結果）
  Future<bool> sendFriendRequestToUser(UserSearchResult user) async {
    try {
      debugPrint('📤 發送好友請求給: ${user.userName} (${user.userCode})');
      
      // 創建等待中的請求記錄
      final pendingRequest = PendingFriendRequest(
        id: user.userId,
        targetName: user.userName,
        targetEmail: user.email ?? '',
        targetPhone: user.phone ?? '',
        requestTime: DateTime.now(),
      );
      
      _pendingRequests.add(pendingRequest);
      notifyListeners();
      
      // 發送 MQTT 好友請求
      await _mqttAppService.sendFriendRequest(
        toUserId: user.userId,
        message: '好友請求',
      );
      
      debugPrint('✅ 好友請求發送成功');
      return true;
    } catch (e) {
      debugPrint('❌ 發送好友請求異常: $e');
      return false;
    }
  }

  /// 發送好友請求（通過搜索信息）
  Future<bool> sendFriendRequestByInfo(FriendSearchInfo searchInfo) async {
    try {
      debugPrint('📤 發送好友請求: ${searchInfo.name}');
      
      // 創建等待中的請求記錄
      final pendingRequest = PendingFriendRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetName: searchInfo.name,
        targetEmail: searchInfo.email,
        targetPhone: searchInfo.phone,
        requestTime: DateTime.now(),
      );
      
      _pendingRequests.add(pendingRequest);
      notifyListeners();
      
      // 通過搜索信息找到用戶並發送請求
      await searchUsers(searchInfo);
      if (_searchResults.isNotEmpty) {
        // 發送給第一個匹配的用戶
        final targetUser = _searchResults.first;
        await _mqttAppService.sendFriendRequest(
          toUserId: targetUser.userId,
          message: '好友請求',
        );
      }
      
      debugPrint('✅ 好友請求發送成功');
      return true;
    } catch (e) {
      debugPrint('❌ 發送好友請求異常: $e');
      return false;
    }
  }

  /// 發送好友請求（舊版本，通過 userId）
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

  /// 移除等待中的請求
  void removePendingRequest(String requestId) {
    _pendingRequests.removeWhere((request) => request.id == requestId);
    notifyListeners();
  }



  /// 手動重連（委託給 MQTT APP 服務）
  Future<void> reconnect() async {
    debugPrint('🔄 請求重新連接 MQTT...');
    await _mqttAppService.reconnect();
    
    // 等待連接建立
    int attempts = 0;
    while (!_mqttAppService.isConnected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    if (_mqttAppService.isConnected) {
      debugPrint('✅ MQTT重新連接成功');
      notifyListeners(); // 通知UI更新連接狀態
    } else {
      debugPrint('❌ MQTT重新連接失敗');
    }
  }

  /// 清理資源
  @override
  void dispose() {
    debugPrint('🧹 清理好友控制器資源...');
    
    _onlineUsersSubscription?.cancel();
    _friendMessagesSubscription?.cancel();
    _connectionSubscription?.cancel();
    _friendRepository.dispose();
    _searchService.dispose();
    
    super.dispose();
  }
}
