import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';

/// 首页帐务列表组件
class HomeExpenses extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onExpenseTap;

  const HomeExpenses({
    super.key,
    required this.expenses,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '還沒有任何帳務記錄',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final expense = expenses[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Card(
              elevation: 0,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 20,
                  ),
                ),
                title: Text(
                  expense.description ?? '無描述',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _formatDate(expense.expenseDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      expense.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                onTap: () => onExpenseTap(expense),
              ),
            ),
          );
        },
        childCount: expenses.length,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case '餐飲':
        return AppColors.warning;
      case 'transport':
      case '交通':
        return AppColors.info;
      case 'entertainment':
      case '娛樂':
        return AppColors.secondary;
      case 'shopping':
      case '購物':
        return AppColors.accent;
      case 'utilities':
      case '水電':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case '餐飲':
        return Icons.restaurant;
      case 'transport':
      case '交通':
        return Icons.directions_car;
      case 'entertainment':
      case '娛樂':
        return Icons.movie;
      case 'shopping':
      case '購物':
        return Icons.shopping_bag;
      case 'utilities':
      case '水電':
        return Icons.home;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
} 
