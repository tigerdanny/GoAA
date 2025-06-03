import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';

/// QR码对话框组件
class QRCodeDialog extends StatelessWidget {
  final User user;

  const QRCodeDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('我的二維碼'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                user.userCode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '分享這個代碼給朋友，邀請他們加入群組',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('關閉'),
        ),
      ],
    );
  }

  /// 显示QR码对话框
  static void show(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(user: user),
    );
  }
}

/// QR码扫描功能
class QRCodeScanner {
  /// 显示扫描功能（暂时用SnackBar代替）
  static void scan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('二維碼掃描功能開發中...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
} 
