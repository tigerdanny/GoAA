import 'package:drift/drift.dart';
import '../database.dart';

/// 用戶相關查詢類
class UserQueries {
  final AppDatabase _database;
  
  UserQueries(this._database);

  /// 獲取當前用戶
  Future<User?> getCurrentUser() {
    return (_database.select(_database.users)
          ..where((u) => u.isCurrentUser.equals(true)))
        .getSingleOrNull();
  }

  /// 通過用戶代碼查找用戶
  Future<User?> findUserByCode(String userCode) {
    return (_database.select(_database.users)
          ..where((u) => u.userCode.equals(userCode)))
        .getSingleOrNull();
  }

  /// 創建或更新用戶
  Future<int> insertOrUpdateUser(UsersCompanion user) {
    return _database.into(_database.users).insertOnConflictUpdate(user);
  }

  /// 安全創建用戶（如果代碼衝突則拋出異常）
  Future<int> insertUser(UsersCompanion user) {
    return _database.into(_database.users).insert(user);
  }

  /// 更新用戶資料
  Future<bool> updateUser(int id, UsersCompanion user) async {
    final result = await (_database.update(_database.users)
          ..where((u) => u.id.equals(id)))
        .write(user.copyWith(updatedAt: Value(DateTime.now())));
    return result > 0;
  }

  /// 清除所有用戶的當前用戶狀態
  Future<int> clearAllCurrentUserStatus() {
    return (_database.update(_database.users)
      ..where((u) => u.isCurrentUser.equals(true)))
      .write(const UsersCompanion(isCurrentUser: Value(false)));
  }
} 
