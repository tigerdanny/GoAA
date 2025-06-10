import 'package:drift/drift.dart';
import '../database.dart';
import '../database_service.dart';

/// 群組資料存取層
class GroupRepository {
  final AppDatabase _db = DatabaseService.instance.database;

  /// 獲取用戶所有群組
  Future<List<Group>> getUserGroups(int userId) {
    return _db.groupQueries.getUserGroups(userId);
  }

  /// 獲取群組詳情
  Future<Group?> getGroup(int groupId) {
    return _db.groupQueries.getGroup(groupId);
  }

  /// 創建群組（簡化版）
  Future<int> createGroup({
    required String name,
    String? description,
    required int createdBy,
    String currency = 'TWD',
  }) {
    final companion = GroupsCompanion.insert(
      name: name,
      description: Value(description),
      createdBy: createdBy,
      currency: Value(currency),
    );

    return _db.groupQueries.createGroup(companion).then((groupId) {
      // 將創建者添加為群組管理員
      return addGroupMember(groupId, createdBy, role: 'admin').then((_) => groupId);
    });
  }

  /// 更新群組資料（簡化版）
  Future<bool> updateGroup(int groupId, {
    String? name,
    String? description,
    String? currency,
    bool? isActive,
  }) {
    final companion = GroupsCompanion(
      id: Value(groupId),
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      currency: currency != null ? Value(currency) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return (_db.update(_db.groups)
      ..where((g) => g.id.equals(groupId)))
      .write(companion)
      .then((count) => count > 0);
  }

  /// 獲取群組成員
  Future<List<User>> getGroupMembers(int groupId) {
    return _db.groupQueries.getGroupMembers(groupId);
  }

  /// 添加群組成員
  Future<int> addGroupMember(int groupId, int userId, {String role = 'member'}) {
    return _db.groupQueries.addGroupMember(groupId, userId, role: role);
  }

  /// 移除群組成員
  Future<int> removeGroupMember(int groupId, int userId) {
    return (_db.delete(_db.groupMembers)
      ..where((gm) => gm.groupId.equals(groupId) & gm.userId.equals(userId)))
      .go();
  }

  /// 更新成員角色
  Future<bool> updateMemberRole(int groupId, int userId, String role) async {
    return await (_db.update(_db.groupMembers)
      ..where((gm) => gm.groupId.equals(groupId) & gm.userId.equals(userId)))
      .write(GroupMembersCompanion(role: Value(role))) > 0;
  }

  /// 檢查用戶是否為群組成員
  Future<bool> isGroupMember(int groupId, int userId) async {
    final member = await (_db.select(_db.groupMembers)
      ..where((gm) => gm.groupId.equals(groupId) & gm.userId.equals(userId)))
      .getSingleOrNull();
    return member != null;
  }

  /// 檢查用戶是否為群組管理員
  Future<bool> isGroupAdmin(int groupId, int userId) async {
    final member = await (_db.select(_db.groupMembers)
      ..where((gm) => gm.groupId.equals(groupId) & 
                      gm.userId.equals(userId) & 
                      gm.role.equals('admin')))
      .getSingleOrNull();
    return member != null;
  }

  /// 獲取群組統計信息
  Future<Map<String, dynamic>> getGroupStats(int groupId) async {
    // 獲取成員數量
    final memberCount = await (_db.select(_db.groupMembers)
      ..where((gm) => gm.groupId.equals(groupId)))
      .get()
      .then((list) => list.length);

    // 獲取支出數量
    final expenseCount = await (_db.select(_db.expenses)
      ..where((e) => e.groupId.equals(groupId)))
      .get()
      .then((list) => list.length);

    // 獲取總支出金額
    final expenses = await (_db.select(_db.expenses)
      ..where((e) => e.groupId.equals(groupId)))
      .get();
    
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    // 獲取最近活動時間
    final latestExpense = await (_db.select(_db.expenses)
      ..where((e) => e.groupId.equals(groupId))
      ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)])
      ..limit(1))
      .getSingleOrNull();

    return {
      'memberCount': memberCount,
      'expenseCount': expenseCount,
      'totalAmount': totalAmount,
      'lastActivity': latestExpense?.expenseDate,
    };
  }

  /// 軟刪除群組
  Future<bool> deactivateGroup(int groupId) {
    return updateGroup(groupId, isActive: false);
  }

  /// 永久刪除群組
  Future<int> deleteGroup(int groupId) async {
    // 由於設置了cascade delete，刪除群組會自動刪除相關的成員、支出等
    return (_db.delete(_db.groups)..where((g) => g.id.equals(groupId))).go();
  }

  /// 搜索群組
  Future<List<Group>> searchGroups(String query, int userId) async {
    final userGroups = await getUserGroups(userId);
    return userGroups.where((group) => 
      group.name.toLowerCase().contains(query.toLowerCase()) ||
      (group.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  /// 獲取群組的邀請記錄
  Future<List<Invitation>> getGroupInvitations(int groupId) {
    return (_db.select(_db.invitations)
      ..where((i) => i.groupId.equals(groupId))
      ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
      .get();
  }
} 
