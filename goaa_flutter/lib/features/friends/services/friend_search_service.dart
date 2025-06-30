import 'dart:async';
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
    
    // 監聽MQTT服務的搜索回復流（不需要手動訂閱主題，MQTT服務已自動訂閱）
    _mqttService.searchResponseStream.listen(_handleSearchResponseFromMqtt);
    
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
  
  /// 處理來自MQTT服務的搜索回復
  void _handleSearchResponseFromMqtt(Map<String, dynamic> payload) {
    try {
      debugPrint('📥 從MQTT服務收到搜索回復');
      
      // 只處理當前搜索會話的回復
      final requestId = payload['requestId'] as String?;
      if (requestId != _currentSearchId) {
        debugPrint('⚠️ 不是當前搜索會話的回復，忽略');
        return;
      }
      
      // 創建搜索結果項目
      final resultItem = FriendSearchResultItem(
        uuid: payload['responderUuid'] as String,
        name: payload['responderName'] as String,
        userCode: payload['responderUserCode'] as String,
        responseTime: DateTime.parse(payload['timestamp'] as String),
      );
      
      // 檢查是否已存在（避免重複）
      if (!_currentResults.any((item) => item.uuid == resultItem.uuid)) {
        _currentResults.add(resultItem);
        debugPrint('✅ 添加搜索結果: ${resultItem.name} (${resultItem.userCode})');
        
        // 通知監聽者
        _searchResultsController.add(List.from(_currentResults));
      }
      
    } catch (e) {
      debugPrint('❌ 處理MQTT搜索回復失敗: $e');
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
