import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'drawer/index.dart' as drawer_components;

/// 首頁側邊選單組件
/// 根據 GOAA 設計指南實現的完整導航系統
/// 採用模組化設計，每個子組件都獨立管理
class HomeDrawer extends StatelessWidget {
  final User? currentUser;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const HomeDrawer({
    super.key,
    required this.currentUser,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // 抽屜頭部
            drawer_components.DrawerHeader(
              currentUser: currentUser,
              onShowQRCode: onShowQRCode,
              onScanQRCode: onScanQRCode,
            ),
            
            // 選單內容
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildPersonalInfoSection(context, l10n),
                  const SizedBox(height: 16),
                  _buildAccountSection(context, l10n),
                  const SizedBox(height: 16),
                  _buildSystemSection(context, l10n),
                  const SizedBox(height: 16),
                  _buildSupportSection(context, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建構個人資訊區段
  Widget _buildPersonalInfoSection(BuildContext context, AppLocalizations? l10n) {
    return drawer_components.DrawerMenuSection(
      title: l10n?.personalInfo ?? '個人資訊',
      items: [
        drawer_components.DrawerMenuItem(
          icon: Icons.account_circle_outlined,
          title: '個人檔案',
          subtitle: '編輯個人資料',
          onTap: () => drawer_components.DrawerNavigationService.navigateToProfile(context),
        ),
        drawer_components.DrawerMenuItem(
          icon: Icons.person_outline,
          title: l10n?.friendsInfo ?? '好友資訊',
          subtitle: '管理好友和聯繫人',
          onTap: () => drawer_components.DrawerNavigationService.navigateToFriends(context),
        ),
      ],
    );
  }

  /// 建構帳務設定區段
  Widget _buildAccountSection(BuildContext context, AppLocalizations? l10n) {
    return drawer_components.DrawerMenuSection(
      title: l10n?.accountSettings ?? '帳務設定',
      items: [
        drawer_components.DrawerMenuItem(
          icon: Icons.account_balance_wallet_outlined,
          title: l10n?.accountSettings ?? '帳務設定',
          subtitle: '貨幣、備份、匯出',
          onTap: () => drawer_components.DrawerNavigationService.navigateToAccountSettings(context),
        ),
        drawer_components.DrawerMenuItem(
          icon: Icons.analytics_outlined,
          title: '統計報表',
          subtitle: '查看支出分析',
          onTap: () => drawer_components.DrawerNavigationService.navigateToAnalytics(context),
        ),
      ],
    );
  }

  /// 建構系統設定區段
  Widget _buildSystemSection(BuildContext context, AppLocalizations? l10n) {
    return drawer_components.DrawerMenuSection(
      title: '系統設定',
      items: [
        drawer_components.DrawerMenuItem(
          icon: Icons.settings_outlined,
          title: l10n?.settings ?? '設定',
          subtitle: '介面、語言、主題',
          onTap: () => drawer_components.DrawerNavigationService.navigateToSettings(context),
        ),
        drawer_components.DrawerMenuItem(
          icon: Icons.notifications_outlined,
          title: '提醒設定',
          subtitle: '通知和提醒管理',
          onTap: () => drawer_components.DrawerNavigationService.navigateToReminderSettings(context),
        ),
      ],
    );
  }

  /// 建構說明與支援區段
  Widget _buildSupportSection(BuildContext context, AppLocalizations? l10n) {
    return drawer_components.DrawerMenuSection(
      title: '說明與支援',
      items: [
        drawer_components.DrawerMenuItem(
          icon: Icons.help_outline,
          title: '說明',
          subtitle: '使用指南和常見問題',
          onTap: () => drawer_components.DrawerNavigationService.navigateToHelp(context),
        ),
        drawer_components.DrawerMenuItem(
          icon: Icons.info_outline,
          title: l10n?.about ?? '關於',
          subtitle: '版本資訊和開發者',
          onTap: () => drawer_components.DrawerNavigationService.navigateToAbout(context),
        ),
      ],
    );
  }
} 
