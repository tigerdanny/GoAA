import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database.dart';

/// 好友數據庫操作類
class FriendRepository {
  final AppDatabase _database = AppDatabase();

  /// 保存好友信息到數據庫
  Future<bool> saveFriend({
    required int currentUserId,
    required String friendUserId,
    required String friendUserCode,
    required String friendName,
    String? friendEmail,
    String? friendPhone,
    String? friendAvatar,
    String? friendAvatarSource,
  }) async {
    try {
      await _database.into(_database.friends).insertOnConflictUpdate(
        FriendsCompanion(
          userId: Value(currentUserId),
          friendUserId: Value(friendUserId),
          friendUserCode: Value(friendUserCode),
          friendName: Value(friendName),
          friendEmail: Value(friendEmail),
          friendPhone: Value(friendPhone),
          friendAvatar: Value(friendAvatar),
          friendAvatarSource: Value(friendAvatarSource),
          status: const Value('active'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('保存好友信息失敗: $e');
      return false;
    }
  }

  /// 獲取當前用戶的所有好友
  Future<List<Friend>> getFriends(int currentUserId) async {
    return await (_database.select(_database.friends)
          ..where((tbl) => tbl.userId.equals(currentUserId))
          ..where((tbl) => tbl.status.equals('active')))
        .get();
  }

  /// 根據好友用戶代碼獲取好友信息
  Future<Friend?> getFriendByUserCode(int currentUserId, String friendUserCode) async {
    final query = _database.select(_database.friends)
      ..where((tbl) => tbl.userId.equals(currentUserId))
      ..where((tbl) => tbl.friendUserCode.equals(friendUserCode))
      ..where((tbl) => tbl.status.equals('active'));
    
    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }

  /// 檢查是否已經是好友
  Future<bool> isFriend(int currentUserId, String friendUserCode) async {
    final friend = await getFriendByUserCode(currentUserId, friendUserCode);
    return friend != null;
  }

  /// 刪除好友（軟刪除）
  Future<bool> deleteFriend(int currentUserId, String friendUserCode) async {
    try {
      final updatedRows = await (_database.update(_database.friends)
            ..where((tbl) => tbl.userId.equals(currentUserId))
            ..where((tbl) => tbl.friendUserCode.equals(friendUserCode)))
          .write(const FriendsCompanion(
            status: Value('deleted'),
            updatedAt: Value.absent(),
          ));
      return updatedRows > 0;
    } catch (e) {
      debugPrint('刪除好友失敗: $e');
      return false;
    }
  }

  /// 封鎖好友
  Future<bool> blockFriend(int currentUserId, String friendUserCode) async {
    try {
      final updatedRows = await (_database.update(_database.friends)
            ..where((tbl) => tbl.userId.equals(currentUserId))
            ..where((tbl) => tbl.friendUserCode.equals(friendUserCode)))
          .write(const FriendsCompanion(
            status: Value('blocked'),
            updatedAt: Value.absent(),
          ));
      return updatedRows > 0;
    } catch (e) {
      debugPrint('封鎖好友失敗: $e');
      return false;
    }
  }

  /// 解除封鎖好友
  Future<bool> unblockFriend(int currentUserId, String friendUserCode) async {
    try {
      final updatedRows = await (_database.update(_database.friends)
            ..where((tbl) => tbl.userId.equals(currentUserId))
            ..where((tbl) => tbl.friendUserCode.equals(friendUserCode)))
          .write(const FriendsCompanion(
            status: Value('active'),
            updatedAt: Value.absent(),
          ));
      return updatedRows > 0;
    } catch (e) {
      debugPrint('解除封鎖好友失敗: $e');
      return false;
    }
  }

  /// 更新好友信息
  Future<bool> updateFriend({
    required int currentUserId,
    required String friendUserCode,
    String? friendName,
    String? friendEmail,
    String? friendPhone,
    String? friendAvatar,
    String? friendAvatarSource,
  }) async {
    try {
      final updatedRows = await (_database.update(_database.friends)
            ..where((tbl) => tbl.userId.equals(currentUserId))
            ..where((tbl) => tbl.friendUserCode.equals(friendUserCode)))
          .write(FriendsCompanion(
            friendName: friendName != null ? Value(friendName) : const Value.absent(),
            friendEmail: friendEmail != null ? Value(friendEmail) : const Value.absent(),
            friendPhone: friendPhone != null ? Value(friendPhone) : const Value.absent(),
            friendAvatar: friendAvatar != null ? Value(friendAvatar) : const Value.absent(),
            friendAvatarSource: friendAvatarSource != null ? Value(friendAvatarSource) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ));
      return updatedRows > 0;
    } catch (e) {
      debugPrint('更新好友信息失敗: $e');
      return false;
    }
  }

  /// 清理資源
  void dispose() {
    _database.close();
  }
} 
