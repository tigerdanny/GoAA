import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 搜索進度對話框 - 顯示搜索過程中的動畫
class SearchProgressDialog extends StatefulWidget {
  final Future<void> searchFuture;
  final VoidCallback onSearchComplete;

  const SearchProgressDialog({
    super.key,
    required this.searchFuture,
    required this.onSearchComplete,
  });

  @override
  State<SearchProgressDialog> createState() => _SearchProgressDialogState();
}

class _SearchProgressDialogState extends State<SearchProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;
  bool _isCompleted = false;
  
  final List<String> _searchSteps = [
    '正在連接到搜索服務...',
    '正在廣播搜索請求...',
    '等待用戶響應...',
    '正在收集搜索結果...',
    '正在整理用戶信息...',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSearchProcess();
  }

  void _initializeAnimations() {
    // 脈沖動畫 - 搜索圈的呼吸效果
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 旋轉動畫 - 搜索圖標旋轉
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);

    // 淡入淡出動畫 - 步驟文字切換
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fadeController);

    // 縮放動畫 - 完成時的彈性效果
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // 開始動畫
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _fadeController.forward();
  }

  Future<void> _startSearchProcess() async {
    // 模擬搜索步驟
    for (int i = 0; i < _searchSteps.length; i++) {
      if (mounted) {
        await _fadeController.reverse();
        setState(() {
          _currentStep = i;
        });
        await _fadeController.forward();
        await Future.delayed(Duration(milliseconds: 400 + (i * 200)));
      }
    }

    // 執行真正的搜索
    try {
      await widget.searchFuture;
    } catch (e) {
      // 錯誤處理
      debugPrint('搜索過程發生錯誤: $e');
    }

    // 搜索完成動畫
    if (mounted) {
      _pulseController.stop();
      _rotationController.stop();
      
      setState(() {
        _isCompleted = true;
      });
      
      await _scaleController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSearchComplete();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 防止用戶在搜索過程中返回
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 動畫區域
              SizedBox(
                height: 120,
                child: _buildAnimationArea(),
              ),
              
              const SizedBox(height: 24),
              
              // 標題
              Text(
                _isCompleted ? '搜索完成！' : '搜索好友中',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 步驟指示器
              if (!_isCompleted) _buildStepIndicator(),
              
              const SizedBox(height: 8),
              
              // 進度條
              if (!_isCompleted) _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationArea() {
    if (_isCompleted) {
      // 完成動畫
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    }

    // 搜索動畫
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外圈脈沖效果
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        
        // 中圈
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        
        // 旋轉的搜索圖標
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 32,
              ),
            );
          },
        ),
        
        // 環繞的小點
        for (int i = 0; i < 8; i++)
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              final angle = (i * 45 * 3.14159 / 180) + (_rotationAnimation.value * 2 * 3.14159);
              const radius = 45.0;
              return Positioned(
                left: 60 + radius * cos(angle) - 3,
                top: 60 + radius * sin(angle) - 3,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.6 + 0.4 * sin(_rotationAnimation.value * 2 * 3.14159 + i * 0.5),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return SizedBox(
      height: 50,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          _searchSteps[_currentStep],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _searchSteps.length;
    
    return Column(
      children: [
        // 進度條
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 進度文字
        Text(
          '${(_currentStep + 1)}/${_searchSteps.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
