import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'interface_setting_items.dart';

/// 交互设置区段组件
class InteractionSettingsSection extends StatelessWidget {
  final bool hapticFeedback;
  final bool animations;
  final ValueChanged<bool> onHapticFeedbackChanged;
  final ValueChanged<bool> onAnimationsChanged;

  const InteractionSettingsSection({
    super.key,
    required this.hapticFeedback,
    required this.animations,
    required this.onHapticFeedbackChanged,
    required this.onAnimationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '交互設定'),
        const SizedBox(height: 16),
        
        SettingCard(
          title: '觸覺回饋',
          subtitle: '按鈕點擊時的震動反饋',
          child: Switch(
            value: hapticFeedback,
            onChanged: (value) {
              onHapticFeedbackChanged(value);
              if (value) HapticFeedback.lightImpact();
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        SettingCard(
          title: '動畫效果',
          subtitle: '介面切換和元素動畫',
          child: Switch(
            value: animations,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onAnimationsChanged(value);
            },
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
} 
