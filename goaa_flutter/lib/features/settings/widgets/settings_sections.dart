import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'settings_items.dart';

/// 设置区段组件
class SettingsSections extends StatelessWidget {
  final User? currentUser;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool billRemindersEnabled;
  final bool settlementRemindersEnabled;
  final bool autoSettlementEnabled;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBillRemindersChanged;
  final ValueChanged<bool> onSettlementRemindersChanged;
  final ValueChanged<bool> onAutoSettlementChanged;
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onEditPhone;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditCurrency;
  final VoidCallback onBackupRestore;
  final VoidCallback onExportData;
  final VoidCallback onShowLanguagePicker;
  final VoidCallback onEditFontSize;
  final VoidCallback onEditTheme;
  final VoidCallback onShowAppInfo;
  final VoidCallback onShowPrivacy;
  final VoidCallback onShowTerms;
  final VoidCallback onContactSupport;
  final VoidCallback onLogout;

  const SettingsSections({
    super.key,
    required this.currentUser,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.billRemindersEnabled,
    required this.settlementRemindersEnabled,
    required this.autoSettlementEnabled,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
    required this.onBillRemindersChanged,
    required this.onSettlementRemindersChanged,
    required this.onAutoSettlementChanged,
    required this.onEditName,
    required this.onEditEmail,
    required this.onEditPhone,
    required this.onEditAvatar,
    required this.onEditCurrency,
    required this.onBackupRestore,
    required this.onExportData,
    required this.onShowLanguagePicker,
    required this.onEditFontSize,
    required this.onEditTheme,
    required this.onShowAppInfo,
    required this.onShowPrivacy,
    required this.onShowTerms,
    required this.onContactSupport,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SliverList(
      delegate: SliverChildListDelegate([
        // 個人資訊設置
        _buildPersonalInfoSection(l10n),
        
        // 帳務設定
        _buildAccountSection(l10n),
        
        // 提醒設定
        _buildReminderSection(l10n),
        
        // 介面設定
        _buildInterfaceSection(l10n),
        
        // 其他設定
        _buildAboutSection(l10n),
      ]),
    );
  }

  Widget _buildPersonalInfoSection(AppLocalizations? l10n) {
    return SettingSectionCard(
      title: l10n?.personalInfo ?? '個人信息',
      items: [
        SettingItem(
          icon: Icons.person_outlined,
          title: l10n?.name ?? '姓名',
          subtitle: currentUser?.name ?? l10n?.notAvailable ?? 'N/A',
          onTap: onEditName,
        ),
        SettingItem(
          icon: Icons.email_outlined,
          title: l10n?.email ?? '電子郵件',
          subtitle: currentUser?.email ?? l10n?.notAvailable ?? 'N/A',
          onTap: onEditEmail,
        ),
        SettingItem(
          icon: Icons.phone_outlined,
          title: l10n?.phone ?? '電話',
          subtitle: currentUser?.phone ?? l10n?.notAvailable ?? 'N/A',
          onTap: onEditPhone,
        ),
        SettingItem(
          icon: Icons.account_circle_outlined,
          title: l10n?.avatar ?? '頭像',
          subtitle: '設置頭像',
          onTap: onEditAvatar,
        ),
      ],
    );
  }

  Widget _buildAccountSection(AppLocalizations? l10n) {
    return SettingSectionCard(
      title: l10n?.accountSettings ?? '帳戶設置',
      items: [
        SettingItem(
          icon: Icons.attach_money_outlined,
          title: l10n?.defaultCurrency ?? '默認貨幣',
          subtitle: 'USD (\$)',
          onTap: onEditCurrency,
        ),
        SettingSwitchItem(
          icon: Icons.auto_awesome_outlined,
          title: l10n?.autoSettlement ?? '自動結算',
          subtitle: '啟用自動結算',
          value: autoSettlementEnabled,
          onChanged: onAutoSettlementChanged,
        ),
        SettingItem(
          icon: Icons.backup_outlined,
          title: l10n?.backupRestore ?? '備份與恢復',
          subtitle: '備份與恢復帳戶',
          onTap: onBackupRestore,
        ),
        SettingItem(
          icon: Icons.file_download_outlined,
          title: l10n?.exportData ?? '導出數據',
          subtitle: 'CSV, Excel 格式',
          onTap: onExportData,
        ),
      ],
    );
  }

  Widget _buildReminderSection(AppLocalizations? l10n) {
    return SettingSectionCard(
      title: l10n?.reminderSettings ?? '提醒設置',
      items: [
        SettingSwitchItem(
          icon: Icons.notifications_outlined,
          title: l10n?.enableNotifications ?? '啟用通知',
          subtitle: '啟用通知',
          value: notificationsEnabled,
          onChanged: onNotificationsChanged,
        ),
        SettingSwitchItem(
          icon: Icons.receipt_long_outlined,
          title: l10n?.billReminders ?? '帳單提醒',
          subtitle: '啟用帳單提醒',
          value: billRemindersEnabled,
          onChanged: onBillRemindersChanged,
        ),
        SettingSwitchItem(
          icon: Icons.account_balance_outlined,
          title: l10n?.settlementReminders ?? '結算提醒',
          subtitle: '啟用結算提醒',
          value: settlementRemindersEnabled,
          onChanged: onSettlementRemindersChanged,
        ),
      ],
    );
  }

  Widget _buildInterfaceSection(AppLocalizations? l10n) {
    return SettingSectionCard(
      title: l10n?.interface ?? '界面設置',
      items: [
        SettingItem(
          icon: Icons.language_outlined,
          title: l10n?.language ?? '語言',
          subtitle: l10n?.languageTraditionalChinese ?? '繁體中文',
          onTap: onShowLanguagePicker,
        ),
        SettingSwitchItem(
          icon: Icons.dark_mode_outlined,
          title: l10n?.darkMode ?? '暗模式',
          subtitle: '啟用暗模式',
          value: darkModeEnabled,
          onChanged: onDarkModeChanged,
        ),
        SettingItem(
          icon: Icons.text_fields_outlined,
          title: l10n?.fontSize ?? '字體大小',
          subtitle: '調整字體大小',
          onTap: onEditFontSize,
        ),
        SettingItem(
          icon: Icons.palette_outlined,
          title: l10n?.themeSettings ?? '主題設置',
          subtitle: 'GOAA主題',
          onTap: onEditTheme,
        ),
      ],
    );
  }

  Widget _buildAboutSection(AppLocalizations? l10n) {
    return SettingSectionCard(
      title: l10n?.about ?? '關於',
      items: [
        SettingItem(
          icon: Icons.info_outlined,
          title: l10n?.version ?? '版本',
          subtitle: 'v1.0.0 (Build 1)',
          onTap: onShowAppInfo,
        ),
        SettingItem(
          icon: Icons.privacy_tip_outlined,
          title: l10n?.privacy ?? '隱私',
          subtitle: '隱私政策',
          onTap: onShowPrivacy,
        ),
        SettingItem(
          icon: Icons.description_outlined,
          title: l10n?.terms ?? '條款',
          subtitle: '使用條款',
          onTap: onShowTerms,
        ),
        SettingItem(
          icon: Icons.support_agent_outlined,
          title: l10n?.support ?? '支持',
          subtitle: '24/7 支持',
          onTap: onContactSupport,
        ),
        SettingItem(
          icon: Icons.logout_outlined,
          title: l10n?.logout ?? '登出',
          subtitle: '登出帳戶',
          onTap: onLogout,
          isDestructive: true,
        ),
      ],
    );
  }
} 
