import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 应用信息对话框
class AppInfoDialog extends StatelessWidget {
  final VoidCallback onContactDeveloper;

  const AppInfoDialog({
    super.key,
    required this.onContactDeveloper,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/goaa_logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n?.appInfo ?? '關於應用',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: l10n?.appName ?? 'GOAA Bill Splitter',
            value: 'GOAA Bill Splitter',
            icon: Icons.apps,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n?.version ?? '版本',
            value: 'v1.0.0 (Build 1)',
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n?.developer ?? '開發者',
            value: l10n?.developerName ?? 'Danny Wang',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n?.developmentDate ?? '開發日期',
            value: l10n?.developmentDateValue ?? '2025年6月',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n?.email ?? '電子郵件',
            value: l10n?.developerEmail ?? 'tiger.danny@gmail.com',
            icon: Icons.email,
            isClickable: true,
            onTap: onContactDeveloper,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n?.cancel ?? '取消',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onContactDeveloper();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(l10n?.contactDeveloper ?? '聯繫開發者'),
        ),
      ],
    );
  }

  /// 显示应用信息对话框
  static void show(BuildContext context, VoidCallback onContactDeveloper) {
    showDialog(
      context: context,
      builder: (context) => AppInfoDialog(onContactDeveloper: onContactDeveloper),
    );
  }
}

/// 登出确认对话框
class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(l10n?.logout ?? '登出'),
      content: const Text('確定要登出嗎？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? '取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n?.logout ?? '登出'),
        ),
      ],
    );
  }

  /// 显示登出确认对话框
  static void show(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmDialog(onConfirm: onConfirm),
    );
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isClickable;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isClickable ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isClickable && onTap != null)
          Icon(
            Icons.open_in_new,
            size: 16,
            color: AppColors.primary,
          ),
      ],
    );

    if (isClickable && onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
} 
