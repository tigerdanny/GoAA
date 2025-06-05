import 'package:flutter/material.dart';

/// 首頁動畫控制器
/// 管理首頁相關的所有動畫效果
class HomeAnimationController {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Getters
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;

  /// 初始化動畫
  void initialize(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: vsync,
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
  }

  /// 開始動畫
  void forward() {
    _animationController.forward();
  }

  /// 釋放資源
  void dispose() {
    _animationController.dispose();
  }
} 
