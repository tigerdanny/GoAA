import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_switch_button.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/database.dart';
import '../../l10n/generated/app_localizations.dart';

/// GOAA設置頁面
/// 符合品牌設計理念：專業、友善、現代化
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = true;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _billRemindersEnabled = true;
  bool _settlementRemindersEnabled = true;
  bool _autoSettlementEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      _currentUser = await _userRepository.getCurrentUser();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('載入用戶資料失敗: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(l10n),
                _buildUserProfileCard(l10n),
                _buildSettingSections(l10n),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建應用欄
  Widget _buildAppBar(AppLocalizations? l10n) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ),
      title: Text(
        l10n?.settings ?? '設置',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        const CompactLanguageSwitchButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  /// 構建用戶資料卡片
  Widget _buildUserProfileCard(AppLocalizations? l10n) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          shadowColor: AppColors.textPrimary.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Row(
                    children: [
                      // 用戶頭像
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/goaa_logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // 用戶信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser?.name ?? l10n?.userName ?? 'GOAA用戶',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.userCode(_currentUser?.userCode ?? 'N/A') ?? '用戶代碼：${_currentUser?.userCode ?? "N/A"}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '已驗證用戶',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 編輯按鈕
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => _editProfile(),
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// 構建設置區段
  Widget _buildSettingSections(AppLocalizations? l10n) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // 個人資訊設置
        _buildSectionCard(
          l10n?.personalInfo ?? '個人信息',
          [
            _buildSettingItem(
              icon: Icons.person_outlined,
              title: l10n?.name ?? '姓名',
              subtitle: _currentUser?.name ?? l10n?.notAvailable ?? 'N/A',
              onTap: () => _editName(),
            ),
            _buildSettingItem(
              icon: Icons.email_outlined,
              title: l10n?.email ?? '電子郵件',
              subtitle: _currentUser?.email ?? l10n?.notAvailable ?? 'N/A',
              onTap: () => _editEmail(),
            ),
            _buildSettingItem(
              icon: Icons.phone_outlined,
              title: l10n?.phone ?? '電話',
              subtitle: _currentUser?.phone ?? l10n?.notAvailable ?? 'N/A',
              onTap: () => _editPhone(),
            ),
            _buildSettingItem(
              icon: Icons.account_circle_outlined,
              title: l10n?.avatar ?? '頭像',
              subtitle: '設置頭像',
              onTap: () => _editAvatar(),
            ),
          ],
        ),
        
        // 帳務設定
        _buildSectionCard(
          l10n?.accountSettings ?? '帳戶設置',
          [
            _buildSettingItem(
              icon: Icons.attach_money_outlined,
              title: l10n?.defaultCurrency ?? '默認貨幣',
              subtitle: 'USD (\$)',
              onTap: () => _editCurrency(),
            ),
            _buildSwitchItem(
              icon: Icons.auto_awesome_outlined,
              title: l10n?.autoSettlement ?? '自動結算',
              subtitle: '啟用自動結算',
              value: _autoSettlementEnabled,
              onChanged: (value) => setState(() => _autoSettlementEnabled = value),
            ),
            _buildSettingItem(
              icon: Icons.backup_outlined,
              title: l10n?.backupRestore ?? '備份與恢復',
              subtitle: '備份與恢復帳戶',
              onTap: () => _backupRestore(),
            ),
            _buildSettingItem(
              icon: Icons.file_download_outlined,
              title: l10n?.exportData ?? '導出數據',
              subtitle: 'CSV, Excel 格式',
              onTap: () => _exportData(),
            ),
          ],
        ),
        
        // 提醒設定
        _buildSectionCard(
          l10n?.reminderSettings ?? '提醒設置',
          [
            _buildSwitchItem(
              icon: Icons.notifications_outlined,
              title: l10n?.enableNotifications ?? '啟用通知',
              subtitle: '啟用通知',
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchItem(
              icon: Icons.receipt_long_outlined,
              title: l10n?.billReminders ?? '帳單提醒',
              subtitle: '啟用帳單提醒',
              value: _billRemindersEnabled,
              onChanged: (value) => setState(() => _billRemindersEnabled = value),
            ),
            _buildSwitchItem(
              icon: Icons.account_balance_outlined,
              title: l10n?.settlementReminders ?? '結算提醒',
              subtitle: '啟用結算提醒',
              value: _settlementRemindersEnabled,
              onChanged: (value) => setState(() => _settlementRemindersEnabled = value),
            ),
          ],
        ),
        
        // 介面設定
        _buildSectionCard(
          l10n?.interface ?? '界面設置',
          [
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: l10n?.language ?? '語言',
              subtitle: l10n?.languageTraditionalChinese ?? '繁體中文',
              onTap: () => _showLanguagePicker(),
            ),
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              title: l10n?.darkMode ?? '暗模式',
              subtitle: '啟用暗模式',
              value: _darkModeEnabled,
              onChanged: (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildSettingItem(
              icon: Icons.text_fields_outlined,
              title: l10n?.fontSize ?? '字體大小',
              subtitle: '調整字體大小',
              onTap: () => _editFontSize(),
            ),
            _buildSettingItem(
              icon: Icons.palette_outlined,
              title: l10n?.themeSettings ?? '主題設置',
              subtitle: 'GOAA主題',
              onTap: () => _editTheme(),
            ),
          ],
        ),
        
        // 其他設定
        _buildSectionCard(
          l10n?.about ?? '關於',
          [
            _buildSettingItem(
              icon: Icons.info_outlined,
              title: l10n?.version ?? '版本',
              subtitle: 'v1.0.0 (Build 1)',
              onTap: () => _showAppInfo(),
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: l10n?.privacy ?? '隱私',
              subtitle: '隱私政策',
              onTap: () => _showPrivacy(),
            ),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: l10n?.terms ?? '條款',
              subtitle: '使用條款',
              onTap: () => _showTerms(),
            ),
            _buildSettingItem(
              icon: Icons.support_agent_outlined,
              title: l10n?.support ?? '支持',
              subtitle: '24/7 支持',
              onTap: () => _contactSupport(),
            ),
            _buildSettingItem(
              icon: Icons.logout_outlined,
              title: l10n?.logout ?? '登出',
              subtitle: '登出帳戶',
              onTap: () => _logout(),
              isDestructive: true,
            ),
          ],
        ),
      ]),
    );
  }

  /// 構建設置區段卡片
  Widget _buildSectionCard(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 區段標題
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 設置項目
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                        indent: 20,
                        endIndent: 20,
                      ),
                    item,
                  ],
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 構建設置項目
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 圖標
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // 文字內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭頭圖標
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 構建開關項目
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 開關
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  // 交互方法
  void _editProfile() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.comingSoon ?? '功能開發中...')),
    );
  }

  void _editName() => _showComingSoon();
  void _editEmail() => _showComingSoon();
  void _editPhone() => _showComingSoon();
  void _editAvatar() => _showComingSoon();
  void _editCurrency() => _showComingSoon();
  void _backupRestore() => _showComingSoon();
  void _exportData() => _showComingSoon();
  void _showLanguagePicker() => _showComingSoon();
  void _editFontSize() => _showComingSoon();
  void _editTheme() => _showComingSoon();
  void _showAppInfo() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            _buildInfoRow(
              l10n?.appName ?? 'GOAA Bill Splitter',
              'GOAA Bill Splitter',
              Icons.apps,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              l10n?.version ?? '版本',
              'v1.0.0 (Build 1)',
              Icons.info_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              l10n?.developer ?? '開發者',
              l10n?.developerName ?? 'Danny Wang',
              Icons.person,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              l10n?.developmentDate ?? '開發日期',
              l10n?.developmentDateValue ?? '2025年6月',
              Icons.schedule,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              l10n?.email ?? '電子郵件',
              l10n?.developerEmail ?? 'tiger.danny@gmail.com',
              Icons.email,
              isClickable: true,
              onTap: () => _contactDeveloperByEmail(),
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
              _contactDeveloperByEmail();
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
      ),
    );
  }
  void _showPrivacy() => _showComingSoon();
  void _showTerms() => _showComingSoon();
  void _contactSupport() => _showComingSoon();

  void _showComingSoon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.comingSoon ?? '功能開發中...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _logout() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.logout ?? '登出'),
        content: Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? '取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n?.logout ?? '登出'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
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

  void _contactDeveloperByEmail() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n?.developerEmail ?? "tiger.danny@gmail.com"} ${l10n?.comingSoon ?? "功能開發中..."}'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: '聯繫',
          textColor: Colors.white,
          onPressed: () {
            //實現複製到剪貼板功能
          },
        ),
      ),
    );
  }
} 
