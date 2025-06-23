import 'package:flutter/foundation.dart';
import 'dart:async';
import 'mqtt_service.dart';
import 'mqtt_models.dart';
import '../user_id_service.dart';

/// APP 級別的 MQTT 服務
/// 負責統一管理 MQTT 連接，訂閱 friends 和 expenses 群組
/// 在 APP 啟動時自動連接，提供全局的 MQTT 功能
class MqttAppService {
  static final MqttAppService _instance = MqttAppService._internal();
  factory MqttAppService() => _instance;
  MqttAppService._internal();

  final MqttService _mqttService = MqttService();
  final UserIdService _userIdService = UserIdService();

  // 服務狀態
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isInitialized = false;

  // 訂閱狀態
  final Map<String, StreamSubscription> _subscriptions = {};

  // 事件流控制器
  final StreamController<List<OnlineUser>> _onlineUsersController = 
      StreamController<List<OnlineUser>>.broadcast();
  final StreamController<GoaaMqttMessage> _friendMessagesController = 
      StreamController<GoaaMqttMessage>.broadcast();
  final StreamController<GoaaMqttMessage> _expenseMessagesController = 
      StreamController<GoaaMqttMessage>.broadcast();
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();

  // Getters
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  // 事件流
  Stream<List<OnlineUser>> get onlineUsersStream => _onlineUsersController.stream;
  Stream<GoaaMqttMessage> get friendMessagesStream => _friendMessagesController.stream;
  Stream<GoaaMqttMessage> get expenseMessagesStream => _expenseMessagesController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  /// 初始化並啟動 MQTT 服務
  /// 這個方法應該在 APP 啟動時調用
  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('📡 MQTT APP 服務已初始化');
      return _isConnected;
    }

    debugPrint('🚀 初始化 MQTT APP 服務...');
    
    try {
      _isInitialized = true;
      final success = await _connectToMqtt();
      
      if (success) {
        await _subscribeToGroups();
        debugPrint('✅ MQTT APP 服務初始化成功');
      } else {
        debugPrint('❌ MQTT APP 服務初始化失敗');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ MQTT APP 服務初始化異常: $e');
      return false;
    }
  }

  /// 連接到 MQTT 服務器
  Future<bool> _connectToMqtt() async {
    if (_isConnected) return true;
    
    _isConnecting = true;
    _connectionController.add(false);

    try {
      // 獲取用戶信息
      final userId = await _userIdService.getUserId();
      final userName = 'User_${userId.substring(0, 8)}';
      final userCode = await _userIdService.getUserCode();

      debugPrint('🔗 連接 MQTT 服務器...');
      debugPrint('👤 用戶ID: ${userId.substring(0, 8)}...');
      debugPrint('🏷️ 用戶代碼: ${userCode.substring(0, 8)}...');

      // 連接 MQTT 服務
      final connected = await _mqttService.connect(
        userId: userId,
        userName: userName,
        userCode: userCode,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ MQTT 連接超時 (10秒)');
          return false;
        },
      );

      _isConnected = connected;
      _connectionController.add(connected);

      if (connected) {
        debugPrint('✅ MQTT 連接成功');
      } else {
        debugPrint('❌ MQTT 連接失敗');
      }

      return connected;
    } catch (e) {
      debugPrint('❌ MQTT 連接異常: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// 訂閱必要的群組
  Future<void> _subscribeToGroups() async {
    if (!_isConnected) return;

    debugPrint('📡 開始訂閱 MQTT 群組...');

    try {
      // 確保群組存在並訂閱
      await _ensureGroupExistsAndSubscribe('friends');
      await _ensureGroupExistsAndSubscribe('expenses');

      // 設置消息監聽
      _setupMessageListeners();

      debugPrint('✅ MQTT 群組訂閱完成');
    } catch (e) {
      debugPrint('❌ MQTT 群組訂閱失敗: $e');
    }
  }

  /// 確保群組存在並訂閱
  Future<void> _ensureGroupExistsAndSubscribe(String groupName) async {
    try {
      debugPrint('🔍 檢查群組: $groupName');
      
      // 嘗試訂閱群組
      final success = await _mqttService.subscribeToGroup(groupName);
      
      if (success) {
        debugPrint('✅ 成功訂閱群組: $groupName');
      } else {
        debugPrint('❌ 訂閱群組失敗: $groupName');
        // 如果訂閱失敗，可能是群組不存在，嘗試創建
        debugPrint('🔨 嘗試創建群組: $groupName');
        await _mqttService.createGroup(groupName);
        
        // 重新嘗試訂閱
        final retrySuccess = await _mqttService.subscribeToGroup(groupName);
        if (retrySuccess) {
          debugPrint('✅ 創建並訂閱群組成功: $groupName');
        } else {
          debugPrint('❌ 創建群組後訂閱仍失敗: $groupName');
        }
      }
    } catch (e) {
      debugPrint('❌ 處理群組 $groupName 時發生異常: $e');
    }
  }

  /// 設置消息監聽器
  void _setupMessageListeners() {
    // 監聽在線用戶
    _subscriptions['onlineUsers'] = _mqttService.onlineUsersStream.listen(
      (users) {
        _onlineUsersController.add(users);
      },
      onError: (error) {
        debugPrint('❌ 在線用戶監聽錯誤: $error');
      },
    );

    // 監聽所有消息並分發到對應的流
    _subscriptions['messages'] = _mqttService.messageStream.listen(
      (message) {
        _handleMessage(message);
      },
      onError: (error) {
        debugPrint('❌ 消息監聽錯誤: $error');
      },
    );

    // 監聽連接狀態
    _subscriptions['connection'] = _mqttService.connectionStream.listen(
      (connected) {
        _isConnected = connected;
        _connectionController.add(connected);
        
        if (!connected) {
          debugPrint('⚠️ MQTT 連接斷開，嘗試重連...');
          _attemptReconnect();
        }
      },
      onError: (error) {
        debugPrint('❌ 連接狀態監聽錯誤: $error');
      },
    );

    debugPrint('✅ MQTT 消息監聽器設置完成');
  }

  /// 處理接收到的消息
  void _handleMessage(GoaaMqttMessage message) {
    debugPrint('📨 收到消息: ${message.type} from ${message.group}');
    
    switch (message.group) {
      case 'friends':
        _friendMessagesController.add(message);
        break;
      case 'expenses':
        _expenseMessagesController.add(message);
        break;
      default:
        debugPrint('⚠️ 未知群組消息: ${message.group}');
    }
  }

  /// 嘗試重新連接
  Future<void> _attemptReconnect() async {
    if (_isConnecting) return;
    
    debugPrint('🔄 嘗試重新連接 MQTT...');
    
    // 等待一段時間後重連
    await Future.delayed(const Duration(seconds: 5));
    
    if (!_isConnected) {
      final success = await _connectToMqtt();
      if (success) {
        await _subscribeToGroups();
      }
    }
  }

  /// 發送好友消息
  Future<bool> sendFriendMessage(GoaaMqttMessage message) async {
    if (!_isConnected) {
      debugPrint('❌ MQTT 未連接，無法發送好友消息');
      return false;
    }
    
    return await _mqttService.sendMessage('friends', message);
  }

  /// 發送帳務消息
  Future<bool> sendExpenseMessage(GoaaMqttMessage message) async {
    if (!_isConnected) {
      debugPrint('❌ MQTT 未連接，無法發送帳務消息');
      return false;
    }
    
    return await _mqttService.sendMessage('expenses', message);
  }

  /// 手動重連
  Future<bool> reconnect() async {
    debugPrint('🔄 手動重新連接 MQTT...');
    
    // 先斷開現有連接
    await disconnect();
    
    // 重新連接
    final success = await _connectToMqtt();
    if (success) {
      await _subscribeToGroups();
    }
    
    return success;
  }

  /// 斷開連接
  Future<void> disconnect() async {
    debugPrint('🔌 斷開 MQTT 連接...');
    
    // 取消所有訂閱
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    
    // 斷開 MQTT 連接
    await _mqttService.disconnect();
    
    _isConnected = false;
    _connectionController.add(false);
    
    debugPrint('✅ MQTT 連接已斷開');
  }

  /// 清理資源
  Future<void> dispose() async {
    await disconnect();
    
    await _onlineUsersController.close();
    await _friendMessagesController.close();
    await _expenseMessagesController.close();
    await _connectionController.close();
    
    _isInitialized = false;
    debugPrint('✅ MQTT APP 服務已清理');
  }
} 
