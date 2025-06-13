import "package:drift/drift.dart";
import "../database.dart";
import "../database_service.dart";

class ExpenseRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  AppDatabase get _database => _databaseService.database;

  Future<List<Expense>> getUserGroupExpenses(int userId, {int? limit}) async {
    try {
      final userGroups = await (_database.select(_database.groupMembers)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      final groupIds = userGroups.map((gm) => gm.groupId).toList();

      if (groupIds.isEmpty) {
        return [];
      }

      var query = _database.select(_database.expenses)
        ..where((tbl) => tbl.groupId.isIn(groupIds))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

      if (limit != null) {
        query = query..limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get user group expenses: $e');
    }
  }

  Future<Expense?> getExpenseById(int expenseId) async {
    try {
      return await (_database.select(_database.expenses)
            ..where((tbl) => tbl.id.equals(expenseId)))
          .getSingleOrNull();
    } catch (e) {
      throw Exception('Failed to get expense by ID: $e');
    }
  }

  Future<List<ExpenseSplit>> getExpenseSplits(int expenseId) async {
    try {
      return await (_database.select(_database.expenseSplits)
            ..where((tbl) => tbl.expenseId.equals(expenseId)))
          .get();
    } catch (e) {
      throw Exception('Failed to get expense splits: $e');
    }
  }

  Future<double> getUserBalance(int userId) async {
    try {
      final splits = await (_database.select(_database.expenseSplits)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      double balance = 0.0;
      for (final split in splits) {
        balance += split.amount;
      }

      return balance;
    } catch (e) {
      throw Exception('Failed to get user balance: $e');
    }
  }

  Future<Map<String, double>> getGroupExpenseStats(int groupId) async {
    try {
      final expenses = await (_database.select(_database.expenses)
            ..where((tbl) => tbl.groupId.equals(groupId)))
          .get();

      double totalAmount = 0.0;
      int totalCount = expenses.length;

      for (final expense in expenses) {
        totalAmount += expense.amount;
      }

      return {
        'totalAmount': totalAmount,
        'totalCount': totalCount.toDouble(),
        'averageAmount': totalCount > 0 ? totalAmount / totalCount : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get group expense stats: $e');
    }
  }
} 
