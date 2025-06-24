import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/mqtt/mqtt_app_service.dart';
import '../../../core/services/mqtt/mqtt_models.dart';
import '../../../core/services/mqtt/mqtt_topics.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../widgets/add_friend_dialog.dart';

/// 基於MQTT的用戶搜索服務
class MqttUserSearchService {
  static final MqttUserSearchService _instance = MqttUserSearchService._internal();
  factory MqttUserSearchService() => _instance;
  MqttUserSearchService._internal();

  final MqttAppService _mqttService = MqttAppService();
  final UserRepository _userRepository = UserRepository();
  
  // 搜索相關狀態
  final Map<String, Completer<List<UserSearchResult>>> _searchCompleters = {};
  final Map<String, Timer> _searchTimeouts = {};
  final Map<String, List<UserSearchResult>> _searchResults = {}; // 存儲搜索結果
  StreamSubscription<GoaaMqttMessage>? _searchResponseSubscription;
  StreamSubscription<GoaaMqttMessage>? _searchRequestSubscription;
  
  bool _isInitialized = false;

  /// 初始化搜索服務
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🔍 初始化MQTT用戶搜索服務...');
    
    // 🔧 搜索請求現在由全局MqttAppService處理，此處不再重複處理
    // 監聽搜索請求（已由全局服務處理）
    _searchRequestSubscription = _mqttService.friendsMessageStream.listen(
      (message) {
        if (message.type == GoaaMqttMessageType.userSearchRequest) {
          debugPrint('🔍 [SEARCH_SERVICE] 搜索請求已由全局MqttAppService處理，跳過本地處理');
          // 搜索請求處理已完全移至全局服務，確保全應用響應能力
        }
      },
    );
    
    // 監聽搜索響應（接收搜索結果）
    _searchResponseSubscription = _mqttService.friendsMessageStream.listen(
      (message) {
        if (message.type == GoaaMqttMessageType.userSearchResponse) {
          _handleSearchResponse(message);
        }
      },
    );
    
    _isInitialized = true;
    debugPrint('✅ MQTT用戶搜索服務初始化完成');
  }

  /// 搜索用戶
  Future<List<UserSearchResult>> searchUsers(FriendSearchInfo searchInfo) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // 🔧 確保MQTT已連接，否則等待連接或嘗試重連
    if (!_mqttService.isConnected) {
      debugPrint('⚠️ MQTT未連接，嘗試重新連接...');
      await _mqttService.reconnect();
      
      // 等待連接建立（最多等待5秒）
      int attempts = 0;
      while (!_mqttService.isConnected && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (!_mqttService.isConnected) {
        debugPrint('❌ MQTT連接失敗，返回空搜索結果');
        return []; // 🔧 返回空結果而不是拋出異常，避免APP崩潰
      }
      
      debugPrint('✅ MQTT重新連接成功');
    }
    
    final currentUser = await _userRepository.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ 無法獲取當前用戶信息');
      return [];
    }
    
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<List<UserSearchResult>>();
    
    // 存儲搜索請求
    _searchCompleters[requestId] = completer;
    _searchResults[requestId] = [];
    
    // 設置超時
    _searchTimeouts[requestId] = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        final results = _searchResults.remove(requestId) ?? [];
        _searchCompleters.remove(requestId);
        _searchTimeouts.remove(requestId);
        completer.complete(results);
        debugPrint('⏰ 搜索請求超時: $requestId，返回 ${results.length} 個結果');
      }
    });
    
    try {
      // 🔧 根據搜索類型構建搜索條件
      String searchType = '';
      String searchValue = '';
      
      switch (searchInfo.searchType) {
        case SearchType.name:
          searchType = 'name';
          searchValue = searchInfo.searchValue.trim();
          break;
        case SearchType.email:
          searchType = 'email';
          searchValue = searchInfo.searchValue.trim();
          break;
        case SearchType.phone:
          searchType = 'phone';
          searchValue = searchInfo.searchValue.trim();
          break;
      }
      
      debugPrint('🔍 搜索請求格式: -search,$searchType,"$searchValue"');
      
      debugPrint('🔍 發送用戶搜索請求: -search,$searchType,"$searchValue"');
      
      // 發布搜索請求到MQTT - 最簡化格式
      await _mqttService.publishMessage(
        MqttTopics.userSearchRequest,
        {
          'type': 'userSearchRequest',
          'requestId': requestId,
          'searchType': searchType,
          'searchValue': searchValue,
          'fromUserId': currentUser.userCode,
        },
      );
      
      debugPrint('📤 [SREQ] 已發布用戶搜索請求到 ${MqttTopics.userSearchRequest}');
      
      // 等待搜索結果
      final results = await completer.future;
      debugPrint('📊 收到搜索結果: ${results.length} 個用戶');
      
      return results;
      
    } catch (e) {
      debugPrint('❌ 搜索用戶失敗: $e');
      _searchCompleters.remove(requestId);
      _searchResults.remove(requestId);
      _searchTimeouts[requestId]?.cancel();
      _searchTimeouts.remove(requestId);
      return [];
    }
  }



  /// 處理搜索響應（收到的搜索結果）
  void _handleSearchResponse(GoaaMqttMessage message) {
    try {
      final requestId = message.data['requestId'] as String?;
      final userId = message.data['userId'] as String?;
      final userName = message.data['userName'] as String?;
      
      if (requestId == null || userId == null || userName == null) {
        debugPrint('❌ 搜索響應格式錯誤');
        return;
      }
      
      final completer = _searchCompleters[requestId];
      final resultsList = _searchResults[requestId];
      
      if (completer == null || completer.isCompleted || resultsList == null) {
        return;
      }
      
      debugPrint('📨 [SRESP] 收到搜索響應: $userName');
      
      // 創建搜索結果並添加到列表
      final result = UserSearchResult.fromJson(message.data);
      resultsList.add(result);
      
      // 延遲完成，等待更多結果
      Timer(const Duration(milliseconds: 1000), () {
        if (!completer.isCompleted) {
          _completeSearch(requestId, List.from(resultsList));
        }
      });
      
    } catch (e) {
      debugPrint('❌ 處理搜索響應失敗: $e');
    }
  }

  /// 完成搜索
  void _completeSearch(String requestId, List<UserSearchResult> results) {
    final completer = _searchCompleters.remove(requestId);
    final timer = _searchTimeouts.remove(requestId);
    
    _searchResults.remove(requestId);
    timer?.cancel();
    
    if (completer != null && !completer.isCompleted) {
      completer.complete(results);
    }
  }



  /// 清理資源
  void dispose() {
    debugPrint('🧹 清理MQTT用戶搜索服務資源...');
    
    _searchRequestSubscription?.cancel();
    _searchResponseSubscription?.cancel();
    
    // 取消所有等待中的搜索
    for (final completer in _searchCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete([]);
      }
    }
    _searchCompleters.clear();
    _searchResults.clear();
    
    // 取消所有超時計時器
    for (final timer in _searchTimeouts.values) {
      timer.cancel();
    }
    _searchTimeouts.clear();
    
    _isInitialized = false;
  }
} 
