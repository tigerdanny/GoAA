import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 删除好友确认对话框组件
class DeleteConfirmDialog extends StatelessWidget {
  final Map<String, String> friend;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.friend,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: const Text('確認刪除'),
      content: Text('確定要刪除好友「${friend['name']}」嗎？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          child: const Text('刪除', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /// 显示删除确认对话框
  static void show(
    BuildContext context,
    Map<String, String> friend,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        friend: friend,
        onConfirm: onConfirm,
      ),
    );
  }
} 
