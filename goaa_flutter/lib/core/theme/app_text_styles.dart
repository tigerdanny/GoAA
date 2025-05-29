import 'package:flutter/material.dart';
import 'app_colors.dart';

/// GoAA應用的文字樣式系統
/// 基於Material Design 3的Typography，針對分帳應用優化
class AppTextStyles {
  // 私有構造函數，防止實例化
  AppTextStyles._();

  // === 標題系列 === //
  /// 大標題 - 用於主要頁面標題
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  /// 中標題 - 用於頁面副標題
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.onSurface,
  );

  /// 小標題 - 用於區塊標題
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// 次級標題 - 用於卡片標題
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  /// 小型標題 - 用於列表項標題
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  /// 最小標題 - 用於表單標籤
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  // === 正文系列 === //
  /// 大正文 - 用於重要內容
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  /// 中正文 - 用於一般內容
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.onSurface,
  );

  /// 小正文 - 用於輔助內容
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );

  // === 標籤系列 === //
  /// 大標籤 - 用於按鈕文字
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  /// 中標籤 - 用於小按鈕
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  /// 小標籤 - 用於標籤和徽章
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  // === 分帳功能專用樣式 === //
  /// 金額顯示 - 大金額
  static const TextStyle currencyLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.onSurface,
  );

  /// 金額顯示 - 中金額
  static const TextStyle currencyMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.onSurface,
  );

  /// 金額顯示 - 小金額
  static const TextStyle currencySmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.onSurface,
  );

  /// 收入金額 - 綠色
  static TextStyle get incomeAmount => currencyMedium.copyWith(
    color: AppColors.income,
  );

  /// 支出金額 - 紅色
  static TextStyle get expenseAmount => currencyMedium.copyWith(
    color: AppColors.expense,
  );

  /// 平衡金額 - 藍色
  static TextStyle get balancedAmount => currencyMedium.copyWith(
    color: AppColors.balanced,
  );

  /// 待結算金額 - 橙色
  static TextStyle get pendingAmount => currencyMedium.copyWith(
    color: AppColors.pending,
  );

  // === 特殊樣式 === //
  /// 按鈕文字 - 主要按鈕
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
    color: AppColors.onPrimary,
  );

  /// 按鈕文字 - 次要按鈕
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );

  /// 按鈕文字 - 文字按鈕
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );

  /// 導航欄文字
  static const TextStyle navigation = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.onSurfaceVariant,
  );

  /// 導航欄文字 - 選中狀態
  static const TextStyle navigationSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );

  /// 提示文字
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  /// 錯誤文字
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.error,
  );

  /// 成功文字
  static const TextStyle success = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.success,
  );

  /// 警告文字
  static const TextStyle warning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.warning,
  );

  /// 鏈接文字
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  /// 代碼文字 - 用於分享碼等
  static const TextStyle code = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 1.0,
    fontFamily: 'monospace',
    color: AppColors.onSurface,
  );

  // === 帶顏色變體的輔助方法 === //
  /// 獲取帶有指定顏色的樣式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 獲取帶有指定字重的樣式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// 獲取帶有指定大小的樣式
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// 獲取白色文字變體
  static TextStyle white(TextStyle style) {
    return style.copyWith(color: AppColors.white);
  }

  /// 獲取主色文字變體
  static TextStyle primary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// 獲取次要文字變體
  static TextStyle variant(TextStyle style) {
    return style.copyWith(color: AppColors.onSurfaceVariant);
  }
} 
