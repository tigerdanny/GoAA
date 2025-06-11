import 'package:drift/drift.dart';
import '../database.dart';
import '../database_service.dart';
import 'package:flutter/foundation.dart';

/// 用戶資料存取層
class UserRepository {
  final AppDatabase _db = DatabaseService.instance.database;

  /// 獲取當前用戶
  Future<User?> getCurrentUser() {
    return _db.userQueries.getCurrentUser();
  }

  /// 通過用戶代碼查找用戶
  Future<User?> findUserByCode(String userCode) {
    return _db.userQueries.findUserByCode(userCode);
  }

  /// 更新用戶資料
  Future<bool> updateUser(int id, {
    String? name,
    String? email,
    String? phone,
    String? avatarType,
    String? avatarSource,
  }) {
    final companion = UsersCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      avatarType: avatarType != null ? Value(avatarType) : const Value.absent(),
      avatarSource: avatarSource != null ? Value(avatarSource) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return _db.userQueries.updateUser(id, companion);
  }

  /// 創建新用戶
  Future<int> createUser({
    required String userCode,
    required String name,
    String? email,
    String? phone,
    String avatarType = 'male_01',
    String? avatarSource,
    bool isCurrentUser = false,
  }) {
    final companion = UsersCompanion.insert(
      userCode: userCode,
      name: name,
      email: Value(email),
      phone: Value(phone),
      avatarType: Value(avatarType),
      avatarSource: Value(avatarSource),
      isCurrentUser: Value(isCurrentUser),
    );

    return _db.userQueries.insertOrUpdateUser(companion);
  }

  /// 🚀 設置當前用戶（重新設計使用 async/await）
  Future<void> setCurrentUser(int userId) async {
    // 先將所有用戶設為非當前用戶，然後設置指定用戶為當前用戶
    await _db.userQueries.clearAllCurrentUserStatus();
    await _db.userQueries.updateUser(userId, const UsersCompanion(isCurrentUser: Value(true)));
  }

  /// 搜索用戶（通過名稱或用戶代碼）
  Future<List<User>> searchUsers(String query) {
    return (_db.select(_db.users)
      ..where((u) => 
        u.name.contains(query) | 
        u.userCode.contains(query) |
        u.email.contains(query))
      ..limit(20))
      .get();
  }

  /// 獲取所有用戶
  Future<List<User>> getAllUsers() {
    return _db.select(_db.users).get();
  }

  /// 刪除用戶
  Future<int> deleteUser(int userId) {
    return (_db.delete(_db.users)..where((u) => u.id.equals(userId))).go();
  }

  /// 🚀 檢查用戶代碼是否已存在（重新設計使用 async/await）
  Future<bool> isUserCodeExists(String userCode) async {
    final user = await findUserByCode(userCode);
    return user != null;
  }

  /// 生成唯一用戶代碼（簡化版）
  Future<String> generateUniqueUserCode() {
    return _generateCodeAttempt(0);
  }

  Future<String> _generateCodeAttempt(int attempts) async {
    const maxAttempts = 100;
    
    if (attempts >= maxAttempts) {
      throw Exception('無法生成唯一用戶代碼');
    }
    
    // 生成用戶代碼
    final now = DateTime.now();
    final timeComponent = now.microsecondsSinceEpoch.toString();
    final timeDigits = timeComponent.substring(timeComponent.length - 8);
    final randomComponent = (now.millisecond * 1000 + attempts * 7 + now.second * 13) % 999999;
    final combinedNumber = (int.parse(timeDigits.substring(2, 6)) + randomComponent) % 999999;
    final codeNumber = combinedNumber.toString().padLeft(6, '0');
    final userCode = 'GA$codeNumber';
    
    final exists = await isUserCodeExists(userCode);
    if (exists) {
      return await _generateCodeAttempt(attempts + 1);
    } else {
      return userCode;
    }
  }

  /// 🚀 獲取用戶統計信息（重新設計使用 async/await）
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      // 🚀 並行獲取數據
      final results = await Future.wait([
        // 獲取用戶參與的群組數量
        (_db.select(_db.groupMembers)
          ..where((gm) => gm.userId.equals(userId)))
          .get(),
        // 獲取用戶的支出數據
        (_db.select(_db.expenses)
          ..where((e) => e.paidBy.equals(userId)))
          .get(),
      ]);

      final groupMembers = results[0] as List<GroupMember>;
      final expenses = results[1] as List<Expense>;

      final groupCount = groupMembers.length;
      final expenseCount = expenses.length;
      final totalPaid = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

      return {
        'groupCount': groupCount,
        'expenseCount': expenseCount,
        'totalPaid': totalPaid,
      };
    } catch (e) {
      debugPrint('❌ 獲取用戶統計失敗: $e');
      return {
        'groupCount': 0,
        'expenseCount': 0,
        'totalPaid': 0.0,
      };
    }
  }
} 
 