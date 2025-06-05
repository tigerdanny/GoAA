import 'package:drift/drift.dart';

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

/// 每日金句表
class DailyQuotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentZh => text()(); // 中文內容
  TextColumn get contentEn => text()(); // 英文內容
  TextColumn get author => text().nullable()(); // 作者
  TextColumn get category => text().withDefault(const Constant('inspirational'))(); // 分類
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
} 
