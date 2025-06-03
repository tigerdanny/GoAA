import 'package:drift/drift.dart';
import '../database.dart';
import '../database_service.dart';

/// 用戶資料存取層
class UserRepository {
  final AppDatabase _db = DatabaseService.instance.database;

  /// 獲取當前用戶
  Future<User?> getCurrentUser() {
    return _db.getCurrentUser();
  }

  /// 通過用戶代碼查找用戶
  Future<User?> findUserByCode(String userCode) {
    return _db.findUserByCode(userCode);
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

    return _db.updateUser(id, companion);
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

    return _db.insertOrUpdateUser(companion);
  }

  /// 設置當前用戶
  Future<void> setCurrentUser(int userId) async {
    // 先將所有用戶設為非當前用戶
    await (_db.update(_db.users)
      ..where((u) => u.isCurrentUser.equals(true)))
      .write(const UsersCompanion(isCurrentUser: Value(false)));

    // 設置指定用戶為當前用戶
    await _db.updateUser(userId, const UsersCompanion(isCurrentUser: Value(true)));
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

  /// 檢查用戶代碼是否已存在
  Future<bool> isUserCodeExists(String userCode) async {
    final user = await findUserByCode(userCode);
    return user != null;
  }

  /// 生成唯一用戶代碼
  Future<String> generateUniqueUserCode() async {
    String userCode;
    bool exists;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      if (attempts >= maxAttempts) {
        throw Exception('無法生成唯一用戶代碼');
      }
      
      // 使用多种元素生成更唯一的用户代码
      final now = DateTime.now();
      
      // 获取微秒级时间戳的后8位
      final timeComponent = now.microsecondsSinceEpoch.toString();
      final timeDigits = timeComponent.substring(timeComponent.length - 8);
      
      // 增加额外的随机性
      final randomComponent = (now.millisecond * 1000 + attempts * 7 + now.second * 13) % 999999;
      
      // 组合时间和随机数生成6位数字
      final combinedNumber = (int.parse(timeDigits.substring(2, 6)) + randomComponent) % 999999;
      final codeNumber = combinedNumber.toString().padLeft(6, '0');
      
      userCode = 'GA$codeNumber';
      
      exists = await isUserCodeExists(userCode);
      attempts++;
      
      // 如果仍然重复，使用纯随机策略
      if (exists && attempts > 50) {
        final pureRandom = DateTime.now().microsecondsSinceEpoch % 999999;
        userCode = 'GA${pureRandom.toString().padLeft(6, '0')}';
        exists = await isUserCodeExists(userCode);
      }
      
    } while (exists);

    return userCode;
  }

  /// 獲取用戶統計信息
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    // 獲取用戶參與的群組數量
    final groupCount = await (_db.select(_db.groupMembers)
      ..where((gm) => gm.userId.equals(userId)))
      .get()
      .then((list) => list.length);

    // 獲取用戶的支出數量
    final expenseCount = await (_db.select(_db.expenses)
      ..where((e) => e.paidBy.equals(userId)))
      .get()
      .then((list) => list.length);

    // 獲取用戶的總支出金額
    final expenses = await (_db.select(_db.expenses)
      ..where((e) => e.paidBy.equals(userId)))
      .get();
    
    final totalPaid = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    return {
      'groupCount': groupCount,
      'expenseCount': expenseCount,
      'totalPaid': totalPaid,
    };
  }
} 
 