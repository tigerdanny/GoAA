import 'package:flutter/material.dart';
import '../../core/database/database.dart';
import '../../core/database/database_service.dart';
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

  // Scaffold key for opening drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      
      // 如果没有当前用户，尝试创建一个
      if (_currentUser == null) {
        debugPrint('未找到當前用戶，嘗試創建新用戶');
        await DatabaseService.instance.initialize();
        _currentUser = await _userRepository.getCurrentUser();
        
        if (_currentUser == null) {
          debugPrint('創建用戶失敗，使用默認資料');
        } else {
          debugPrint('成功創建用戶: ${_currentUser!.name}');
        }
      }
      
      if (_currentUser != null) {
        _groups = await _groupRepository.getUserGroups(_currentUser!.id);
        
        _groupStats.clear();
        for (final group in _groups) {
          _groupStats[group.id] = await _groupRepository.getGroupStats(group.id);
        }
        
        _stats = await _userRepository.getUserStats(_currentUser!.id);
      }

      try {
        debugPrint('\n🌐 正在抓取今天的每日金句...');
        _dailyQuote = await DailyQuoteService().getDailyQuote();
        
        if (_dailyQuote != null) {
          debugPrint('\n📅 成功獲取今天的每日金句:');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('🇨🇳 中文: ${_dailyQuote!.contentZh}');
          debugPrint('🇺🇸 英文: ${_dailyQuote!.contentEn}');
          debugPrint('✍️  作者: ${_dailyQuote!.author ?? '未知'}');
          debugPrint('🏷️  分類: ${_dailyQuote!.category}');
          debugPrint('⏰ 時間: ${_dailyQuote!.createdAt.toString().substring(0, 19)}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          
          // 測試語言切換
          debugPrint('\n🌍 語言測試:');
          final zhContent = DailyQuoteService().getQuoteContent(_dailyQuote!, 'zh');
          final enContent = DailyQuoteService().getQuoteContent(_dailyQuote!, 'en');
          debugPrint('中文版本: $zhContent');
          debugPrint('英文版本: $enContent');
          debugPrint('');
        } else {
          debugPrint('⚠️  未能獲取每日金句，將使用默認內容');
        }
      } catch (e) {
        debugPrint('获取每日金句失败: $e');
        debugPrint('❌ 獲取每日金句失敗: $e');
        _dailyQuote = null;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      // 查詢並顯示資料庫中的所有每日金句
      await _showAllDailyQuotesInDatabase();
    } catch (e) {
      debugPrint('加載數據失敗: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 查詢並顯示資料庫中的所有每日金句
  Future<void> _showAllDailyQuotesInDatabase() async {
    try {
      final database = DatabaseService.instance.database;
      final allQuotes = await database.select(database.dailyQuotes).get();
      
      debugPrint('\n📚 資料庫中的每日金句總覽:');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('總共有 ${allQuotes.length} 條每日金句');
      debugPrint('═══════════════════════════════════════════════\n');
      
      for (int i = 0; i < allQuotes.length; i++) {
        final quote = allQuotes[i];
        debugPrint('📝 第 ${i + 1} 條金句:');
        debugPrint('   ID: ${quote.id}');
        debugPrint('   🇨🇳 中文: ${quote.contentZh}');
        debugPrint('   🇺🇸 英文: ${quote.contentEn}');
        debugPrint('   ✍️  作者: ${quote.author ?? '未知'}');
        debugPrint('   🏷️  分類: ${quote.category}');
        debugPrint('   ⏰ 創建時間: ${quote.createdAt.toString().substring(0, 19)}');
        debugPrint('   ─────────────────────────────────────────────\n');
      }
      
      // 統計不同分類的金句數量
      final Map<String, int> categoryStats = {};
      for (final quote in allQuotes) {
        categoryStats[quote.category] = (categoryStats[quote.category] ?? 0) + 1;
      }
      
      debugPrint('📊 金句分類統計:');
      categoryStats.forEach((category, count) {
        debugPrint('   $category: $count 條');
      });
      debugPrint('═══════════════════════════════════════════════\n');
      
    } catch (e) {
      debugPrint('查詢資料庫金句失敗: $e');
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
      key: _scaffoldKey,
      drawer: HomeDrawer(
        currentUser: _currentUser,
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
                  onMenuTap: () {
                    debugPrint('正在打開選單抽屜');
                    _scaffoldKey.currentState?.openDrawer();
                  },
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
