import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 個人資料頁面應用欄組件
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoading;
  final bool isSaving;
  final bool hasCurrentUser;
  final VoidCallback onSave;

  const ProfileAppBar({
    super.key,
    required this.isLoading,
    required this.isSaving,
    required this.hasCurrentUser,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AppBar(
      title: Text(l10n?.userProfile ?? '個人資料'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios),
            )
          : null,
      actions: [
        if (!isLoading)
          TextButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    hasCurrentUser ? '更新資料' : '完成設置',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 
