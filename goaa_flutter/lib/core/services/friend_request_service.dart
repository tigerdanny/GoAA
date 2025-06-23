import 'package:flutter/foundation.dart';
import 'dart:async';

/// 獨立的好友請求監聽服務
/// 這個服務在應用啟動時就開始運行，完全獨立於 UI 組件
/// 負責監聽和處理所有好友請求相關的通知
class FriendRequestService {
  static final FriendRequestService _instance = FriendRequestService._internal();
  factory FriendRequestService() => _instance;
  FriendRequestService._internal();

  // 服務狀態
  bool _isRunning = false;
  StreamController<String>? _requestController;
  Timer? _pollingTimer;

  /// 服務是否正在運行
  bool get isRunning => _isRunning;

  /// 好友請求事件流
  Stream<String>? get requestStream => _requestController?.stream;

  /// 啟動好友請求監聽服務
  /// 這個方法應該在應用啟動時調用，且只調用一次
  Future<void> startService() async {
    if (_isRunning) {
      debugPrint('📬 好友請求服務已在運行中');
      return;
    }

    try {
      debugPrint('🚀 啟動獨立好友請求監聽服務...');
      
      // 初始化事件流
      _requestController = StreamController<String>.broadcast();
      
      // 方案選擇（按優先級）:
      // 1. 推送通知 (FCM) - 最佳方案
      // 2. WebSocket 長連接 - 次佳方案  
      // 3. 定時輪詢 - 備用方案
      
      await _startPollingMethod(); // 暫時使用輪詢方案
      
      _isRunning = true;
      debugPrint('✅ 好友請求監聽服務已啟動（獨立運行）');
      
    } catch (e) {
      debugPrint('❌ 好友請求監聽服務啟動失敗: $e');
      _isRunning = false;
      await _cleanup();
    }
  }

  /// 停止好友請求監聽服務
  Future<void> stopService() async {
    if (!_isRunning) return;
    
    debugPrint('🛑 停止好友請求監聽服務...');
    
    _isRunning = false;
    await _cleanup();
    
    debugPrint('✅ 好友請求監聽服務已停止');
  }

  /// 啟動定時輪詢方法（備用方案）
  Future<void> _startPollingMethod() async {
    debugPrint('🔄 啟動定時輪詢好友請求...');
    
    // 每30秒檢查一次好友請求
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkFriendRequests();
    });
    
    // 立即執行一次檢查
    await _checkFriendRequests();
  }

  /// 檢查好友請求（實際實現）
  Future<void> _checkFriendRequests() async {
    try {
      // TODO: 實際實現
      // 1. 查詢本地數據庫的好友請求表
      // 2. 或者調用服務器 API 檢查新請求
      // 3. 如果有新請求，發送本地通知
      
      debugPrint('🔍 檢查好友請求...');
      
      // 暫時的模擬實現
      // final hasNewRequests = await _checkLocalDatabase();
      // if (hasNewRequests) {
      //   _requestController?.add('新的好友請求');
      //   await _showLocalNotification();
      // }
      
    } catch (e) {
      debugPrint('❌ 檢查好友請求時出錯: $e');
    }
  }

  /// 顯示本地通知
  Future<void> _showLocalNotification() async {
    try {
      // TODO: 使用 flutter_local_notifications 顯示通知
      debugPrint('📱 顯示好友請求通知');
    } catch (e) {
      debugPrint('❌ 顯示通知失敗: $e');
    }
  }

  /// 清理資源
  Future<void> _cleanup() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    
    await _requestController?.close();
    _requestController = null;
  }

  /// 手動觸發好友請求檢查（供外部調用）
  Future<void> checkNow() async {
    if (_isRunning) {
      await _checkFriendRequests();
    }
  }
} 
