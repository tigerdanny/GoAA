import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/database/repositories/friend_repository.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/services/mqtt/mqtt_models.dart';

/// 好友信息模型
class Friend {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime addedAt;
  final bool isOnline;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.addedAt,
    this.isOnline = false,
  });

  Friend copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? addedAt,
    bool? isOnline,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addedAt: addedAt ?? this.addedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// 好友請求模型
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String fromUserPhone;
  final DateTime requestTime;
  final String status; // 'pending', 'accepted', 'rejected'

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.fromUserPhone,
    required this.requestTime,
    this.status = 'pending',
  });

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserEmail,
    String? fromUserPhone,
    DateTime? requestTime,
    String? status,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserEmail: fromUserEmail ?? this.fromUserEmail,
      fromUserPhone: fromUserPhone ?? this.fromUserPhone,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
    );
  }
}



/// 好友搜索信息
class FriendSearchInfo {
  final String query;
  final DateTime searchTime;

  FriendSearchInfo({
    required this.query,
    required this.searchTime,
  });

  @override
  String toString() => query;
}

/// 好友功能控制器（無MQTT版本）
/// 負責管理好友列表、好友請求等功能
class FriendsController extends ChangeNotifier {
  final FriendRepository _friendRepository = FriendRepository();
  final UserRepository _userRepository = UserRepository();

  // 狀態變量
  final List<Friend> _friends = [];
  final List<FriendRequest> _friendRequests = [];
  final List<UserSearchResult> _searchResults = [];
  final List<OnlineUser> _onlineUsers = [];
  final List<PendingFriendRequest> _pendingRequests = [];
  bool _hasFriends = false;
  bool _isSearching = false;
  bool _isInitialized = false;
  bool _isConnected = false;

  // Getters
  List<Friend> get friends => List.unmodifiable(_friends);
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  List<UserSearchResult> get searchResults => List.unmodifiable(_searchResults);
  List<OnlineUser> get onlineUsers => List.unmodifiable(_onlineUsers);
  List<PendingFriendRequest> get pendingRequests => List.unmodifiable(_pendingRequests);
  bool get hasFriends => _hasFriends;
  bool get isSearching => _isSearching;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  VoidCallback? get reconnect => _reconnect;
  
  String? get userName {
    // 實現獲取當前用戶名稱
    // 這裡應該緩存當前用戶名稱，避免每次都查詢數據庫
    return _currentUserName ?? 'Guest';
  }
  
  String? _currentUserName;

  /// 初始化好友控制器
  Future<void> initialize() async {
    debugPrint('🎯 初始化好友控制器（本地版本）...');
    
    try {
      // 獲取當前用戶信息
      final currentUser = await _userRepository.getCurrentUser();
      _currentUserName = currentUser?.name ?? 'Guest';
      
      // 加載好友列表
      await _loadFriends();
      
      // 加載待處理的好友請求
      await _loadFriendRequests();
      
      _isInitialized = true;
      notifyListeners();
      
      debugPrint('✅ 好友控制器初始化完成');
    } catch (e) {
      debugPrint('❌ 好友控制器初始化失敗: $e');
    }
  }

  /// 從數據庫加載好友列表
  Future<void> _loadFriends() async {
    try {
      debugPrint('📚 開始加載好友列表...');
      
      // 獲取當前用戶
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('⚠️ 沒有當前用戶，無法加載好友列表');
        _friends.clear();
        _hasFriends = false;
        return;
      }
      
      debugPrint('👤 當前用戶: ${currentUser.name} (ID: ${currentUser.id})');
      
      // 從數據庫加載好友
      final friendsData = await _friendRepository.getFriends(currentUser.id);
      
      // 清空現有好友列表
      _friends.clear();
      
      // 將資料庫數據轉換為Friend模型
      for (final friendData in friendsData) {
        final friend = Friend(
          id: friendData.friendUserCode, // 使用userCode作為ID
          name: friendData.friendName,
          email: friendData.friendEmail ?? '',
          phone: friendData.friendPhone ?? '',
          addedAt: friendData.createdAt,
          isOnline: false, // 暫時設為false，後續可以實作在線狀態
        );
        _friends.add(friend);
      }
      
      // 更新狀態
      _hasFriends = _friends.isNotEmpty;
      
      debugPrint('📚 已從資料庫加載 ${_friends.length} 個好友');
      if (_friends.isNotEmpty) {
        for (final friend in _friends) {
          debugPrint('   - ${friend.name} (${friend.email})');
        }
      } else {
        debugPrint('   目前沒有好友');
      }
      
    } catch (e) {
      debugPrint('❌ 加載好友列表失敗: $e');
      // 發生錯誤時確保狀態正確
      _friends.clear();
      _hasFriends = false;
    }
  }

  /// 加載好友請求
  Future<void> _loadFriendRequests() async {
    debugPrint('📚 加載好友請求...');
    
    try {
      // 獲取當前用戶
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('⚠️ 沒有當前用戶，無法加載好友請求');
        _friendRequests.clear();
        _pendingRequests.clear();
        return;
      }
      
      // 實現加載好友請求邏輯
      // 目前暫時使用模擬數據，後續可以連接真實的數據源
      _friendRequests.clear();
      _pendingRequests.clear();
      
      // 模擬一些好友請求數據
      if (currentUser.id == 1) {
        _friendRequests.add(FriendRequest(
          id: 'req_001',
          fromUserId: 'user2',
          fromUserName: '李明',
          fromUserEmail: 'liming@example.com',
          fromUserPhone: '138123456789',
          requestTime: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'pending',
        ));
        
                 _pendingRequests.add(PendingFriendRequest(
           id: 'pending_001',
           fromUserId: currentUser.id.toString(),
           fromUserName: currentUser.name,
           fromUserEmail: 'current@example.com',
           fromUserPhone: '123456789',
           targetName: '王小紅',
           targetEmail: 'wangxiaohong@example.com',
           targetPhone: '139876543210',
           status: 'pending',
           requestTime: DateTime.now().subtract(const Duration(hours: 1)),
         ));
      }
      
      debugPrint('📚 加載了 ${_friendRequests.length} 個待處理好友請求');
      debugPrint('📚 加載了 ${_pendingRequests.length} 個已發送請求');
      
    } catch (e) {
      debugPrint('❌ 加載好友請求失敗: $e');
      _friendRequests.clear();
      _pendingRequests.clear();
    }
  }

  /// 搜索用戶（修復版本）
  Future<List<UserSearchResult>> searchUsers(FriendSearchInfo searchInfo) async {
    debugPrint('🔍 搜索用戶: ${searchInfo.query}');
    _isSearching = true;
    notifyListeners();
    
    try {
      // 實現用戶搜索邏輯
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 基於搜索條件進行模擬搜索
      final searchResults = <UserSearchResult>[];
      
      // 模擬數據庫搜索邏輯
      final mockUsers = [
        UserSearchResult(
          id: 'user_001',
          userId: 'user_001',
          userCode: 'USR001',
          userName: '張三',
          name: '張三',
          email: 'zhangsan@example.com',
          phone: '138123456789',
          matchScore: 0.95,
        ),
        UserSearchResult(
          id: 'user_002',
          userId: 'user_002',
          userCode: 'USR002',
          userName: '李四',
          name: '李四',
          email: 'lisi@example.com',
          phone: '139876543210',
          matchScore: 0.85,
        ),
        UserSearchResult(
          id: 'user_003',
          userId: 'user_003',
          userCode: 'USR003',
          userName: '王五',
          name: '王五',
          email: 'wangwu@example.com',
          phone: '136987654321',
          matchScore: 0.75,
        ),
      ];
      
      // 過濾搜索結果
      final query = searchInfo.query.toLowerCase();
      for (final user in mockUsers) {
        if (user.userName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phone.contains(query) ||
            user.userCode.toLowerCase().contains(query)) {
          searchResults.add(user);
        }
      }
      
      // 按匹配分數排序
      searchResults.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      
      debugPrint('🔍 搜索 "${searchInfo.query}" 找到 ${searchResults.length} 個結果');
      
      return searchResults;
      
    } catch (e) {
      debugPrint('❌ 搜索用戶失敗: $e');
      return [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 發送好友請求
  Future<bool> sendFriendRequestToUser(UserSearchResult user) async {
    debugPrint('📤 發送好友請求給: ${user.name}');
    try {
      // 獲取當前用戶
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ 沒有當前用戶，無法發送好友請求');
        return false;
      }
      
      // 實現發送好友請求邏輯
      // 檢查是否已經是好友
      final isAlreadyFriend = _friends.any((friend) => friend.id == user.userId);
      if (isAlreadyFriend) {
        debugPrint('⚠️ 用戶已經是好友了');
        return false;
      }
      
      // 檢查是否已經發送過請求
      final hasExistingRequest = _pendingRequests.any((request) => 
          request.fromUserId == currentUser.id.toString() && 
          request.targetName == user.name);
      if (hasExistingRequest) {
        debugPrint('⚠️ 已經發送過好友請求了');
        return false;
      }
      
      // 模擬網絡請求延遲
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 創建新的待處理請求
      final pendingRequest = PendingFriendRequest(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        fromUserId: currentUser.id.toString(),
        fromUserName: currentUser.name,
        fromUserEmail: currentUser.email ?? '',
        fromUserPhone: currentUser.phone ?? '',
        targetName: user.userName,
        targetEmail: user.email,
        targetPhone: user.phone,
        status: 'pending',
        requestTime: DateTime.now(),
      );
      
      // 添加到待處理列表
      _pendingRequests.add(pendingRequest);
      notifyListeners();
      
      debugPrint('✅ 好友請求已發送');
      return true;
    } catch (e) {
      debugPrint('❌ 發送好友請求失敗: $e');
      return false;
    }
  }

  /// 獲取好友用戶列表
  List<OnlineUser> getFriendUsers() {
    debugPrint('📚 獲取好友用戶列表');
    
    // 實現獲取好友用戶列表邏輯
    // 將好友列表轉換為在線用戶列表
    _onlineUsers.clear();
    
    for (final friend in _friends) {
      final onlineUser = OnlineUser(
        id: friend.id,
        userId: friend.id,
        userName: friend.name,
        name: friend.name,
        userCode: friend.id, // 使用ID作為用戶代碼
        email: friend.email,
        phone: friend.phone,
        isOnline: friend.isOnline,
        lastSeen: DateTime.now(),
      );
      _onlineUsers.add(onlineUser);
    }
    
    debugPrint('📚 返回 ${_onlineUsers.length} 個好友用戶');
    return _onlineUsers;
  }

  /// 移除待處理請求（暫時空實現）
  void removePendingRequest(String requestId) {
    debugPrint('🗑️ 移除待處理請求: $requestId');
    try {
      _pendingRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 移除待處理請求失敗: $e');
    }
  }

  /// 重新連接
  void _reconnect() {
    debugPrint('🔄 重新連接...');
    try {
      // 實現重新連接邏輯
      _isConnected = false;
      notifyListeners();
      
      // 模擬重新連接過程
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          // 重新初始化控制器
          await initialize();
          
          // 重新加載數據
          await _loadFriends();
          await _loadFriendRequests();
          
          _isConnected = true;
          notifyListeners();
          debugPrint('✅ 重新連接成功');
        } catch (e) {
          debugPrint('❌ 重新連接過程中發生錯誤: $e');
          _isConnected = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('❌ 重新連接失敗: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// 接受好友請求
  Future<bool> acceptFriendRequest(FriendRequest request) async {
    try {
      debugPrint('✅ 接受好友請求: ${request.fromUserName}');
      
      // 處理好友請求接受邏輯
      // await _friendRepository.acceptFriendRequest(request.id);
      
      // 模擬處理
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 添加到好友列表
      final newFriend = Friend(
        id: request.fromUserId,
        name: request.fromUserName,
        email: request.fromUserEmail,
        phone: request.fromUserPhone,
        addedAt: DateTime.now(),
      );
      
      _friends.add(newFriend);
      _hasFriends = true;
      
      // 從請求列表中移除
      _friendRequests.removeWhere((r) => r.id == request.id);
      
      notifyListeners();
      
      debugPrint('✅ 好友請求已接受，已添加到好友列表');
      return true;
    } catch (e) {
      debugPrint('❌ 接受好友請求失敗: $e');
      return false;
    }
  }

  /// 拒絕好友請求
  Future<bool> rejectFriendRequest(FriendRequest request) async {
    try {
      debugPrint('❌ 拒絕好友請求: ${request.fromUserName}');
      
      // 處理好友請求拒絕邏輯
      // await _friendRepository.rejectFriendRequest(request.id);
      
      // 模擬處理
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 從請求列表中移除
      _friendRequests.removeWhere((r) => r.id == request.id);
      
      notifyListeners();
      
      debugPrint('✅ 好友請求已拒絕');
      return true;
    } catch (e) {
      debugPrint('❌ 拒絕好友請求失敗: $e');
      return false;
    }
  }

  /// 移除好友
  Future<bool> removeFriend(String friendId) async {
    try {
      debugPrint('🗑️ 移除好友: $friendId');
      
      // 從數據庫移除好友
      // await _friendRepository.removeFriend(friendId);
      
      // 模擬處理
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 從好友列表中移除
      _friends.removeWhere((f) => f.id == friendId);
      _hasFriends = _friends.isNotEmpty;
      
      notifyListeners();
      
      debugPrint('✅ 好友已移除');
      return true;
    } catch (e) {
      debugPrint('❌ 移除好友失敗: $e');
      return false;
    }
  }

  /// 清除搜索結果
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  /// 刷新好友列表
  Future<void> refreshFriends() async {
    debugPrint('🔄 刷新好友列表');
    await _loadFriends();
    await _loadFriendRequests();
    notifyListeners();
  }

  /// 釋放資源
  @override
  void dispose() {
    debugPrint('🧹 清理好友控制器資源...');
    super.dispose();
  }
}
