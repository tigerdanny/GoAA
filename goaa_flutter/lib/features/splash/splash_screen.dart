import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/repositories/group_repository.dart';
import '../../core/database/database.dart';
import '../../core/utils/performance_monitor.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

/// 啟動畫面 - 集成数据加载功能
/// 展示品牌Logo並執行所有初始化工作
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  // Repository实例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();

  // 数据加载状态
  User? _currentUser;
  List<Group> _groups = [];
  final Map<int, Map<String, dynamic>> _groupStats = {};
  Map<String, dynamic> _stats = {};
  
  bool _dataLoaded = false;

  // 🚀 新增：記錄開始時間
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // 記錄開始時間
    
    // 🚀 性能監控：記錄Splash開始時間
    PerformanceMonitor.recordTimestamp('Splash開始');
    
    _initializeAnimations();
    _startLoadingProcess();
  }

  void _initializeAnimations() {
    // Logo动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo缩放动画
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Logo透明度动画
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
  }

  void _startLoadingProcess() {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 启动logo动画
    _logoController.forward();

    // 🚀 重新設計：使用 async/await 並行載入
    _loadAppDataAsync();
  }

  /// 🚀 重新設計：完全使用 async/await 的數據載入
  Future<void> _loadAppDataAsync() async {
    try {
      // 🚀 性能監控：記錄數據載入開始
      PerformanceMonitor.recordTimestamp('數據載入開始');
      
      // 1. 首先載入當前用戶（這是基礎數據，必須先載入）
      _currentUser = await _userRepository.getCurrentUser();
      
      // 檢查是否有用戶資料
      if (_currentUser == null) {
        debugPrint('🚨 沒有用戶資料，將跳轉到個人資訊頁面');
        setState(() => _dataLoaded = true);
        await _waitForAnimationAndNavigate();
        return;
      }
      
      debugPrint('✅ 已有用戶資料，載入完整應用數據');
      
      // 🚀 並行載入：同時進行多個不相關的數據查詢
      final futures = <Future>[];
      
      // 並行任務1：載入用戶群組
      final groupsFuture = _groupRepository.getUserGroups(_currentUser!.id);
      futures.add(groupsFuture);
      
      // 並行任務2：載入用戶統計
      final statsFuture = _userRepository.getUserStats(_currentUser!.id);
      futures.add(statsFuture);
      
      // 等待所有並行任務完成
      final results = await Future.wait([
        groupsFuture,
        statsFuture,
      ]);
      
      // 處理結果
      _groups = results[0] as List<Group>;
      _stats = results[1] as Map<String, dynamic>;
      
      // 🚀 優化：只載入前5個群組的統計，其他延遲載入
      if (_groups.isNotEmpty) {
        final priorityGroups = _groups.take(5).toList();
        final groupStatsFutures = priorityGroups.map((group) => 
          _loadGroupStatsAsync(group.id)
        );
        
        // 並行載入群組統計
        await Future.wait(groupStatsFutures);
      }
      
      // 🚀 性能監控：記錄數據載入完成時間
      PerformanceMonitor.recordTimestamp('數據載入完成');
      PerformanceMonitor.recordDuration('數據載入時間', '數據載入開始', '數據載入完成');
      
      setState(() => _dataLoaded = true);
      
      // 等待動畫完成並導航
      await _waitForAnimationAndNavigate();
      
    } catch (e) {
      debugPrint('❌ 數據載入失敗: $e');
      setState(() => _dataLoaded = true);
      await _waitForAnimationAndNavigate();
    }
  }
  
  /// 🚀 新增：並行載入群組統計的輔助方法
  Future<void> _loadGroupStatsAsync(int groupId) async {
    try {
      final stats = await _groupRepository.getGroupStats(groupId);
      _groupStats[groupId] = stats;
    } catch (e) {
      debugPrint('⚠️ 群組統計載入失敗: $e');
      _groupStats[groupId] = <String, dynamic>{};
    }
  }

  /// 🚀 重新設計：等待動畫完成並導航
  Future<void> _waitForAnimationAndNavigate() async {
    // 計算動畫剩餘時間
    const animationDuration = Duration(milliseconds: 1500);
    final elapsed = DateTime.now().difference(_startTime ?? DateTime.now());
    final remaining = animationDuration - elapsed;
    
    // 如果還需要等待動畫完成
    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }
    
    // 導航到首頁
    await _navigateToHomeAsync();
  }
  
  /// 🚀 重新設計：異步導航到目標頁面
  Future<void> _navigateToHomeAsync() async {
    if (!mounted) return;
    
    // 🚀 性能監控：記錄導航開始時間
    PerformanceMonitor.recordTimestamp('導航開始');
    PerformanceMonitor.recordDuration('總啟動時間', '應用啟動開始', '導航開始');
    
    // 打印性能報告
    PerformanceMonitor.printPerformanceReport();
    
    // 根據是否有用戶資料決定導航目標
    if (_currentUser == null) {
      debugPrint('🚨 導航到個人資訊頁面（首次使用）');
      // 導航到個人資訊頁面
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      debugPrint('✅ 導航到首頁（正常使用）');
      // 導航到首頁
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PreloadedHomeScreen(
            currentUser: _currentUser,
            groups: _groups,
            groupStats: _groupStats,
            stats: _stats,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo区域
              _buildLogoSection(),
              
              const SizedBox(height: 40),
              
              // 文字区域
              _buildTextSection(),
              
              const Spacer(flex: 2),
              
              // 加载指示器
              _buildLoadingSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Logo区域
  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoOpacityAnimation.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/images/goaa_logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover, // 填满整个容器
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建文字区域
  Widget _buildTextSection() {
    return FadeTransition(
      opacity: _logoOpacityAnimation,
      child: Column(
        children: [
          // 应用名称
          Text(
            'GOAA分帳神器',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 应用描述
          Text(
            '讓分帳變得簡單優雅',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingSection() {
    return FadeTransition(
      opacity: _logoOpacityAnimation,
      child: Column(
        children: [
          // 加载指示器
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 加载文字
          Text(
            _dataLoaded ? '準備就緒...' : '正在載入...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 预加载数据的HomeScreen
class PreloadedHomeScreen extends StatelessWidget {
  final User? currentUser;
  final List<Group> groups;
  final Map<int, Map<String, dynamic>> groupStats;
  final Map<String, dynamic> stats;

  const PreloadedHomeScreen({
    super.key,
    required this.currentUser,
    required this.groups,
    required this.groupStats,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      preloadedUser: currentUser,
      preloadedGroups: groups,
      preloadedGroupStats: groupStats,
      preloadedStats: stats,
    );
  }
} 
