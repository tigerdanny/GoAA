import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:goaa_flutter/core/services/user_id_service.dart';
import 'package:goaa_flutter/core/database/database_service.dart';

/// 啟動頁狀態
enum SplashState {
  initializing,
  loading,
  completed,
  error,
}

/// 啟動頁控制器
class SplashController extends ChangeNotifier {
  final UserIdService _userIdService = UserIdService();

  SplashState _state = SplashState.initializing;
  String _message = '正在初始化...';
  String? _errorMessage;

  // Getters
  SplashState get state => _state;
  String get message => _message;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SplashState.loading || _state == SplashState.initializing;
  bool get isCompleted => _state == SplashState.completed;
  bool get hasError => _state == SplashState.error;

  /// 開始初始化流程
  Future<void> initialize() async {
    try {
      _updateState(SplashState.loading, '正在初始化應用...');

      // 步驟1: 初始化用戶ID服務
      _updateMessage('正在設置用戶身份...');
      await _userIdService.getUserId();
      await _delay(500);

      // 步驟2: 初始化數據庫
      _updateMessage('正在初始化數據庫...');
      await DatabaseService.instance.initialize();
      await _delay(500);

      // 步驟3: 執行數據庫遷移和清理
      _updateMessage('正在檢查數據完整性...');
      await _performDatabaseMaintenance();
      await _delay(500);

      // 步驟4: 預加載必要資源
      _updateMessage('正在加載資源...');
      await _preloadResources();
      await _delay(500);

      // 完成初始化
      _updateState(SplashState.completed, '初始化完成');
      
    } catch (e) {
      debugPrint('啟動頁初始化失敗: $e');
      _updateState(SplashState.error, '初始化失敗');
      _errorMessage = e.toString();
    }
  }

  /// 執行數據庫維護
  Future<void> _performDatabaseMaintenance() async {
    try {
      // 這裡可以添加數據庫清理邏輯
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('數據庫維護失敗: $e');
      // 非關鍵錯誤，繼續執行
    }
  }

  /// 預加載資源
  Future<void> _preloadResources() async {
    try {
      // 這裡可以預加載圖片、字體等資源
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('資源預加載失敗: $e');
      // 非關鍵錯誤，繼續執行
    }
  }

  /// 重新初始化
  Future<void> retry() async {
    _errorMessage = null;
    await initialize();
  }

  /// 更新狀態
  void _updateState(SplashState newState, String newMessage) {
    _state = newState;
    _message = newMessage;
    notifyListeners();
  }

  /// 更新消息
  void _updateMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }

  /// 延遲執行（用於顯示動畫效果）
  Future<void> _delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
} 
