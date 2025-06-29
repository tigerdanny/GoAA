import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/database/repositories/friend_repository.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../services/friend_search_service.dart';
import '../widgets/add_friend_dialog.dart'; // 為了使用FriendSearchInfo

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
  
  // 搜索結果訂閱
  StreamSubscription<List<FriendSearchResultItem>>? _searchResultsSubscription;

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

  /// 通過MQTT搜索用戶
  Future<void> searchUsers(FriendSearchInfo searchInfo) async {
    debugPrint('🔍 開始MQTT搜索用戶: ${searchInfo.searchValue} (類型: ${searchInfo.searchType})');
    _isSearching = true;
    _searchResults.clear();
    
    // 使用scheduleMicrotask避免在build期間調用notifyListeners
    scheduleMicrotask(() => notifyListeners());
    
    try {
      final searchService = FriendSearchService();
      
      // 確保搜索服務已初始化
      await searchService.initialize();
      
      debugPrint('🔍 搜索類型: ${searchInfo.searchType}, 搜索值: ${searchInfo.searchValue}');
      
      // 開始MQTT搜索
      await searchService.searchFriends(
        searchType: searchInfo.searchType,
        searchValue: searchInfo.searchValue,
        timeout: const Duration(seconds: 10),
      );
      
      // 監聽搜索結果
      _searchResultsSubscription?.cancel();
      _searchResultsSubscription = searchService.searchResultsStream.listen((results) {
        debugPrint('📥 收到搜索結果更新: ${results.length} 個結果');
        
        // 轉換為UserSearchResult格式
        _searchResults.clear();
        for (final result in results) {
          final userResult = UserSearchResult(
            id: result.uuid,
            userId: result.uuid,
            userCode: result.userCode,
            userName: result.name,
            name: result.name,
            email: '', // MQTT回復中沒有email信息
            phone: '', // MQTT回復中沒有phone信息
            matchScore: 1.0,
            isOnline: true, // 能回復搜索的用戶都是在線的
          );
          _searchResults.add(userResult);
        }
        
        // 使用scheduleMicrotask避免在流回調中直接調用notifyListeners
        scheduleMicrotask(() => notifyListeners());
      });
      
      // 10秒後自動完成搜索
      Timer(const Duration(seconds: 10), () {
        _isSearching = false;
        scheduleMicrotask(() => notifyListeners());
        debugPrint('✅ MQTT搜索完成，共找到 ${_searchResults.length} 個結果');
      });
      
    } catch (e) {
      debugPrint('❌ MQTT搜索用戶失敗: $e');
      _isSearching = false;
      
      // 如果MQTT服務不可用，提供本地模擬搜索作為後備
      if (e.toString().contains('MQTT服務未連接')) {
        debugPrint('🔄 MQTT不可用，使用本地模擬搜索...');
        await _performLocalSearch(searchInfo);
      }
      
      scheduleMicrotask(() => notifyListeners());
    }
  }

  /// 本地模擬搜索（MQTT不可用時的後備方案）
  Future<void> _performLocalSearch(FriendSearchInfo searchInfo) async {
    debugPrint('🔍 執行本地模擬搜索: ${searchInfo.searchValue}');
    
    // 模擬網絡延遲
    await Future.delayed(const Duration(seconds: 2));
    
    // 模擬搜索結果
    final mockResults = <UserSearchResult>[];
    
    if (searchInfo.searchValue.toLowerCase() == 'danny') {
      mockResults.add(UserSearchResult(
        id: 'mock_user_1',
        userId: 'mock_user_1',
        userCode: 'MOCKUSER001',
        userName: 'Danny Chen',
        name: 'Danny Chen',
        email: 'danny@example.com',
        phone: '+886912345678',
        matchScore: 0.95,
        isOnline: true,
      ));
    }
    
    if (searchInfo.searchValue.toLowerCase().contains('test')) {
      mockResults.add(UserSearchResult(
        id: 'mock_user_2',
        userId: 'mock_user_2',
        userCode: 'TESTUSER001',
        userName: 'Test User',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+886987654321',
        matchScore: 0.85,
        isOnline: false,
      ));
    }
    
    _searchResults.clear();
    _searchResults.addAll(mockResults);
    _isSearching = false;
    
    debugPrint('✅ 本地模擬搜索完成，找到 ${mockResults.length} 個結果');
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
    _searchResultsSubscription?.cancel();
    super.dispose();
  }
}
