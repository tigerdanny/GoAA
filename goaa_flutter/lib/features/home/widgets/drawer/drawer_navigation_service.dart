import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/settings_screen.dart';
import '../../../profile/profile_screen.dart';

/// 抽屜導航服務
/// 集中管理所有抽屜的導航邏輯
class DrawerNavigationService {
  /// 導航到設定頁面
  static void navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// 導航到好友頁面
  static void navigateToFriends(BuildContext context) {
    Navigator.pop(context);
    // 實現好友頁面
    _showComingSoon(context);
  }

  /// 導航到帳務設定頁面
  static void navigateToAccountSettings(BuildContext context) {
    Navigator.pop(context);
    // 實現帳務設定頁面
    _showComingSoon(context);
  }

  /// 導航到關於頁面
  static void navigateToAbout(BuildContext context) {
    Navigator.pop(context);
    // 實現關於頁面
    _showComingSoon(context);
  }

  /// 導航到個人檔案頁面
  static void navigateToProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  /// 導航到統計報表頁面
  static void navigateToAnalytics(BuildContext context) {
    Navigator.pop(context);
    // 實現統計報表頁面
    _showComingSoon(context);
  }

  /// 導航到提醒設定頁面
  static void navigateToReminderSettings(BuildContext context) {
    Navigator.pop(context);
    // 實現提醒設定頁面
    _showComingSoon(context);
  }

  /// 導航到說明頁面
  static void navigateToHelp(BuildContext context) {
    Navigator.pop(context);
    // 實現說明頁面
    _showComingSoon(context);
  }

  /// 顯示功能開發中提示
  static void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.comingSoon ?? '功能開發中...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
} 
