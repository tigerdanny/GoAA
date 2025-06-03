import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// ================================
// 表格定義
// ================================

/// 用戶表
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userCode => text().withLength(min: 8, max: 12).unique()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatarType => text().withDefault(const Constant('male_01'))();
  TextColumn get avatarSource => text().nullable()(); // 自定義頭像路徑
  BoolColumn get isCurrentUser => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 群組表
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('TWD'))();
  IntColumn get createdBy => integer().references(Users, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 群組成員關聯表
class GroupMembers extends Table {
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().withDefault(const Constant('member'))(); // 'admin', 'member'
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {groupId, userId};
}

/// 支出表
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get paidBy => integer().references(Users, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('TWD'))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  TextColumn get splitType => text().withDefault(const Constant('equal'))(); // 'equal', 'exact', 'percentage'
  TextColumn get receiptPath => text().nullable()(); // 收據圖片路徑
  DateTimeColumn get expenseDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 支出分攤詳情表
class ExpenseSplits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get expenseId => integer().references(Expenses, #id, onDelete: KeyAction.cascade)();
  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()(); // 該用戶應分攤的金額
  RealColumn get percentage => real().nullable()(); // 分攤百分比（如果使用百分比分攤）
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get settledAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 結算記錄表
class Settlements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('fromUserRef')
  IntColumn get fromUser => integer().references(Users, #id)();
  @ReferenceName('toUserRef')
  IntColumn get toUser => integer().references(Users, #id)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('TWD'))();
  TextColumn get method => text().nullable()(); // 付款方式：現金、轉帳、等
  TextColumn get note => text().nullable()();
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get settlementDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 邀請表
class Invitations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get invitedBy => integer().references(Users, #id)();
  TextColumn get inviteeUserCode => text()(); // 被邀請者的用戶代碼
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'accepted', 'declined', 'expired'
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get respondedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ================================
// 資料庫類
// ================================

@DriftDatabase(tables: [
  Users,
  Groups,
  GroupMembers,
  Expenses,
  ExpenseSplits,
  Settlements,
  Invitations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ================================
  // 用戶相關查詢
  // ================================
  
  /// 獲取當前用戶
  Future<User?> getCurrentUser() {
    return (select(users)..where((u) => u.isCurrentUser.equals(true))).getSingleOrNull();
  }

  /// 通過用戶代碼查找用戶
  Future<User?> findUserByCode(String userCode) {
    return (select(users)..where((u) => u.userCode.equals(userCode))).getSingleOrNull();
  }

  /// 創建或更新用戶
  Future<int> insertOrUpdateUser(UsersCompanion user) {
    return into(users).insertOnConflictUpdate(user);
  }

  /// 更新用戶資料
  Future<bool> updateUser(int id, UsersCompanion user) {
    return update(users)
        .replace(user.copyWith(id: Value(id), updatedAt: Value(DateTime.now())));
  }

  // ================================
  // 群組相關查詢
  // ================================

  /// 獲取用戶所有群組
  Future<List<Group>> getUserGroups(int userId) {
    final query = select(groups).join([
      innerJoin(groupMembers, groupMembers.groupId.equalsExp(groups.id)),
    ])..where(groupMembers.userId.equals(userId) & groups.isActive.equals(true));
    
    return query.map((row) => row.readTable(groups)).get();
  }

  /// 獲取群組詳情
  Future<Group?> getGroup(int groupId) {
    return (select(groups)..where((g) => g.id.equals(groupId))).getSingleOrNull();
  }

  /// 創建群組
  Future<int> createGroup(GroupsCompanion group) {
    return into(groups).insert(group);
  }

  /// 獲取群組成員
  Future<List<User>> getGroupMembers(int groupId) {
    final query = select(users).join([
      innerJoin(groupMembers, groupMembers.userId.equalsExp(users.id)),
    ])..where(groupMembers.groupId.equals(groupId));
    
    return query.map((row) => row.readTable(users)).get();
  }

  /// 添加群組成員
  Future<int> addGroupMember(int groupId, int userId, {String role = 'member'}) {
    return into(groupMembers).insert(GroupMembersCompanion(
      groupId: Value(groupId),
      userId: Value(userId),
      role: Value(role),
    ));
  }

  // ================================
  // 支出相關查詢
  // ================================

  /// 獲取群組支出
  Stream<List<Expense>> watchGroupExpenses(int groupId) {
    return (select(expenses)
          ..where((e) => e.groupId.equals(groupId))
          ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)]))
        .watch();
  }

  /// 創建支出
  Future<int> createExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  /// 獲取支出分攤詳情
  Future<List<ExpenseSplit>> getExpenseSplits(int expenseId) {
    return (select(expenseSplits)..where((es) => es.expenseId.equals(expenseId))).get();
  }

  /// 創建支出分攤
  Future<void> createExpenseSplits(List<ExpenseSplitsCompanion> splits) {
    return batch((batch) {
      batch.insertAll(expenseSplits, splits);
    });
  }

  // ================================
  // 結算相關查詢
  // ================================

  /// 獲取群組未結算金額
  Future<Map<int, double>> getGroupBalances(int groupId) async {
    // 這裡需要複雜的查詢來計算每個用戶的淨餘額
    // 暫時返回空的Map，後續實現具體邏輯
    return {};
  }

  /// 創建結算記錄
  Future<int> createSettlement(SettlementsCompanion settlement) {
    return into(settlements).insert(settlement);
  }

  /// 獲取群組結算記錄
  Future<List<Settlement>> getGroupSettlements(int groupId) {
    return (select(settlements)
          ..where((s) => s.groupId.equals(groupId))
          ..orderBy([(s) => OrderingTerm.desc(s.settlementDate)]))
        .get();
  }

  // ================================
  // 邀請相關查詢
  // ================================

  /// 創建邀請
  Future<int> createInvitation(InvitationsCompanion invitation) {
    return into(invitations).insert(invitation);
  }

  /// 獲取待處理邀請
  Future<List<Invitation>> getPendingInvitations(String userCode) {
    return (select(invitations)
          ..where((i) => i.inviteeUserCode.equals(userCode) & 
                        i.status.equals('pending') &
                        i.expiresAt.isBiggerThanValue(DateTime.now())))
        .get();
  }

  /// 回應邀請
  Future<bool> respondToInvitation(int invitationId, String status) {
    return update(invitations)
        .replace(InvitationsCompanion(
          id: Value(invitationId),
          status: Value(status),
          respondedAt: Value(DateTime.now()),
        ));
  }
}

// ================================
// 資料庫連接設置
// ================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'goaa_database.db'));

    // 確保在Android上使用最新的sqlite3
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // 創建原生資料庫連接
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
} 
