import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 好友页面应用栏组件
class FriendsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddFriend;

  const FriendsAppBar({
    super.key,
    required this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AppBar(
      title: Text(l10n?.friendsInfo ?? '好友資訊'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      actions: [
        IconButton(
          onPressed: onAddFriend,
          icon: Icon(Icons.person_add, color: AppColors.primary),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 
