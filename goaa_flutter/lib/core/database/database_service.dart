import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'database.dart';
import 'dart:math';

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
  /// 創建初始用戶和示例數據
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
      final db = database;
      
      // 檢查是否已有當前用戶
      final currentUser = await db.userQueries.getCurrentUser();
      
      if (currentUser == null) {
        // 創建初始用戶
        await _createInitialUser();
        
        if (kDebugMode) {
          // 開發模式下創建示例數據
          await _createSampleData();
        }
      }
      
      _isInitialized = true;
      debugPrint('✅ 資料庫初始化完成');
    } catch (e) {
      debugPrint('❌ 資料庫初始化失敗: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// 創建初始用戶
  Future<void> _createInitialUser() async {
    final db = database;
    
    // 生成用戶代碼
    final userCode = _generateUserCode();
    debugPrint('生成新用戶代碼: $userCode');
    
    final user = UsersCompanion.insert(
      userCode: userCode,
      name: '使用者名稱',
      avatarType: const Value('male_01'),
      isCurrentUser: const Value(true),
    );
    
    final userId = await db.userQueries.insertOrUpdateUser(user);
    debugPrint('創建初始用戶成功 - ID: $userId, 代碼: $userCode, 名稱: 使用者名稱');
    
    // 验证用户是否创建成功
    final createdUser = await db.userQueries.getCurrentUser();
    debugPrint('驗證當前用戶: ${createdUser?.name ?? 'null'}, 代碼: ${createdUser?.userCode ?? 'null'}');
  }

  /// 創建示例數據（僅限開發模式）
  Future<void> _createSampleData() async {
    final db = database;
    final currentUser = await db.userQueries.getCurrentUser();
    if (currentUser == null) return;

    try {
      // 創建示例群組
      final groupId = await db.groupQueries.createGroup(GroupsCompanion.insert(
        name: '室友分攤',
        description: const Value('與室友一起分攤日常開支'),
        createdBy: currentUser.id,
      ));

      // 將當前用戶添加到群組（作為管理員）
      await db.groupQueries.addGroupMember(groupId, currentUser.id, role: 'admin');

      // 創建其他示例用戶
      final user2Id = await db.userQueries.insertOrUpdateUser(UsersCompanion.insert(
        userCode: _generateUserCode(),
        name: '室友小王',
        avatarType: const Value('female_01'),
      ));

      final user3Id = await db.userQueries.insertOrUpdateUser(UsersCompanion.insert(
        userCode: _generateUserCode(),
        name: '室友小李',
        avatarType: const Value('male_02'),
      ));

      // 將其他用戶添加到群組
      await db.groupQueries.addGroupMember(groupId, user2Id);
      await db.groupQueries.addGroupMember(groupId, user3Id);

      // 創建示例支出
      final expenseId = await db.expenseQueries.createExpense(ExpensesCompanion.insert(
        groupId: groupId,
        paidBy: currentUser.id,
        title: '購買日用品',
        description: const Value('衛生紙、洗衣精等'),
        amount: 450.0,
        expenseDate: DateTime.now().subtract(const Duration(hours: 2)),
      ));

      // 創建支出分攤
      await db.expenseQueries.createExpenseSplits([
        ExpenseSplitsCompanion.insert(
          expenseId: expenseId,
          userId: currentUser.id,
          amount: 150.0,
        ),
        ExpenseSplitsCompanion.insert(
          expenseId: expenseId,
          userId: user2Id,
          amount: 150.0,
        ),
        ExpenseSplitsCompanion.insert(
          expenseId: expenseId,
          userId: user3Id,
          amount: 150.0,
        ),
      ]);

      debugPrint('創建示例數據完成');
    } catch (e) {
      debugPrint('創建示例數據失敗: $e');
    }
  }

  /// 生成用戶代碼 - 🎲 使用更好的隨機數生成
  String _generateUserCode() {
    final now = DateTime.now();
    // 使用多個時間源創建真正的隨機數
    final microseconds = now.microsecondsSinceEpoch;
    final random = Random(microseconds);
    
    // 結合時間和隨機數，確保唯一性
    final timeComponent = microseconds % 1000000;
    final randomComponent = random.nextInt(999999);
    final combined = (timeComponent + randomComponent) % 1000000;
    
    final userCode = 'GA${combined.toString().padLeft(6, '0')}';
    debugPrint('🎲 生成用戶代碼: $userCode (時間: $timeComponent, 隨機: $randomComponent)');
    return userCode;
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
