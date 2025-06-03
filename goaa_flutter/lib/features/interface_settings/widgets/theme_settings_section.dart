import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'interface_setting_items.dart';

/// 主题设置区段组件
class ThemeSettingsSection extends StatelessWidget {
  final bool useSystemTheme;
  final bool darkMode;
  final String colorTheme;
  final ValueChanged<bool> onUseSystemThemeChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<String?> onColorThemeChanged;

  const ThemeSettingsSection({
    super.key,
    required this.useSystemTheme,
    required this.darkMode,
    required this.colorTheme,
    required this.onUseSystemThemeChanged,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '主題設定'),
        const SizedBox(height: 16),
        
        SettingCard(
          title: '跟隨系統主題',
          subtitle: '自動切換深色/淺色模式',
          child: Switch(
            value: useSystemTheme,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onUseSystemThemeChanged(value);
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        if (!useSystemTheme) ...[
          SettingCard(
            title: '深色模式',
            subtitle: '使用深色主題',
            child: Switch(
              value: darkMode,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                onDarkModeChanged(value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        DropdownCard(
          title: '主題顏色',
          subtitle: '選擇應用的主色調',
          value: colorTheme,
          items: const [
            DropdownMenuItem(value: 'default', child: Text('預設藍色')),
            DropdownMenuItem(value: 'green', child: Text('清新綠色')),
            DropdownMenuItem(value: 'purple', child: Text('優雅紫色')),
            DropdownMenuItem(value: 'orange', child: Text('活力橙色')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              onColorThemeChanged(value);
            }
          },
        ),
      ],
    );
  }
} 
