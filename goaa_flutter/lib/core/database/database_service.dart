import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'database.dart';

/// 資料庫服務
/// 管理資料庫實例的單例，提供初始化和關閉方法
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

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

  /// 初始化資料庫
  /// 創建初始用戶和示例數據
  Future<void> initialize() async {
    try {
      final db = database;
      
      // 檢查是否已有當前用戶
      final currentUser = await db.getCurrentUser();
      
      if (currentUser == null) {
        // 創建初始用戶
        await _createInitialUser();
        
        if (kDebugMode) {
          // 開發模式下創建示例數據
          await _createSampleData();
        }
      }
      
      debugPrint('資料庫初始化完成');
    } catch (e) {
      debugPrint('資料庫初始化失敗: $e');
      rethrow;
    }
  }

  /// 創建初始用戶
  Future<void> _createInitialUser() async {
    final db = database;
    
    // 生成用戶代碼
    final userCode = _generateUserCode();
    
    final user = UsersCompanion.insert(
      userCode: userCode,
      name: '使用者名稱',
      avatarType: Value('male_01'),
      isCurrentUser: Value(true),
    );
    
    await db.insertOrUpdateUser(user);
    debugPrint('創建初始用戶: $userCode');
  }

  /// 創建示例數據（僅限開發模式）
  Future<void> _createSampleData() async {
    final db = database;
    final currentUser = await db.getCurrentUser();
    if (currentUser == null) return;

    try {
      // 創建示例群組
      final groupId = await db.createGroup(GroupsCompanion.insert(
        name: '室友分攤',
        description: Value('與室友一起分攤日常開支'),
        createdBy: currentUser.id,
      ));

      // 將當前用戶添加到群組（作為管理員）
      await db.addGroupMember(groupId, currentUser.id, role: 'admin');

      // 創建其他示例用戶
      final user2Id = await db.insertOrUpdateUser(UsersCompanion.insert(
        userCode: _generateUserCode(),
        name: '室友小王',
        avatarType: Value('female_01'),
      ));

      final user3Id = await db.insertOrUpdateUser(UsersCompanion.insert(
        userCode: _generateUserCode(),
        name: '室友小李',
        avatarType: Value('male_02'),
      ));

      // 將其他用戶添加到群組
      await db.addGroupMember(groupId, user2Id);
      await db.addGroupMember(groupId, user3Id);

      // 創建示例支出
      final expenseId = await db.createExpense(ExpensesCompanion.insert(
        groupId: groupId,
        paidBy: currentUser.id,
        title: '購買日用品',
        description: Value('衛生紙、洗衣精等'),
        amount: 450.0,
        expenseDate: DateTime.now().subtract(const Duration(hours: 2)),
      ));

      // 創建支出分攤
      await db.createExpenseSplits([
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

  /// 生成用戶代碼
  String _generateUserCode() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'GA${random.toString().padLeft(6, '0')}';
  }

  /// 清理資料庫連接
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  /// 獲取資料庫統計信息
  Future<Map<String, int>> getDatabaseStats() async {
    final db = database;
    
    try {
      final userCount = await (db.select(db.users)..limit(1000)).get().then((list) => list.length);
      final groupCount = await (db.select(db.groups)..limit(1000)).get().then((list) => list.length);
      final expenseCount = await (db.select(db.expenses)..limit(1000)).get().then((list) => list.length);
      
      return {
        'users': userCount,
        'groups': groupCount,
        'expenses': expenseCount,
      };
    } catch (e) {
      debugPrint('獲取資料庫統計失敗: $e');
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
