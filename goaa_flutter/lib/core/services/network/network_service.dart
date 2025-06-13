import 'dart:async';
import 'dart:io';
import '../logger_service.dart';
import 'package:flutter/foundation.dart';

/// 網路服務
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  
  bool _isConnected = true;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  DateTime? _lastCheckTime;

  final LoggerService _logger = LoggerService();

  NetworkService._internal();

  /// 網路連接狀態流
  Stream<bool> get connectionStream => _connectionController.stream;

  /// 當前網路狀態
  bool get isConnected => _isConnected;

  /// 檢查網路是否可用
  Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      return result.isNotEmpty;
    } catch (e) {
      _logger.error('網路檢查失敗', e);
      return false;
    }
  }

  /// 獲取網路狀態
  Map<String, dynamic> getNetworkStatus() {
    return {
      'isOffline': !_isConnected,
      'lastCheck': _lastCheckTime?.toIso8601String(),
    };
  }

  /// 重置網路狀態
  void resetNetworkStatus() {
    _isConnected = true;
    _lastCheckTime = null;
    _connectionController.add(_isConnected);
  }

  /// 檢查網路連接
  Future<bool> checkConnection() async {
    try {
      // 這裡可以實現實際的網路檢查邏輯
      // 例如：ping 一個可靠的服務器
      _isConnected = true;
      _connectionController.add(_isConnected);
      return _isConnected;
    } catch (e) {
      debugPrint('網路檢查失敗: $e');
      _isConnected = false;
      _connectionController.add(_isConnected);
      return false;
    }
  }

  /// 釋放資源
  void dispose() {
    _connectionController.close();
  }
} 
