import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';

/// 設置菜單項目
class SettingsMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });
}

/// 設置菜單區塊
class SettingsMenuSection extends StatelessWidget {
  final String title;
  final List<SettingsMenuItem> items;

  const SettingsMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 區塊標題
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // 菜單項目
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    item.icon,
                    color: item.iconColor ?? AppColors.textSecondary,
                  ),
                  title: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: item.subtitle != null
                      ? Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: item.trailing ?? const Icon(Icons.chevron_right),
                  onTap: item.onTap,
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.divider,
                  ),
              ],
            );
          }),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
} 
