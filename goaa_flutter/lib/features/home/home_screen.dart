import 'package:flutter/material.dart';
import '../../core/database/database.dart';
import 'controllers/home_controller.dart';
import 'controllers/home_animation_controller.dart';
import 'views/home_loading_view.dart';
import 'services/home_interaction_service.dart';
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
  
  // 控制器
  late HomeController _homeController;
  late HomeAnimationController _animationController;

  // Scaffold key for opening drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _homeController = HomeController();
    _animationController = HomeAnimationController();
    _animationController.initialize(this);
  }

  void _loadData() {
    if (widget.preloadedUser != null) {
      _homeController.usePreloadedData(
        preloadedUser: widget.preloadedUser,
        preloadedGroups: widget.preloadedGroups,
        preloadedGroupStats: widget.preloadedGroupStats,
        preloadedStats: widget.preloadedStats,
      );
      _animationController.forward();
    } else {
      _homeController.loadDataAsync();
    }
    
    _homeController.addListener(() {
      if (mounted) {
        setState(() {});
        if (!_homeController.isLoading) {
          _animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_homeController.isLoading) {
      return const HomeLoadingView();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(
        currentUser: _homeController.currentUser,
        onShowQRCode: () => _showQRCode(),
        onScanQRCode: () => _scanQRCode(),
      ),
      drawerScrimColor: Colors.black.withValues(alpha: 0.3),
      drawerEdgeDragWidth: 60,
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController.fadeAnimation,
          child: SlideTransition(
            position: _animationController.slideAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    currentUser: _homeController.currentUser,
                    dailyQuote: _homeController.dailyQuote,
                    onMenuTap: () => _openDrawer(),
                    onShowQRCode: () => _showQRCode(),
                    onScanQRCode: () => _scanQRCode(),
                    languageCode: 'zh',
                  ),
                ),
                HomeStats(stats: _homeController.stats),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Text(
                      '最近帳務',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                HomeExpenses(
                  expenses: _homeController.expenses,
                  onExpenseTap: (expense) => _viewExpense(expense),
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
        onPressed: () => _showQuickActions(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // 交互方法
  void _showQRCode() {
    if (_homeController.currentUser != null) {
      HomeInteractionService.showQRCode(context, _homeController.currentUser!);
    }
  }

  void _scanQRCode() {
    HomeInteractionService.scanQRCode(context);
  }

  void _showQuickActions() {
    HomeInteractionService.showQuickActions(context);
  }

  void _openDrawer() {
    HomeInteractionService.openDrawer(_scaffoldKey);
  }

  void _viewExpense(Expense expense) {
    // 導航到費用詳情頁面
    debugPrint('查看費用: ${expense.description}');
  }
} 
