import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'interface_setting_items.dart';

/// 显示设置区段组件
class DisplaySettingsSection extends StatelessWidget {
  final bool showBalance;
  final String dateFormat;
  final ValueChanged<bool> onShowBalanceChanged;
  final ValueChanged<String?> onDateFormatChanged;

  const DisplaySettingsSection({
    super.key,
    required this.showBalance,
    required this.dateFormat,
    required this.onShowBalanceChanged,
    required this.onDateFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '顯示設定'),
        const SizedBox(height: 16),
        
        SettingCard(
          title: '顯示餘額',
          subtitle: '在首頁顯示帳戶餘額',
          child: Switch(
            value: showBalance,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onShowBalanceChanged(value);
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        DropdownCard(
          title: '日期格式',
          subtitle: '選擇日期顯示格式',
          value: dateFormat,
          items: const [
            DropdownMenuItem(value: 'yyyy/MM/dd', child: Text('2024/12/31')),
            DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('31/12/2024')),
            DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('12/31/2024')),
            DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('2024-12-31')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              onDateFormatChanged(value);
            }
          },
        ),
      ],
    );
  }
} 
