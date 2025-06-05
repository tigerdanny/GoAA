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

  /// 更新用戶資料
  Future<bool> updateUser(int id, UsersCompanion user) {
    return _database.update(_database.users).replace(
        user.copyWith(id: Value(id), updatedAt: Value(DateTime.now())));
  }

  /// 清除所有用戶的當前用戶狀態
  Future<int> clearAllCurrentUserStatus() {
    return (_database.update(_database.users)
      ..where((u) => u.isCurrentUser.equals(true)))
      .write(const UsersCompanion(isCurrentUser: Value(false)));
  }
} 
