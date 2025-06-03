import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// 重置确认对话框组件
class ResetConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ResetConfirmDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('重置介面設定', style: TextStyle(color: AppColors.warning)),
      content: const Text('此操作將恢復所有介面設定為預設值。確定要繼續嗎？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.heavyImpact();
            onConfirm();
          },
          child: Text('重置', style: TextStyle(color: AppColors.warning)),
        ),
      ],
    );
  }

  /// 显示重置确认对话框
  static void show(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => ResetConfirmDialog(onConfirm: onConfirm),
    );
  }
} 
