import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 首页统计卡片组件
class HomeStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const HomeStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.group,
                title: l10n?.participatedGroups ?? '參與群組',
                amount: '${stats['groupCount'] ?? 0}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                icon: Icons.account_balance_wallet,
                title: l10n?.totalExpenses ?? '總支出',
                amount: '\$${(stats['totalPaid'] ?? 0.0).toStringAsFixed(2)}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计卡片组件
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
} 
