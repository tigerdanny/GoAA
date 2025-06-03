import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'interface_setting_items.dart';
import 'reset_confirm_dialog.dart';

/// 重置设置区段组件
class ResetSettingsSection extends StatelessWidget {
  final VoidCallback onReset;

  const ResetSettingsSection({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '重置設定'),
        const SizedBox(height: 16),
        
        ActionCard(
          icon: Icons.refresh,
          title: '重置介面設定',
          subtitle: '恢復所有介面設定為預設值',
          onTap: () => _showResetDialog(context),
          color: AppColors.warning,
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    ResetConfirmDialog.show(context, onReset);
  }
} 
