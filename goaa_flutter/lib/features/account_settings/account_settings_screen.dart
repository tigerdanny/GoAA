import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'controllers/account_settings_controller.dart';
import 'widgets/account_info_section.dart';
import 'widgets/settings_menu_section.dart';

/// 帳務設定頁面 - 重構版
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late AccountSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccountSettingsController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.accountSettings ?? '帳務設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 帳戶信息區塊
                  AccountInfoSection(
                    userName: _controller.userName,
                    userCode: _controller.userCode,
                    avatarPath: _controller.avatarPath,
                    onEditProfile: _navigateToProfile,
                  ),
                  
                  // 帳務設置區塊
                  SettingsMenuSection(
                    title: '帳務設置',
                    items: [
                      SettingsMenuItem(
                        icon: Icons.account_balance_wallet,
                        title: '自動結算',
                        subtitle: '當群組費用平衡時自動結算',
                        onTap: _showAutoSettlementDialog,
                      ),
                      SettingsMenuItem(
                        icon: Icons.share,
                        title: '費用分享',
                        subtitle: '允許與群組成員分享費用詳情',
                        onTap: _showExpenseSharingDialog,
                      ),
                      SettingsMenuItem(
                        icon: Icons.monetization_on,
                        title: '預設貨幣',
                        subtitle: '新建群組時的預設貨幣',
                        onTap: _showCurrencyDialog,
                      ),
                    ],
                  ),
                  
                  // 提醒設置區塊
                  SettingsMenuSection(
                    title: '提醒設置',
                    items: [
                      SettingsMenuItem(
                        icon: Icons.notifications,
                        title: '提醒通知',
                        subtitle: '管理各種提醒通知設置',
                        onTap: _navigateToReminderSettings,
                      ),
                      SettingsMenuItem(
                        icon: Icons.warning,
                        title: '提醒閾值',
                        subtitle: '設置發送提醒的金額閾值',
                        onTap: _showThresholdDialog,
                      ),
                    ],
                  ),
                  
                  // 數據管理區塊
                  SettingsMenuSection(
                    title: '數據管理',
                    items: [
                      SettingsMenuItem(
                        icon: Icons.backup,
                        title: '備份數據',
                        subtitle: '將帳務數據備份到雲端',
                        onTap: _showBackupDialog,
                        iconColor: AppColors.info,
                      ),
                      SettingsMenuItem(
                        icon: Icons.restore,
                        title: '恢復數據',
                        subtitle: '從雲端恢復之前的備份',
                        onTap: _showRestoreDialog,
                        iconColor: AppColors.warning,
                      ),
                      SettingsMenuItem(
                        icon: Icons.delete_forever,
                        title: '清除所有數據',
                        subtitle: '永久刪除所有帳務記錄',
                        onTap: _showClearDataDialog,
                        iconColor: AppColors.error,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 導航到個人資料頁面
  void _navigateToProfile() {
    // 實現導航到個人資料頁面
    _showComingSoonDialog('個人資料編輯');
  }

  /// 導航到提醒設置頁面
  void _navigateToReminderSettings() {
    // 實現導航到提醒設置頁面
    _showComingSoonDialog('提醒設置');
  }

  /// 顯示自動結算對話框
  void _showAutoSettlementDialog() {
    _showComingSoonDialog('自動結算設置');
  }

  /// 顯示費用分享對話框
  void _showExpenseSharingDialog() {
    _showComingSoonDialog('費用分享設置');
  }

  /// 顯示貨幣選擇對話框
  void _showCurrencyDialog() {
    _showComingSoonDialog('貨幣設置');
  }

  /// 顯示閾值設置對話框
  void _showThresholdDialog() {
    _showComingSoonDialog('提醒閾值設置');
  }

  /// 顯示備份對話框
  void _showBackupDialog() {
    _showComingSoonDialog('數據備份');
  }

  /// 顯示恢復對話框
  void _showRestoreDialog() {
    _showComingSoonDialog('數據恢復');
  }

  /// 顯示清除數據對話框
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有數據'),
        content: const Text('此操作將永久刪除所有帳務記錄，且無法恢復。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonDialog('清除數據');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  /// 顯示即將推出對話框
  void _showComingSoonDialog(String feature) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('此功能即將推出，敬請期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
