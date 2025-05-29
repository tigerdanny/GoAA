import 'package:flutter/material.dart';

/// GoAA應用的顏色系統
/// 基於Material Design 3，並融入品牌色彩
class AppColors {
  // 私有構造函數，防止實例化
  AppColors._();

  // === 主色調系統 === //
  /// 主要品牌色 - 青藍色
  static const Color primary = Color(0xFF2BBAC5);
  
  /// 主色變體 - 深藍色
  static const Color primaryVariant = Color(0xFF1B5E7E);
  
  /// 次要色 - 橙黃色
  static const Color secondary = Color(0xFFF5A623);
  
  /// 次要色變體
  static const Color secondaryVariant = Color(0xFFE09900);

  // === 語義化顏色 === //
  /// 成功色 - 綠色系
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  /// 警告色 - 橙色系
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFCC02);
  static const Color warningDark = Color(0xFFF57C00);
  
  /// 錯誤色 - 紅色系
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  /// 信息色 - 藍色系
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // === 中性色階 === //
  /// 純白
  static const Color white = Color(0xFFFFFFFF);
  
  /// 純黑
  static const Color black = Color(0xFF000000);
  
  /// 中性色 - 50度
  static const Color neutral50 = Color(0xFFFAFAFA);
  
  /// 中性色 - 100度
  static const Color neutral100 = Color(0xFFF5F5F5);
  
  /// 中性色 - 200度
  static const Color neutral200 = Color(0xFFEEEEEE);
  
  /// 中性色 - 300度
  static const Color neutral300 = Color(0xFFE0E0E0);
  
  /// 中性色 - 400度
  static const Color neutral400 = Color(0xFFBDBDBD);
  
  /// 中性色 - 500度
  static const Color neutral500 = Color(0xFF9E9E9E);
  
  /// 中性色 - 600度
  static const Color neutral600 = Color(0xFF757575);
  
  /// 中性色 - 700度
  static const Color neutral700 = Color(0xFF616161);
  
  /// 中性色 - 800度
  static const Color neutral800 = Color(0xFF424242);
  
  /// 中性色 - 900度
  static const Color neutral900 = Color(0xFF212121);

  // === 分帳功能專用色彩 === //
  /// 收入/獲得金錢 - 綠色
  static const Color income = success;
  
  /// 支出/欠款 - 紅色
  static const Color expense = error;
  
  /// 平衡/中性 - 藍色
  static const Color balanced = info;
  
  /// 待結算 - 橙色
  static const Color pending = warning;

  // === 表面色彩 === //
  /// 背景色
  static const Color background = Color(0xFFFDFDFD);
  
  /// 表面色
  static const Color surface = Color(0xFFFFFFFF);
  
  /// 表面變體色
  static const Color surfaceVariant = Color(0xFFF3F3F3);
  
  /// 深色表面
  static const Color surfaceDark = Color(0xFF121212);

  // === 文字色彩 === //
  /// 主要文字色
  static const Color onSurface = Color(0xFF1C1B1F);
  
  /// 次要文字色
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  /// 主色上的文字色
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  /// 次要色上的文字色
  static const Color onSecondary = Color(0xFF000000);
  
  /// 錯誤色上的文字色
  static const Color onError = Color(0xFFFFFFFF);

  // === 邊框和分隔線 === //
  /// 邊框色
  static const Color outline = Color(0xFFCAC4D0);
  
  /// 淺邊框色
  static const Color outlineVariant = Color(0xFFE7E0EC);
  
  /// 分隔線色
  static const Color divider = Color(0xFFE0E0E0);

  // === 透明度變體 === //
  /// 主色 - 10% 透明度
  static Color get primaryWithOpacity10 => primary.withOpacity(0.1);
  
  /// 主色 - 20% 透明度
  static Color get primaryWithOpacity20 => primary.withOpacity(0.2);
  
  /// 主色 - 50% 透明度
  static Color get primaryWithOpacity50 => primary.withOpacity(0.5);
  
  /// 黑色 - 10% 透明度
  static Color get blackWithOpacity10 => black.withOpacity(0.1);
  
  /// 黑色 - 20% 透明度
  static Color get blackWithOpacity20 => black.withOpacity(0.2);
  
  /// 白色 - 90% 透明度
  static Color get whiteWithOpacity90 => white.withOpacity(0.9);

  // === 漸層色彩 === //
  /// 主要漸層 - 品牌色漸層
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryVariant],
  );
  
  /// 啟動畫面漸層
  static const Gradient splashGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [primaryVariant, Color(0xFF0A3A52)],
  );
  
  /// 成功漸層
  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );
  
  /// 警告漸層
  static const Gradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningLight, warning],
  );

  // === 陰影色彩 === //
  /// 輕微陰影色
  static Color get shadowLight => black.withOpacity(0.08);
  
  /// 中等陰影色
  static Color get shadowMedium => black.withOpacity(0.16);
  
  /// 深色陰影色
  static Color get shadowDark => black.withOpacity(0.24);
} 
