import 'package:drift/drift.dart';
import '../database.dart';

/// 支出相關查詢類
class ExpenseQueries {
  final AppDatabase _database;
  
  ExpenseQueries(this._database);

  /// 獲取群組支出
  Stream<List<Expense>> watchGroupExpenses(int groupId) {
    return (_database.select(_database.expenses)
          ..where((e) => e.groupId.equals(groupId))
          ..orderBy([(e) => OrderingTerm.desc(e.expenseDate)]))
        .watch();
  }

  /// 創建支出
  Future<int> createExpense(ExpensesCompanion expense) {
    return _database.into(_database.expenses).insert(expense);
  }

  /// 獲取支出分攤詳情
  Future<List<ExpenseSplit>> getExpenseSplits(int expenseId) {
    return (_database.select(_database.expenseSplits)
          ..where((es) => es.expenseId.equals(expenseId)))
        .get();
  }

  /// 創建支出分攤
  Future<void> createExpenseSplits(List<ExpenseSplitsCompanion> splits) {
    return _database.batch((batch) {
      batch.insertAll(_database.expenseSplits, splits);
    });
  }
} 
