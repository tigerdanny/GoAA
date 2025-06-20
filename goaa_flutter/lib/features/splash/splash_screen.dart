import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'controllers/splash_controller.dart';
import 'widgets/splash_logo.dart';
import 'widgets/loading_indicator.dart';

/// 啟動畫面 - 重構版
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashController _controller;
  bool _logoAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _controller = SplashController();
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 設置系統UI
  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// 控制器狀態變化處理
  void _onControllerChanged() {
    if (_controller.isCompleted && _logoAnimationComplete) {
      _navigateToNext();
    }
  }

  /// Logo 動畫完成處理
  void _onLogoAnimationComplete() {
    setState(() {
      _logoAnimationComplete = true;
    });
    
    if (_controller.isCompleted) {
      _navigateToNext();
    }
  }

  /// 導航到下一個頁面
  void _navigateToNext() {
    if (!mounted) return;

    // 根據導航目標決定要跳轉的頁面
    Widget targetScreen;
    if (_controller.navigationTarget == NavigationTarget.profile) {
      targetScreen = const ProfileScreen();
    } else {
      targetScreen = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return targetScreen;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// 重試初始化
  void _retry() {
    _controller.retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 背景漸變
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            
            // 主要內容
            Column(
              children: [
                // Logo 區域
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SplashLogo(
                      onAnimationComplete: _onLogoAnimationComplete,
                    ),
                  ),
                ),
                
                // 加載指示器區域
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, child) {
                        if (_controller.hasError) {
                          return _buildErrorWidget();
                        }
                        
                        return LoadingIndicator(
                          message: _controller.message,
                          isVisible: _controller.isLoading,
                        );
                      },
                    ),
                  ),
                ),
                
                // 底部版本信息
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 構建錯誤widget
  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        const Text(
          '初始化失敗',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _controller.errorMessage ?? '未知錯誤',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _retry,
          child: const Text('重試'),
        ),
      ],
    );
  }
}
