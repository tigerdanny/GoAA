import 'package:drift/drift.dart';
import '../database.dart';

/// 結算相關查詢類
class SettlementQueries {
  final AppDatabase _database;
  
  SettlementQueries(this._database);

  /// 獲取群組未結算金額
  Future<Map<int, double>> getGroupBalances(int groupId) async {
    // 這裡需要複雜的查詢來計算每個用戶的淨餘額
    // 暫時返回空的Map，後續實現具體邏輯
    return {};
  }

  /// 創建結算記錄
  Future<int> createSettlement(SettlementsCompanion settlement) {
    return _database.into(_database.settlements).insert(settlement);
  }

  /// 獲取群組結算記錄
  Future<List<Settlement>> getGroupSettlements(int groupId) {
    return (_database.select(_database.settlements)
          ..where((s) => s.groupId.equals(groupId))
          ..orderBy([(s) => OrderingTerm.desc(s.settlementDate)]))
        .get();
  }
} 
