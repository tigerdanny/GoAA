import 'package:flutter/material.dart';

/// GOAA品牌色彩系統
/// 基於logo設計：橘色手勢保護綠色鈔票的理念
class AppColors {
  // 防止實例化
  AppColors._();

  // ============ 品牌主色 ============
  /// 主品牌色 - 深海藍 (信任、專業)
  static const Color primary = Color(0xFF1B5E7E);
  static const Color primaryLight = Color(0xFF4A8BB8);
  static const Color primaryDark = Color(0xFF0D3F56);

  /// 次要品牌色 - 活力橘 (友善、溫暖)
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFF8F66);
  static const Color secondaryDark = Color(0xFFE44A0C);

  /// 強調色 - 翠綠 (金錢、成功)
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);

  // ============ 功能色彩 ============
  /// 成功狀態
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E8);
  
  /// 警告狀態  
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// 錯誤狀態
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFEEBEE);
  
  /// 資訊狀態
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ 中性色彩 ============
  /// 文字顏色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// 背景顏色
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  /// 分隔線顏色
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // ============ 特殊功能色 ============
  /// 金錢相關
  static const Color moneyPositive = Color(0xFF4CAF50); // 收入/結清
  static const Color moneyNegative = Color(0xFFE53E3E); // 支出/欠款
  static const Color moneyNeutral = Color(0xFF757575);  // 平衡

  /// 群組顏色 (用於區分不同群組)
  static const List<Color> groupColors = [
    Color(0xFF1B5E7E), // 深海藍
    Color(0xFF4CAF50), // 翠綠
    Color(0xFFFF6B35), // 活力橘
    Color(0xFF9C27B0), // 紫色
    Color(0xFF673AB7), // 深紫
    Color(0xFF3F51B5), // 靛藍
    Color(0xFF009688), // 青色
    Color(0xFF795548), // 棕色
  ];

  // ============ 暗色主題 ============
  /// 暗色背景
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  
  /// 暗色文字
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF808080);

  // ============ 漸變色 ============
  /// 主要漸變 (首頁背景)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 成功漸變 (結算完成)
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 溫暖漸變 (活動狀態)
  static const LinearGradient warmGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ 便利方法 ============
  /// 帶透明度的主色
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) => accent.withValues(alpha: opacity);

  // ============ 工具方法 ============
  /// 根據索引獲取群組顏色
  static Color getGroupColor(int index) {
    return groupColors[index % groupColors.length];
  }

  /// 根據金額獲取顏色
  static Color getMoneyColor(double amount) {
    if (amount > 0) return moneyPositive;
    if (amount < 0) return moneyNegative;
    return moneyNeutral;
  }

  /// 根據背景色獲取對比色
  static Color getContrastColor(Color backgroundColor) {
    // 計算亮度
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : Colors.white;
  }
} 
