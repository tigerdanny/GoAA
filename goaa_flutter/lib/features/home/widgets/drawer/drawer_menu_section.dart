import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 抽屜選單區段組件
/// 包含標題和項目列表
class DrawerMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const DrawerMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context),
        _buildSectionContainer(),
      ],
    );
  }

  /// 建構區段標題
  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 建構區段容器
  Widget _buildSectionContainer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (index > 0) _buildDivider(),
              item,
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 建構分隔線
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border.withValues(alpha: 0.5),
      indent: 16,
      endIndent: 16,
    );
  }
} 
