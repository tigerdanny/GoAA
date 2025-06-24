import 'dart:async';
import 'dart:convert';
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
    
    // 監聽搜索請求（回應其他用戶的搜索）
    _searchRequestSubscription = _mqttService.friendsMessageStream.listen(
      (message) {
        if (message.type == GoaaMqttMessageType.userSearchRequest) {
          _handleSearchRequest(message);
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
        debugPrint('❌ MQTT連接失敗，無法進行搜索');
        throw Exception('MQTT 連接失敗，請檢查網絡連接');
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
      // 🔧 清理和驗證搜索條件，確保UTF-8編碼安全
      final cleanName = _cleanString(searchInfo.name.trim());
      final cleanEmail = _cleanString(searchInfo.email.trim());
      final cleanPhone = _cleanString(searchInfo.phone.trim());
      final cleanUserName = _cleanString(currentUser.name);
      
      debugPrint('🔍 清理後的搜索條件:');
      debugPrint('   原始姓名: "${searchInfo.name.trim()}" -> 清理後: "$cleanName"');
      debugPrint('   原始Email: "${searchInfo.email.trim()}" -> 清理後: "$cleanEmail"');
      debugPrint('   原始電話: "${searchInfo.phone.trim()}" -> 清理後: "$cleanPhone"');
      
      // 發送搜索請求到公共搜索主題
      final searchMessage = GoaaMqttMessage(
        id: requestId,
        type: GoaaMqttMessageType.userSearchRequest,
        fromUserId: currentUser.userCode,
        toUserId: 'all', // 廣播給所有用戶
        data: {
          'requestId': requestId,
          'searchCriteria': {
            'name': cleanName,
            'email': cleanEmail,
            'phone': cleanPhone,
          },
          'requesterInfo': {
            'userId': currentUser.userCode,
            'userName': cleanUserName,
          },
        },
        group: 'friends', // 添加必需的 group 參數
      );
      
      debugPrint('🔍 發送用戶搜索請求: ${searchInfo.name}');
      debugPrint('   Email: ${searchInfo.email}');
      debugPrint('   Phone: ${searchInfo.phone}');
      
      // 發布搜索請求到MQTT
      await _mqttService.publishMessage(
        MqttTopics.userSearchRequest,
        searchMessage.toJson(),
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

  /// 處理搜索請求（其他用戶發來的搜索）
  Future<void> _handleSearchRequest(GoaaMqttMessage message) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) return;
      
      final requestId = message.data['requestId'] as String?;
      final searchCriteria = message.data['searchCriteria'] as Map<String, dynamic>?;
      final requesterInfo = message.data['requesterInfo'] as Map<String, dynamic>?;
      
      if (requestId == null || searchCriteria == null || requesterInfo == null) {
        debugPrint('❌ 搜索請求格式錯誤');
        return;
      }
      
      final requesterId = requesterInfo['userId'] as String;
      
      // 不要回應自己的搜索請求
      if (requesterId == currentUser.userCode) {
        return;
      }
      
      debugPrint('🔍 [SREQ] 收到搜索請求來自: ${requesterInfo['userName']}');
      
      // 檢查是否匹配搜索條件
      final matchScore = _calculateMatchScore(currentUser, searchCriteria);
      
      if (matchScore > 0.0) {
        debugPrint('✅ 匹配搜索條件，匹配度: $matchScore');
        
        // 發送搜索響應
        final responseMessage = GoaaMqttMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: GoaaMqttMessageType.userSearchResponse,
          fromUserId: currentUser.userCode,
          toUserId: requesterId,
          data: {
            'requestId': requestId,
            'userInfo': {
              'userId': currentUser.userCode,
              'userName': currentUser.name, // 修正：使用 name 而不是 userName
              'userCode': currentUser.userCode,
              'email': currentUser.email,
              'phone': currentUser.phone,
              'matchScore': matchScore,
            },
          },
          group: 'friends', // 添加必需的 group 參數
        );
        
        // 發布搜索響應到MQTT
        await _mqttService.publishMessage(
          MqttTopics.userSearchResponse(requesterId),
          responseMessage.toJson(),
        );
        
        debugPrint('📤 [SRESP] 已發送搜索響應給: ${requesterInfo['userName']}');
      } else {
        debugPrint('❌ 不匹配搜索條件');
      }
      
    } catch (e) {
      debugPrint('❌ 處理搜索請求失敗: $e');
    }
  }

  /// 處理搜索響應（收到的搜索結果）
  void _handleSearchResponse(GoaaMqttMessage message) {
    try {
      final requestId = message.data['requestId'] as String?;
      final userInfo = message.data['userInfo'] as Map<String, dynamic>?;
      
      if (requestId == null || userInfo == null) {
        debugPrint('❌ 搜索響應格式錯誤');
        return;
      }
      
      final completer = _searchCompleters[requestId];
      final resultsList = _searchResults[requestId];
      
      if (completer == null || completer.isCompleted || resultsList == null) {
        return;
      }
      
      debugPrint('📨 [SRESP] 收到搜索響應: ${userInfo['userName']}');
      
      // 創建搜索結果並添加到列表
      final result = UserSearchResult.fromJson(userInfo);
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

  /// 計算匹配度
  double _calculateMatchScore(dynamic currentUser, Map<String, dynamic> searchCriteria) {
    double score = 0.0;
    int matchCount = 0;
    
    final searchName = (searchCriteria['name'] as String? ?? '').toLowerCase().trim();
    final searchEmail = (searchCriteria['email'] as String? ?? '').toLowerCase().trim();
    final searchPhone = (searchCriteria['phone'] as String? ?? '').trim();
    
    // 姓名匹配 (權重最高)
    if (searchName.isNotEmpty) {
      final userName = (currentUser.name ?? '').toLowerCase(); // 修正：使用 name
      if (userName.contains(searchName) || searchName.contains(userName)) {
        score += 0.6; // 姓名匹配權重60%
        matchCount++;
      }
    }
    
    // 信箱匹配
    if (searchEmail.isNotEmpty) {
      final userEmail = (currentUser.email ?? '').toLowerCase();
      if (userEmail == searchEmail) {
        score += 0.3; // 信箱匹配權重30%
        matchCount++;
      }
    }
    
    // 電話匹配
    if (searchPhone.isNotEmpty) {
      final userPhone = (currentUser.phone ?? '').replaceAll(RegExp(r'[\s\-\(\)]'), '');
      final cleanSearchPhone = searchPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (userPhone == cleanSearchPhone) {
        score += 0.3; // 電話匹配權重30%
        matchCount++;
      }
    }
    
    // 如果沒有任何匹配，返回0
    if (matchCount == 0) {
      return 0.0;
    }
    
    // 如果至少有一個條件匹配，返回計算的分數
    return score;
  }

  /// 清理字符串，確保UTF-8編碼安全
  String _cleanString(String? input) {
    if (input == null || input.isEmpty) return '';
    
    try {
      // 移除控制字符和無效字符
      final cleaned = input.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
      
      // 驗證UTF-8編碼
      final bytes = cleaned.codeUnits;
      final validString = String.fromCharCodes(bytes);
      
      // 確保字符串可以正確JSON序列化
      final testJson = '{"test":"$validString"}';
      // 嘗試解析以驗證
      jsonDecode(testJson);
      
      return validString;
    } catch (e) {
      debugPrint('⚠️ 字符串清理失敗: $e, 原始字符串: "$input"');
      
      // 如果清理失敗，只保留ASCII字符
      final asciiOnly = input.replaceAll(RegExp(r'[^\x20-\x7E\u4e00-\u9fff]'), '');
      debugPrint('   回退到ASCII+中文字符: "$asciiOnly"');
      
      return asciiOnly;
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
