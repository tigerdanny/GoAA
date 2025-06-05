import 'package:drift/drift.dart';
import '../database.dart';

/// 邀請相關查詢類
class InvitationQueries {
  final AppDatabase _database;
  
  InvitationQueries(this._database);

  /// 創建邀請
  Future<int> createInvitation(InvitationsCompanion invitation) {
    return _database.into(_database.invitations).insert(invitation);
  }

  /// 獲取待處理邀請
  Future<List<Invitation>> getPendingInvitations(String userCode) {
    return (_database.select(_database.invitations)
          ..where((i) => i.inviteeUserCode.equals(userCode) & 
                        i.status.equals('pending') &
                        i.expiresAt.isBiggerThanValue(DateTime.now())))
        .get();
  }

  /// 回應邀請
  Future<bool> respondToInvitation(int invitationId, String status) {
    return _database.update(_database.invitations).replace(
        InvitationsCompanion(
          id: Value(invitationId),
          status: Value(status),
          respondedAt: Value(DateTime.now()),
        ));
  }
} 
