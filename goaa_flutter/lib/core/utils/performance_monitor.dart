import 'package:flutter/foundation.dart';

/// 性能監控工具
/// 用於追蹤應用啟動時間和各個階段的性能
class PerformanceMonitor {
  static final Map<String, DateTime> _timestamps = {};
  static final Map<String, Duration> _durations = {};
  
  /// 記錄時間點
  static void recordTimestamp(String name) {
    _timestamps[name] = DateTime.now();
    if (kDebugMode) {
      debugPrint('🕐 [$name] 時間點記錄: ${DateTime.now().millisecondsSinceEpoch}');
    }
  }
  
  /// 記錄持續時間（從開始到結束）
  static void recordDuration(String name, String startPoint, String endPoint) {
    final start = _timestamps[startPoint];
    final end = _timestamps[endPoint];
    
    if (start != null && end != null) {
      _durations[name] = end.difference(start);
      if (kDebugMode) {
        debugPrint('⏱️ [$name] 持續時間: ${_durations[name]?.inMilliseconds}ms');
      }
    }
  }
  
  /// 記錄從指定時間點到現在的持續時間
  static void recordDurationFromNow(String name, String startPoint) {
    final start = _timestamps[startPoint];
    if (start != null) {
      final duration = DateTime.now().difference(start);
      _durations[name] = duration;
      if (kDebugMode) {
        debugPrint('⏱️ [$name] 持續時間: ${duration.inMilliseconds}ms');
      }
    }
  }
  
  /// 打印性能報告
  static void printPerformanceReport() {
    if (!kDebugMode) return;
    
    debugPrint('\n📊 ========== 性能報告 ==========');
    debugPrint('🕐 時間點記錄:');
    _timestamps.forEach((name, time) {
      debugPrint('  [$name]: ${time.millisecondsSinceEpoch}');
    });
    
    debugPrint('\n⏱️ 持續時間記錄:');
    _durations.forEach((name, duration) {
      debugPrint('  [$name]: ${duration.inMilliseconds}ms');
    });
    debugPrint('================================\n');
  }
  
  /// 清空記錄
  static void clear() {
    _timestamps.clear();
    _durations.clear();
  }
  
  /// 獲取特定持續時間
  static Duration? getDuration(String name) {
    return _durations[name];
  }
  
  /// 獲取總啟動時間
  static Duration? getTotalStartupTime() {
    return getDuration('總啟動時間');
  }
} 
