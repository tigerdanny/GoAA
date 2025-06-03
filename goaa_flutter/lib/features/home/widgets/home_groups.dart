import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';

/// 首页群组列表组件
class HomeGroups extends StatelessWidget {
  final List<Group> groups;
  final Function(Group) onGroupTap;

  const HomeGroups({
    super.key,
    required this.groups,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '還沒有加入任何群組',
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
          final group = groups[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.group, color: Colors.white),
                ),
                title: Text(group.name),
                subtitle: Text(group.description ?? ''),
                trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () => onGroupTap(group),
              ),
            ),
          );
        },
        childCount: groups.length,
      ),
    );
  }
}

/// 区段标题组件
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
} 
