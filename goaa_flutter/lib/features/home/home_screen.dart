import 'package:flutter/material.dart';
import '../../core/database/database.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/repositories/group_repository.dart';
import '../../core/services/daily_quote_service.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/index.dart';

/// 首頁主界面
/// 展示用戶的群組列表、快速操作和統計概覽
class HomeScreen extends StatefulWidget {
  final User? preloadedUser;
  final List<Group>? preloadedGroups;
  final Map<int, Map<String, dynamic>>? preloadedGroupStats;
  final Map<String, dynamic>? preloadedStats;

  const HomeScreen({
    super.key,
    this.preloadedUser,
    this.preloadedGroups,
    this.preloadedGroupStats,
    this.preloadedStats,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // 數據相關
  bool _isLoading = false;
  User? _currentUser;
  List<Group> _groups = [];
  final Map<int, Map<String, dynamic>> _groupStats = {};
  Map<String, dynamic> _stats = {};
  DailyQuote? _dailyQuote;

  // 動畫控制器
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Repository實例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.preloadedUser != null) {
      _usePreloadedData();
    } else {
      _loadData();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _usePreloadedData() {
    _currentUser = widget.preloadedUser;
    _groups = widget.preloadedGroups ?? [];
    _groupStats.clear();
    _groupStats.addAll(widget.preloadedGroupStats ?? {});
    _stats = widget.preloadedStats ?? {};
    
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      _currentUser = await _userRepository.getCurrentUser();
      
      if (_currentUser != null) {
        _groups = await _groupRepository.getUserGroups(_currentUser!.id);
        
        _groupStats.clear();
        for (final group in _groups) {
          _groupStats[group.id] = await _groupRepository.getGroupStats(group.id);
        }
        
        _stats = await _userRepository.getUserStats(_currentUser!.id);
      }

      try {
        _dailyQuote = await DailyQuoteService().getDailyQuote();
      } catch (e) {
        debugPrint('获取每日金句失败: $e');
        _dailyQuote = null;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('加載數據失敗: $e');
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
    
    if (_isLoading) {
      return _buildLoadingScreen(l10n);
    }

    return Scaffold(
      drawer: HomeDrawer(
        currentUser: _currentUser,
        dailyQuote: _dailyQuote,
        onShowQRCode: _showQRCode,
        onScanQRCode: _scanQRCode,
      ),
      drawerScrimColor: Colors.black.withValues(alpha: 0.3),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                HomeHeader(
                  currentUser: _currentUser,
                  dailyQuote: _dailyQuote,
                  onMenuTap: () => Scaffold.of(context).openDrawer(),
                  onShowQRCode: _showQRCode,
                  onScanQRCode: _scanQRCode,
                ),
                HomeStats(stats: _stats),
                SectionTitle(title: l10n?.myGroups ?? '我的群組'),
                HomeGroups(
                  groups: _groups,
                  onGroupTap: _enterGroup,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: HomeQuickActionButton(
        onPressed: () => QuickActionsSheet.show(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingScreen(AppLocalizations? l10n) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/goaa_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.loading ?? '載入中...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 交互方法
  void _enterGroup(Group group) {
    // 導航到群組詳情頁面
  }

  void _showQRCode() {
    if (_currentUser != null) {
      QRCodeDialog.show(context, _currentUser!);
    }
  }

  void _scanQRCode() {
    QRCodeScanner.scan(context);
  }
} 
