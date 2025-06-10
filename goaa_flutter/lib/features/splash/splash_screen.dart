import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/repositories/group_repository.dart';
import '../../core/database/database.dart';
import '../home/home_screen.dart';

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
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
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

    // 順序執行數據載入和動畫，避免並發複雜度
    _loadAppData().then((_) {
      return _waitForMinimumDuration();
    }).then((_) {
      _checkNavigationReady();
    });
  }

  /// 載入應用數據（完全簡化版，無await）
  Future<void> _loadAppData() {
    return _userRepository.getCurrentUser().then((user) {
      _currentUser = user;
      
      if (_currentUser != null) {
        return _groupRepository.getUserGroups(_currentUser!.id);
      } else {
        return Future.value(<Group>[]);
      }
    }).then((groups) {
      _groups = groups;
      
      // 其他數據使用非阻塞載入
      if (_currentUser != null) {
        _userRepository.getUserStats(_currentUser!.id).then((stats) {
          _stats = stats;
        }).catchError((e) {
          debugPrint('統計載入失敗: $e');
          _stats = <String, dynamic>{};
        });
        
        // 群組統計也改為非阻塞
        for (final group in _groups) {
          _groupRepository.getGroupStats(group.id).then((stats) {
            _groupStats[group.id] = stats;
          }).catchError((e) {
            debugPrint('群組統計載入失敗: $e');
            _groupStats[group.id] = <String, dynamic>{};
          });
        }
      }

      setState(() => _dataLoaded = true);
    }).catchError((e) {
      debugPrint('數據載入失敗: $e');
      setState(() => _dataLoaded = true);
    });
  }

  /// 等待最小显示时间（簡化版）
  Future<void> _waitForMinimumDuration() {
    return Future.delayed(const Duration(milliseconds: 2000)).then((_) {
      setState(() => _animationCompleted = true);
    });
  }

  /// 检查是否可以导航
  void _checkNavigationReady() {
    if (_dataLoaded && _animationCompleted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      // 直接导航到HomeScreen并传递预加载的数据
      Navigator.of(context).pushReplacement(
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
