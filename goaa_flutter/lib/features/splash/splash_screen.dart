import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// GoAA啟動畫面
/// 複製Android版本的設計，包含品牌標誌和漸層背景
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 標誌動畫控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 淡入動畫控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 標誌縮放動畫
    _logoAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    // 淡入動畫
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // 開始動畫序列
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 等待一小段時間
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 開始淡入動畫
    _fadeController.forward();
    
    // 稍後開始標誌動畫
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // 總等待時間約1.2秒後跳轉到主頁面
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (mounted) {
      // TODO: 跳轉到主頁面（暫時跳轉到一個佔位頁面）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const _PlaceholderHomePage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 使用漸層背景，與Android版本保持一致
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主要標誌區域
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.scale(
                            scale: _logoAnimation.value,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 應用圖標
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: AppDimensions.shadowXL,
                                  ),
                                  child: const Icon(
                                    Icons.group_work_rounded,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                ),
                                
                                const SizedBox(height: AppDimensions.space32),
                                
                                // 應用名稱
                                Text(
                                  'GoAA',
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 48,
                                  ),
                                ),
                                
                                const SizedBox(height: AppDimensions.space8),
                                
                                // 副標題
                                Text(
                                  '分帳神器',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // 底部區域
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 載入指示器
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                            
                            const SizedBox(height: AppDimensions.space16),
                            
                            // 版本資訊
                            Text(
                              '讓分帳變得簡單優雅',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withOpacity(0.7),
                              ),
                            ),
                            
                            const SizedBox(height: AppDimensions.space24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 暫時的首頁佔位頁面
/// TODO: 替換為實際的主頁面
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GoAA分帳神器'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: AppDimensions.space16),
            Text(
              '正在開發中...',
              style: AppTextStyles.h4,
            ),
            SizedBox(height: AppDimensions.space8),
            Text(
              'Flutter版本即將完成',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
} 
