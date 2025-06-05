import 'package:drift/drift.dart';
import '../database.dart';

/// 群組相關查詢類
class GroupQueries {
  final AppDatabase _database;
  
  GroupQueries(this._database);

  /// 獲取用戶所有群組
  Future<List<Group>> getUserGroups(int userId) {
    final query = _database.select(_database.groups).join([
      innerJoin(_database.groupMembers, 
          _database.groupMembers.groupId.equalsExp(_database.groups.id)),
    ])..where(_database.groupMembers.userId.equals(userId) & 
              _database.groups.isActive.equals(true));
    
    return query.map((row) => row.readTable(_database.groups)).get();
  }

  /// 獲取群組詳情
  Future<Group?> getGroup(int groupId) {
    return (_database.select(_database.groups)
          ..where((g) => g.id.equals(groupId)))
        .getSingleOrNull();
  }

  /// 創建群組
  Future<int> createGroup(GroupsCompanion group) {
    return _database.into(_database.groups).insert(group);
  }

  /// 獲取群組成員
  Future<List<User>> getGroupMembers(int groupId) {
    final query = _database.select(_database.users).join([
      innerJoin(_database.groupMembers, 
          _database.groupMembers.userId.equalsExp(_database.users.id)),
    ])..where(_database.groupMembers.groupId.equals(groupId));
    
    return query.map((row) => row.readTable(_database.users)).get();
  }

  /// 添加群組成員
  Future<int> addGroupMember(int groupId, int userId, {String role = 'member'}) {
    return _database.into(_database.groupMembers).insert(GroupMembersCompanion(
      groupId: Value(groupId),
      userId: Value(userId),
      role: Value(role),
    ));
  }
} 
