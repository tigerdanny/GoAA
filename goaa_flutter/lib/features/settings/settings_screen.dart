import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/database.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/index.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                const SettingsAppBar(),
                SettingsUserProfile(
                  currentUser: _currentUser,
                  isLoading: _isLoading,
                  onEditProfile: _editProfile,
                ),
                SettingsSections(
                  currentUser: _currentUser,
                  darkModeEnabled: _darkModeEnabled,
                  notificationsEnabled: _notificationsEnabled,
                  billRemindersEnabled: _billRemindersEnabled,
                  settlementRemindersEnabled: _settlementRemindersEnabled,
                  autoSettlementEnabled: _autoSettlementEnabled,
                  onDarkModeChanged: (value) => setState(() => _darkModeEnabled = value),
                  onNotificationsChanged: (value) => setState(() => _notificationsEnabled = value),
                  onBillRemindersChanged: (value) => setState(() => _billRemindersEnabled = value),
                  onSettlementRemindersChanged: (value) => setState(() => _settlementRemindersEnabled = value),
                  onAutoSettlementChanged: (value) => setState(() => _autoSettlementEnabled = value),
                  onEditName: _showComingSoon,
                  onEditEmail: _showComingSoon,
                  onEditPhone: _showComingSoon,
                  onEditAvatar: _showComingSoon,
                  onEditCurrency: _showComingSoon,
                  onBackupRestore: _showComingSoon,
                  onExportData: _showComingSoon,
                  onShowLanguagePicker: _showComingSoon,
                  onEditFontSize: _showComingSoon,
                  onEditTheme: _showComingSoon,
                  onShowAppInfo: _showAppInfo,
                  onShowPrivacy: _showComingSoon,
                  onShowTerms: _showComingSoon,
                  onContactSupport: _showComingSoon,
                  onLogout: _logout,
                ),
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

  // 交互方法
  void _editProfile() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.comingSoon ?? '功能開發中...')),
    );
  }

  void _showComingSoon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.comingSoon ?? '功能開發中...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAppInfo() {
    AppInfoDialog.show(context, _contactDeveloperByEmail);
  }

  void _logout() {
    LogoutConfirmDialog.show(context, () {
      Navigator.pop(context);
    });
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
            // 實現複製到剪貼板功能
          },
        ),
      ),
    );
  }
} 
