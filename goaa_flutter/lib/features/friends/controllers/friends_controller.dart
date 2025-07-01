import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/repositories/friend_repository.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../../../core/services/mqtt/mqtt_service.dart';
import '../services/friend_search_service.dart';
import '../widgets/add_friend_dialog.dart'; // 為了使用FriendSearchInfo

/// 發送好友請求的結果狀態
enum FriendRequestResult {
  success,           // 成功發送
  alreadyFriend,     // 已經是好友
  alreadySent,       // 已經發送過請求
  inWaitingList,     // 該人已在等待添加好友名單中
  failed,            // 發送失敗
}

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

  /// 轉換為JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'fromUserEmail': fromUserEmail,
    'fromUserPhone': fromUserPhone,
    'requestTime': requestTime.toIso8601String(),
    'status': status,
  };

  /// 從JSON創建實例
  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'] as String,
    fromUserId: json['fromUserId'] as String,
    fromUserName: json['fromUserName'] as String,
    fromUserEmail: json['fromUserEmail'] as String? ?? '',
    fromUserPhone: json['fromUserPhone'] as String? ?? '',
    requestTime: DateTime.parse(json['requestTime'] as String),
    status: json['status'] as String? ?? 'pending',
  );
}

/// 好友功能控制器（無MQTT版本）
/// 負責管理好友列表、好友請求等功能
class FriendsController extends ChangeNotifier {
  final FriendRepository _friendRepository = FriendRepository();
  final UserRepository _userRepository = UserRepository();

  // SharedPreferences 鍵值常量
  static const String _pendingRequestsKey = 'pending_friend_requests';
  static const String _friendRequestsKey = 'received_friend_requests';

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

  /// 保存待處理的好友請求到SharedPreferences
  Future<void> _savePendingRequestsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _pendingRequests.map((request) => request.toJson()).toList();
      final jsonString = jsonEncode(requestsJson);
      await prefs.setString(_pendingRequestsKey, jsonString);
      debugPrint('💾 已保存 ${_pendingRequests.length} 個待處理好友請求到本地存儲');
    } catch (e) {
      debugPrint('❌ 保存待處理好友請求失敗: $e');
    }
  }

  /// 從SharedPreferences加載待處理的好友請求
  Future<void> _loadPendingRequestsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingRequestsKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> requestsJson = jsonDecode(jsonString);
        _pendingRequests.clear();
        
        for (final requestJson in requestsJson) {
          if (requestJson is Map<String, dynamic>) {
            final request = PendingFriendRequest.fromJson(requestJson);
            _pendingRequests.add(request);
          }
        }
        
        debugPrint('📱 從本地存儲加載了 ${_pendingRequests.length} 個待處理好友請求');
      } else {
        debugPrint('📱 本地存儲中沒有待處理好友請求');
      }
    } catch (e) {
      debugPrint('❌ 從本地存儲加載待處理好友請求失敗: $e');
      _pendingRequests.clear();
    }
  }

  /// 保存收到的好友請求到SharedPreferences
  Future<void> _saveFriendRequestsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _friendRequests.map((request) => request.toJson()).toList();
      final jsonString = jsonEncode(requestsJson);
      await prefs.setString(_friendRequestsKey, jsonString);
      debugPrint('💾 已保存 ${_friendRequests.length} 個收到的好友請求到本地存儲');
    } catch (e) {
      debugPrint('❌ 保存收到的好友請求失敗: $e');
    }
  }

  /// 從SharedPreferences加載收到的好友請求
  Future<void> _loadFriendRequestsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_friendRequestsKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> requestsJson = jsonDecode(jsonString);
        _friendRequests.clear();
        
        for (final requestJson in requestsJson) {
          if (requestJson is Map<String, dynamic>) {
            final request = FriendRequest.fromJson(requestJson);
            _friendRequests.add(request);
          }
        }
        
        debugPrint('📱 從本地存儲加載了 ${_friendRequests.length} 個收到的好友請求');
      } else {
        debugPrint('📱 本地存儲中沒有收到的好友請求');
      }
    } catch (e) {
      debugPrint('❌ 從本地存儲加載收到的好友請求失敗: $e');
      _friendRequests.clear();
    }
  }

  /// 處理收到的好友請求（來自MQTT私人消息）
  Future<bool> handleReceivedFriendRequest({
    required String fromUserId,
    required String fromUserName,
    required String fromUserEmail,
    required String fromUserPhone,
    String? message,
  }) async {
    debugPrint('📨 收到好友請求: $fromUserName ($fromUserId)');
    
    try {
      // 檢查是否已經是好友
      final isAlreadyFriend = _friends.any((friend) => friend.id == fromUserId);
      if (isAlreadyFriend) {
        debugPrint('⚠️ 用戶 $fromUserName 已經是好友，忽略請求');
        return false;
      }
      
      // 檢查是否已經有相同的待處理請求
      final hasExistingRequest = _friendRequests.any((request) => 
          request.fromUserId == fromUserId && request.status == 'pending');
      if (hasExistingRequest) {
        debugPrint('⚠️ 已經有來自 $fromUserName 的待處理好友請求，忽略重複請求');
        return false;
      }
      
      // 創建新的好友請求
      final friendRequest = FriendRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserEmail: fromUserEmail,
        fromUserPhone: fromUserPhone,
        requestTime: DateTime.now(),
        status: 'pending',
      );
      
      // 添加到好友請求列表
      _friendRequests.add(friendRequest);
      
      // 保存到本地存儲
      await _saveFriendRequestsToStorage();
      
      // 通知UI更新
      notifyListeners();
      
      debugPrint('✅ 好友請求已添加到要求添加好友名單: $fromUserName');
      debugPrint('📋 當前共有 ${_friendRequests.length} 個待處理的好友請求');
      
      return true;
    } catch (e) {
      debugPrint('❌ 處理收到的好友請求失敗: $e');
      return false;
    }
  }

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
      
      // 清空現有數據
      _friendRequests.clear();
      _pendingRequests.clear();
      
      // 從本地存儲加載待處理的好友請求
      await _loadPendingRequestsFromStorage();
      
      // 從本地存儲加載收到的好友請求
      await _loadFriendRequestsFromStorage();
      
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
  Future<String> sendFriendRequestToUser(UserSearchResult user) async {
    debugPrint('📤 發送好友請求給: ${user.name}');
    try {
      // 獲取當前用戶
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('❌ 沒有當前用戶，無法發送好友請求');
        return 'failed';
      }
      
      // 檢查是否已經是好友
      final isAlreadyFriend = _friends.any((friend) => friend.id == user.userId);
      if (isAlreadyFriend) {
        debugPrint('⚠️ 用戶已經是好友了');
        return 'alreadyFriend';
      }
      
      // 檢查該人是否已在等待添加好友名單中（根據UUID檢查）
      final isInWaitingList = _friendRequests.any((request) => 
          request.fromUserId == user.userId || request.fromUserId == user.id);
      if (isInWaitingList) {
        debugPrint('⚠️ 該人已在等待添加好友名單中');
        return 'inWaitingList';
      }
      
      // 檢查是否已經發送過請求
      final hasExistingRequest = _pendingRequests.any((request) => 
          request.fromUserId == currentUser.id.toString() && 
          request.targetName == user.name);
      if (hasExistingRequest) {
        debugPrint('⚠️ 已經發送過好友請求了');
        return 'alreadySent';
      }

      // 獲取MQTT服務實例
      final mqttService = MqttService();
      
      // 1. 訂閱該用戶的私人消息主題
      final subscriptionSuccess = await mqttService.subscribeToUserPrivateMessages(user.userCode);
      if (!subscriptionSuccess) {
        debugPrint('⚠️ 訂閱私人消息主題失敗，但繼續發送請求');
      }
      
      // 2. 向該用戶發送好友請求私人消息
      final messageSuccess = await mqttService.sendFriendRequestMessage(
        targetUserCode: user.userCode,
        myName: currentUser.name,
        myEmail: currentUser.email ?? '',
        myPhone: currentUser.phone ?? '',
      );
      
      if (!messageSuccess) {
        debugPrint('❌ 發送好友請求消息失敗');
        return 'failed';
      }
      
      // 3. 創建新的待處理請求並加入本地資料庫
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
        message: 'Hello! I would like to add you as a friend. Please accept my friend request.',
      );
      
      // 添加到待處理列表
      _pendingRequests.add(pendingRequest);
      
      // 保存到本地資料庫
      await _savePendingRequestsToStorage();
      
      notifyListeners();
      
      debugPrint('✅ 好友請求已發送 - 已訂閱私人消息，已發送請求消息，已加入等待名單');
      return 'success';
    } catch (e) {
      debugPrint('❌ 發送好友請求失敗: $e');
      return 'failed';
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
      // 保存更改到本地存儲
      _savePendingRequestsToStorage();
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
      
      // 保存更改到本地存儲
      await _saveFriendRequestsToStorage();
      
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
      
      // 保存更改到本地存儲
      await _saveFriendRequestsToStorage();
      
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

  /// 示例：處理來自MQTT私人消息的好友請求
  /// 這個方法可以在MQTT消息處理器中調用
  Future<void> handleMqttFriendRequestMessage({
    required Map<String, dynamic> messageData,
  }) async {
    debugPrint('📨 處理MQTT好友請求消息: $messageData');
    
    try {
      // 從MQTT消息中提取必要信息
      final fromUserId = messageData['fromUserId'] as String?;
      final fromUserName = messageData['fromUserName'] as String?;
      final fromUserEmail = messageData['fromUserEmail'] as String? ?? '';
      final fromUserPhone = messageData['fromUserPhone'] as String? ?? '';
      final message = messageData['message'] as String?;
      
      // 驗證必需字段
      if (fromUserId == null || fromUserName == null) {
        debugPrint('⚠️ MQTT好友請求消息缺少必需字段');
        return;
      }
      
      // 處理好友請求
      final success = await handleReceivedFriendRequest(
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserEmail: fromUserEmail,
        fromUserPhone: fromUserPhone,
        message: message,
      );
      
      if (success) {
        debugPrint('✅ MQTT好友請求處理成功');
      } else {
        debugPrint('⚠️ MQTT好友請求處理失敗或被忽略');
      }
    } catch (e) {
      debugPrint('❌ 處理MQTT好友請求消息失敗: $e');
    }
  }

  /// 釋放資源
  @override
  void dispose() {
    debugPrint('🧹 清理好友控制器資源...');
    _searchResultsSubscription?.cancel();
    super.dispose();
  }
}
