import 'package:flutter/foundation.dart';
import 'database.dart';

/// 資料庫服務
/// 管理資料庫實例的單例，提供初始化和關閉方法
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;
  
  // 🚀 優化：添加初始化狀態追蹤
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  DatabaseService._internal();

  /// 獲取資料庫服務單例
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// 獲取資料庫實例
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }
  
  /// 檢查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化資料庫
  /// 不再自動創建用戶，只確保資料庫可用
  Future<void> initialize() async {
    // 🚀 優化：避免重複初始化
    if (_isInitialized) {
      debugPrint('✅ 資料庫已初始化，跳過重複初始化');
      return;
    }
    
    if (_isInitializing) {
      debugPrint('⏳ 資料庫正在初始化中，等待完成...');
      // 等待初始化完成
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    
    _isInitializing = true;
    
          try {
        // 只初始化資料庫連接，不自動創建用戶
        final db = database;
        
        // 檢查資料庫是否可正常存取
        await (db.select(db.users)..limit(1)).get();
      
      _isInitialized = true;
      debugPrint('✅ 資料庫初始化完成（不自動創建用戶）');
    } catch (e) {
      debugPrint('❌ 資料庫初始化失敗: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }





  /// 清理資料庫連接
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  /// 🚀 獲取資料庫統計信息（重新設計使用 async/await）
  Future<Map<String, int>> getDatabaseStats() async {
    final db = database;
    
    try {
      // 🚀 並行獲取所有統計數據
      final results = await Future.wait([
        (db.select(db.users)..limit(1000)).get(),
        (db.select(db.groups)..limit(1000)).get(),
        (db.select(db.expenses)..limit(1000)).get(),
      ]);
      
      return {
        'users': (results[0] as List).length,
        'groups': (results[1] as List).length,
        'expenses': (results[2] as List).length,
      };
    } catch (e) {
      debugPrint('❌ 獲取資料庫統計失敗: $e');
      return {};
    }
  }

  /// 重置資料庫（危險操作，僅限開發模式）
  Future<void> resetDatabase() async {
    if (!kDebugMode) {
      throw Exception('重置資料庫僅限開發模式');
    }
    
    final db = database;
    
    try {
      // 清空所有表格
      await db.delete(db.expenseSplits).go();
      await db.delete(db.expenses).go();
      await db.delete(db.settlements).go();
      await db.delete(db.invitations).go();
      await db.delete(db.groupMembers).go();
      await db.delete(db.groups).go();
      await db.delete(db.users).go();
      
      // 重新初始化
      await initialize();
      
      debugPrint('資料庫重置完成');
    } catch (e) {
      debugPrint('資料庫重置失敗: $e');
      rethrow;
    }
  }
} 
