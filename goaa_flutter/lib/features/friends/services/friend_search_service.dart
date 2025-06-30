import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/mqtt/mqtt_service.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../../../core/database/repositories/user_repository.dart';

/// 好友搜尋結果模型
class FriendSearchResult {
  final String name;
  final String userCode;
  final String email;
  final String? phone;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;

  FriendSearchResult({
    required this.name,
    required this.userCode,
    required this.email,
    this.phone,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
  });
}

/// MQTT好友搜尋服務
class FriendSearchService {
  static final FriendSearchService _instance = FriendSearchService._internal();
  factory FriendSearchService() => _instance;
  FriendSearchService._internal();

  final MqttService _mqttService = MqttService();
  final UserRepository _userRepository = UserRepository();
  
  // MQTT主題定義
  static const String _searchRequestTopic = 'goaa/friend/search/request';
  static const String _searchResponseTopic = 'goaa/friend/search/response';
  
  // 搜索結果流控制器
  final StreamController<List<FriendSearchResultItem>> _searchResultsController = 
      StreamController<List<FriendSearchResultItem>>.broadcast();
  
  // 當前搜索會話
  String? _currentSearchId;
  final List<FriendSearchResultItem> _currentResults = [];
  Timer? _searchTimeoutTimer;
  
  // 獲取搜索結果流
  Stream<List<FriendSearchResultItem>> get searchResultsStream => _searchResultsController.stream;
  
  /// 初始化搜索服務
  Future<void> initialize() async {
    debugPrint('🔍 初始化MQTT好友搜索服務...');
    
    // 確保MQTT服務已連接
    if (!_mqttService.isConnected) {
      debugPrint('⚠️ MQTT服務未連接，等待連接...');
      await _waitForMqttConnection();
    }
    
    // 訂閱搜索相關主題
    await _subscribeToSearchTopics();
    
    // 監聽MQTT消息
    _mqttService.messageStream.listen(_handleMqttMessage);
    
    debugPrint('✅ MQTT好友搜索服務初始化完成');
  }
  
  /// 等待MQTT連接
  Future<void> _waitForMqttConnection() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = _mqttService.connectionStateStream.listen((state) {
      if (state == GoaaMqttConnectionState.connected) {
        subscription.cancel();
        completer.complete();
      }
    });
    
    // 設置超時
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        debugPrint('⏰ 等待MQTT連接超時');
        subscription.cancel();
        completer.complete();
      }
    });
    
    await completer.future;
  }
  
  /// 訂閱搜索相關主題
  Future<void> _subscribeToSearchTopics() async {
    try {
      await _mqttService.subscribeToTopic(_searchRequestTopic);
      await _mqttService.subscribeToTopic(_searchResponseTopic);
      debugPrint('✅ 已訂閱好友搜索主題');
    } catch (e) {
      debugPrint('❌ 訂閱好友搜索主題失敗: $e');
    }
  }
  
  /// 處理MQTT消息
  void _handleMqttMessage(dynamic message) {
    try {
      if (message is! Map<String, dynamic>) return;
      
      final topic = message['topic'] as String?;
      final payload = message['payload'] as String?;
      
      if (topic == null || payload == null) return;
      
      if (topic == _searchRequestTopic) {
        _handleSearchRequest(payload);
      } else if (topic == _searchResponseTopic) {
        _handleSearchResponse(payload);
      }
    } catch (e) {
      debugPrint('❌ 處理MQTT消息失敗: $e');
    }
  }
  
  /// 處理搜索請求
  void _handleSearchRequest(String payload) async {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final request = FriendSearchRequest.fromJson(data);
      
      debugPrint('📥 收到好友搜索請求: ${request.searchType} = ${request.searchValue}');
      
      // 取得當前用戶資料
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('⚠️ 無法取得當前用戶資料');
        return;
      }
      
      // 跳過自己發布的搜索請求
      if (request.publisherUuid == currentUser.userCode) {
        debugPrint('⏭️ 跳過自己的搜索請求');
        return;
      }
      
      // 比對搜索條件
      bool isMatch = false;
      switch (request.searchType) {
        case 'name':
          isMatch = currentUser.name.toLowerCase().contains(request.searchValue.toLowerCase());
          break;
        case 'email':
          isMatch = (currentUser.email ?? '').toLowerCase().contains(request.searchValue.toLowerCase());
          break;
        case 'phone':
          isMatch = (currentUser.phone ?? '').contains(request.searchValue);
          break;
        default:
          debugPrint('⚠️ 未知的搜索類型: ${request.searchType}');
          return;
      }
      
      if (isMatch) {
        debugPrint('✅ 搜索條件匹配，發送回復');
        await _sendSearchResponse(request, currentUser);
      } else {
        debugPrint('❌ 搜索條件不匹配');
      }
      
    } catch (e) {
      debugPrint('❌ 處理搜索請求失敗: $e');
    }
  }
  
  /// 發送搜索回復
  Future<void> _sendSearchResponse(FriendSearchRequest request, dynamic currentUser) async {
    try {
      final response = FriendSearchResponse(
        requestId: request.requestId,
        responderUuid: currentUser.userCode,
        searcherUuid: request.publisherUuid,
        responderName: currentUser.name,
        responderUserCode: currentUser.userCode,
        timestamp: DateTime.now(),
      );
      
      final payload = response.toJson();
      await _mqttService.publishMessage(
        topic: _searchResponseTopic,
        payload: payload,
      );
      
      debugPrint('📤 已發送搜索回復給: ${request.publisherUuid}');
    } catch (e) {
      debugPrint('❌ 發送搜索回復失敗: $e');
    }
  }
  
  /// 處理搜索回復
  void _handleSearchResponse(String payload) async {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final response = FriendSearchResponse.fromJson(data);
      
      // 取得當前用戶資料
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) return;
      
      // 只處理給自己的回復
      if (response.searcherUuid != currentUser.userCode) {
        return;
      }
      
      // 檢查是否為當前搜索會話
      if (response.requestId != _currentSearchId) {
        debugPrint('⚠️ 收到非當前搜索會話的回復，忽略');
        return;
      }
      
      debugPrint('📥 收到搜索回復: ${response.responderName}');
      
      // 添加到搜索結果
      final resultItem = FriendSearchResultItem(
        uuid: response.responderUuid,
        name: response.responderName,
        userCode: response.responderUserCode,
        responseTime: response.timestamp,
      );
      
      // 檢查是否已存在（避免重複）
      final existingIndex = _currentResults.indexWhere((item) => item.uuid == resultItem.uuid);
      if (existingIndex == -1) {
        _currentResults.add(resultItem);
        // 按回復時間排序
        _currentResults.sort((a, b) => a.responseTime.compareTo(b.responseTime));
        
        // 通知搜索結果更新
        _searchResultsController.add(List.from(_currentResults));
      }
      
    } catch (e) {
      debugPrint('❌ 處理搜索回復失敗: $e');
    }
  }
  
  /// 執行好友搜索
  Future<void> searchFriends({
    required String searchType,
    required String searchValue,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    debugPrint('🔍 開始搜索好友: $searchType = $searchValue');
    
    // 取得當前用戶資料
    final currentUser = await _userRepository.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ 無法取得當前用戶資料');
      throw Exception('無法取得當前用戶資料');
    }
    
    // 檢查MQTT連接
    if (!_mqttService.isConnected) {
      debugPrint('❌ MQTT服務未連接');
      throw Exception('MQTT服務未連接');
    }
    
    // 創建新的搜索會話
    _currentSearchId = const Uuid().v4();
    _currentResults.clear();
    
    // 創建搜索請求
    final request = FriendSearchRequest(
      requestId: _currentSearchId!,
      publisherUuid: currentUser.userCode,
      searchType: searchType,
      searchValue: searchValue,
      timestamp: DateTime.now(),
    );
    
    try {
      // 發布搜索請求
      final payload = request.toJson();
      await _mqttService.publishMessage(
        topic: _searchRequestTopic,
        payload: payload,
      );
      
      debugPrint('📤 已發布搜索請求: $_currentSearchId');
      
      // 初始化搜索結果
      _searchResultsController.add([]);
      
      // 設置搜索超時
      _searchTimeoutTimer?.cancel();
      _searchTimeoutTimer = Timer(timeout, () {
        debugPrint('⏰ 搜索超時，完成搜索');
        _completeSearch();
      });
      
    } catch (e) {
      debugPrint('❌ 發布搜索請求失敗: $e');
      _currentSearchId = null;
      _currentResults.clear();
      rethrow;
    }
  }
  
  /// 完成搜索
  void _completeSearch() {
    debugPrint('✅ 搜索完成，找到 ${_currentResults.length} 個結果');
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = null;
  }
  
  /// 停止當前搜索
  void stopSearch() {
    debugPrint('🛑 停止當前搜索');
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = null;
    _currentSearchId = null;
    _currentResults.clear();
    _searchResultsController.add([]);
  }
  
  /// 清理資源
  void dispose() {
    debugPrint('🧹 清理好友搜索服務資源...');
    _searchTimeoutTimer?.cancel();
    _searchResultsController.close();
  }
} 
