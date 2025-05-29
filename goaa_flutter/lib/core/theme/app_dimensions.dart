import 'package:flutter/material.dart';

/// GoAA應用的尺寸規範系統
/// 基於8pt網格系統，提供一致的間距和尺寸規範
class AppDimensions {
  // 私有構造函數，防止實例化
  AppDimensions._();

  // === 間距系統 (8pt grid) === //
  /// 超小間距 - 2px
  static const double space2 = 2.0;
  
  /// 小間距 - 4px
  static const double space4 = 4.0;
  
  /// 基礎間距 - 8px
  static const double space8 = 8.0;
  
  /// 中間距 - 12px
  static const double space12 = 12.0;
  
  /// 標準間距 - 16px
  static const double space16 = 16.0;
  
  /// 大間距 - 20px
  static const double space20 = 20.0;
  
  /// 大間距 - 24px
  static const double space24 = 24.0;
  
  /// 特大間距 - 32px
  static const double space32 = 32.0;
  
  /// 超大間距 - 40px
  static const double space40 = 40.0;
  
  /// 巨大間距 - 48px
  static const double space48 = 48.0;
  
  /// 超巨大間距 - 64px
  static const double space64 = 64.0;

  // === 內邊距 (Padding) === //
  /// 最小內邊距
  static const EdgeInsets paddingXS = EdgeInsets.all(space4);
  
  /// 小內邊距
  static const EdgeInsets paddingS = EdgeInsets.all(space8);
  
  /// 中等內邊距
  static const EdgeInsets paddingM = EdgeInsets.all(space16);
  
  /// 大內邊距
  static const EdgeInsets paddingL = EdgeInsets.all(space24);
  
  /// 特大內邊距
  static const EdgeInsets paddingXL = EdgeInsets.all(space32);

  /// 水平內邊距 - 小
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: space8);
  
  /// 水平內邊距 - 中
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: space16);
  
  /// 水平內邊距 - 大
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: space24);

  /// 垂直內邊距 - 小
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: space8);
  
  /// 垂直內邊距 - 中
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: space16);
  
  /// 垂直內邊距 - 大
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: space24);

  /// 頁面內邊距 - 標準頁面邊距
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space24,
  );

  /// 卡片內邊距
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);

  /// 列表項內邊距
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  // === 外邊距 (Margin) === //
  /// 最小外邊距
  static const EdgeInsets marginXS = EdgeInsets.all(space4);
  
  /// 小外邊距
  static const EdgeInsets marginS = EdgeInsets.all(space8);
  
  /// 中等外邊距
  static const EdgeInsets marginM = EdgeInsets.all(space16);
  
  /// 大外邊距
  static const EdgeInsets marginL = EdgeInsets.all(space24);
  
  /// 特大外邊距
  static const EdgeInsets marginXL = EdgeInsets.all(space32);

  // === 圓角系統 === //
  /// 無圓角
  static const double radiusNone = 0.0;
  
  /// 超小圓角
  static const double radiusXS = 2.0;
  
  /// 小圓角
  static const double radiusS = 4.0;
  
  /// 中等圓角
  static const double radiusM = 8.0;
  
  /// 大圓角
  static const double radiusL = 12.0;
  
  /// 特大圓角
  static const double radiusXL = 16.0;
  
  /// 超大圓角
  static const double radiusXXL = 24.0;
  
  /// 圓形
  static const double radiusCircle = 1000.0;

  /// BorderRadius - 小
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(radiusS));
  
  /// BorderRadius - 中
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(radiusM));
  
  /// BorderRadius - 大
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(radiusL));
  
  /// BorderRadius - 特大
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));

  // === 邊框寬度 === //
  /// 無邊框
  static const double borderNone = 0.0;
  
  /// 細邊框
  static const double borderThin = 1.0;
  
  /// 中等邊框
  static const double borderMedium = 2.0;
  
  /// 粗邊框
  static const double borderThick = 3.0;

  // === 陰影系統 === //
  /// 無陰影
  static const List<BoxShadow> shadowNone = [];

  /// 輕微陰影 - 用於懸浮按鈕
  static const List<BoxShadow> shadowS = [
    BoxShadow(
      color: Color(0x14000000), // AppColors.shadowLight
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// 小陰影 - 用於卡片
  static const List<BoxShadow> shadowM = [
    BoxShadow(
      color: Color(0x14000000), // AppColors.shadowLight
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// 中等陰影 - 用於提升的元素
  static const List<BoxShadow> shadowL = [
    BoxShadow(
      color: Color(0x29000000), // AppColors.shadowMedium
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// 大陰影 - 用於對話框
  static const List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Color(0x29000000), // AppColors.shadowMedium
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// 超大陰影 - 用於底部表單
  static const List<BoxShadow> shadowXXL = [
    BoxShadow(
      color: Color(0x3D000000), // AppColors.shadowDark
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // === 特定組件尺寸 === //
  /// 按鈕高度 - 小
  static const double buttonHeightS = 32.0;
  
  /// 按鈕高度 - 中
  static const double buttonHeightM = 40.0;
  
  /// 按鈕高度 - 大
  static const double buttonHeightL = 48.0;
  
  /// 按鈕高度 - 特大
  static const double buttonHeightXL = 56.0;

  /// 輸入框高度
  static const double inputHeight = 48.0;
  
  /// 輸入框最小高度
  static const double inputMinHeight = 40.0;

  /// 應用欄高度
  static const double appBarHeight = 56.0;
  
  /// 標籤欄高度
  static const double tabBarHeight = 48.0;
  
  /// 底部導航欄高度
  static const double bottomNavHeight = 80.0;

  /// 頭像尺寸 - 小
  static const double avatarS = 32.0;
  
  /// 頭像尺寸 - 中
  static const double avatarM = 48.0;
  
  /// 頭像尺寸 - 大
  static const double avatarL = 64.0;
  
  /// 頭像尺寸 - 特大
  static const double avatarXL = 96.0;

  /// 圖標尺寸 - 小
  static const double iconS = 16.0;
  
  /// 圖標尺寸 - 中
  static const double iconM = 24.0;
  
  /// 圖標尺寸 - 大
  static const double iconL = 32.0;
  
  /// 圖標尺寸 - 特大
  static const double iconXL = 48.0;

  /// 列表項高度 - 小
  static const double listItemHeightS = 48.0;
  
  /// 列表項高度 - 中
  static const double listItemHeightM = 56.0;
  
  /// 列表項高度 - 大
  static const double listItemHeightL = 72.0;

  /// 卡片最小高度
  static const double cardMinHeight = 80.0;
  
  /// 對話框最小寬度
  static const double dialogMinWidth = 280.0;
  
  /// 對話框最大寬度
  static const double dialogMaxWidth = 560.0;

  // === 響應式斷點 === //
  /// 手機斷點
  static const double breakpointMobile = 600.0;
  
  /// 平板斷點
  static const double breakpointTablet = 900.0;
  
  /// 桌面斷點
  static const double breakpointDesktop = 1200.0;

  // === 分帳功能專用尺寸 === //
  /// 金額顯示區域高度
  static const double amountDisplayHeight = 120.0;
  
  /// 計算器按鈕尺寸
  static const double calculatorButtonSize = 64.0;
  
  /// 分帳項目高度
  static const double expenseItemHeight = 80.0;
  
  /// 群組卡片高度
  static const double groupCardHeight = 120.0;
  
  /// 結算卡片高度
  static const double settlementCardHeight = 100.0;

  // === 動畫尺寸 === //
  /// 滑動閾值
  static const double swipeThreshold = 100.0;
  
  /// 拖拽阻力係數
  static const double dragResistance = 0.7;
} 
