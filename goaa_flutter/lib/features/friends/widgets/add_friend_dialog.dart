import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 添加好友对话框组件
class AddFriendDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const AddFriendDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final userCodeController = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '添加好友',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: userCodeController,
            decoration: InputDecoration(
              labelText: '用戶代碼',
              hintText: '請輸入好友的用戶代碼',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.tag, color: AppColors.primary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('添加', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /// 显示添加好友对话框
  static void show(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AddFriendDialog(onConfirm: onConfirm),
    );
  }
} 
