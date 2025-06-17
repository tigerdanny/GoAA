import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../database/database_service.dart';

/// 資料庫清理服務
class DatabaseCleanupService {
  static final DatabaseCleanupService _instance = DatabaseCleanupService._internal();
  factory DatabaseCleanupService() => _instance;
  
  final DatabaseService _dbService;
  
  DatabaseCleanupService._internal() : _dbService = DatabaseService.instance;

  /// 清除除了金句以外的所有資料，保留資料庫格式
  Future<void> clearAllDataExceptQuotes() async {
    try {
      final db = _dbService.database;
      
      debugPrint('🗑️ 開始清除所有資料（保留金句）...');
      
      // 按順序清除資料（考慮外鍵約束）
      await db.delete(db.expenseSplits).go();
      debugPrint('✅ 已清除費用分攤資料');
      
      await db.delete(db.expenses).go();
      debugPrint('✅ 已清除費用資料');
      
      await db.delete(db.settlements).go();
      debugPrint('✅ 已清除結算資料');
      
      await db.delete(db.invitations).go();
      debugPrint('✅ 已清除邀請資料');
      
      await db.delete(db.groupMembers).go();
      debugPrint('✅ 已清除群組成員資料');
      
      await db.delete(db.groups).go();
      debugPrint('✅ 已清除群組資料');
      
      await db.delete(db.users).go();
      debugPrint('✅ 已清除用戶資料');
      
      // 保留 daily_quotes 表格，不清除
      debugPrint('✅ 保留金句資料');
      
      debugPrint('🎉 資料清除完成，已保留金句資料');
    } catch (e) {
      debugPrint('❌ 資料清除失敗: $e');
      rethrow;
    }
  }

  /// 清理舊金句（保留最新100條）
  Future<void> cleanupOldQuotes() async {
    try {
      final db = _dbService.database;
      final quotes = await (db.select(db.dailyQuotes)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
      
      if (quotes.length > 100) {
        final idsToDelete = quotes.skip(100).map((q) => q.id).toList();
        if (idsToDelete.isNotEmpty) {
          await (db.delete(db.dailyQuotes)
            ..where((tbl) => tbl.id.isIn(idsToDelete)))
            .go();
          debugPrint('已清理 ${idsToDelete.length} 條舊金句');
        }
      }
    } catch (e) {
      debugPrint('資料庫清理失敗: $e');
    }
  }

  /// 清理資料庫
  Future<void> cleanup() async {
    try {
      final db = _dbService.database;
      
      // 清理過期資料
      await _cleanupExpiredData(db);
      
      // 清理重複資料
      await _cleanupDuplicateData(db);
      
      // 清理無效資料
      await _cleanupInvalidData(db);
      
      debugPrint('✅ 資料庫清理完成');
    } catch (e) {
      debugPrint('❌ 資料庫清理失敗: $e');
      rethrow;
    }
  }

  /// 清理過期資料
  Future<void> _cleanupExpiredData(AppDatabase db) async {
    // 清理過期金句（30天前）
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await (db.delete(db.dailyQuotes)
      ..where((tbl) => tbl.createdAt.isSmallerOrEqualValue(thirtyDaysAgo)))
      .go();
  }

  /// 清理重複資料
  Future<void> _cleanupDuplicateData(AppDatabase db) async {
    // 清理重複用戶
    final users = await db.select(db.users).get();
    final uniqueUserCodes = <String>{};
    final duplicateUsers = <int>[];
    
    for (final user in users) {
      if (!uniqueUserCodes.add(user.userCode)) {
        duplicateUsers.add(user.id);
      }
    }
    
    if (duplicateUsers.isNotEmpty) {
      await (db.delete(db.users)
        ..where((tbl) => tbl.id.isIn(duplicateUsers)))
        .go();
    }
  }

  /// 清理無效資料
  Future<void> _cleanupInvalidData(AppDatabase db) async {
    // 清理無效群組（沒有成員的群組）
    final groups = await db.select(db.groups).get();
    final invalidGroups = <int>[];
    
    for (final group in groups) {
      final members = await (db.select(db.groupMembers)
        ..where((tbl) => tbl.groupId.equals(group.id)))
        .get();
      
      if (members.isEmpty) {
        invalidGroups.add(group.id);
      }
    }
    
    if (invalidGroups.isNotEmpty) {
      await (db.delete(db.groups)
        ..where((tbl) => tbl.id.isIn(invalidGroups)))
        .go();
    }
  }
} 
