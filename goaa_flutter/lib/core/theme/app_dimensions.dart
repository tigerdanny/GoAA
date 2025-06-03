import 'package:flutter/material.dart';

/// GOAA設計系統尺寸規範
/// 基於8pt網格系統，確保設計一致性與可擴展性
class AppDimensions {
  // 私有構造函數，防止實例化
  AppDimensions._();

  // === 基礎間距 (8pt grid) === //
  /// 最小間距 - 2px
  static const double space2 = 2.0;
  
  /// 微小間距 - 4px
  static const double space4 = 4.0;
  
  /// 小間距 - 8px
  static const double space8 = 8.0;
  
  /// 中小間距 - 12px
  static const double space12 = 12.0;
  
  /// 標準間距 - 16px
  static const double space16 = 16.0;
  
  /// 中間距 - 20px
  static const double space20 = 20.0;
  
  /// 大間距 - 24px
  static const double space24 = 24.0;
  
  /// 較大間距 - 32px
  static const double space32 = 32.0;
  
  /// 大型間距 - 40px
  static const double space40 = 40.0;
  
  /// 超大間距 - 48px
  static const double space48 = 48.0;
  
  /// 巨大間距 - 64px
  static const double space64 = 64.0;

  // === 內邊距 (Padding) === //
  /// 極小內邊距
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

  /// 頁面內邊距 - 水平中垂直大
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
  /// 極小外邊距
  static const EdgeInsets marginXS = EdgeInsets.all(space4);
  
  /// 小外邊距
  static const EdgeInsets marginS = EdgeInsets.all(space8);
  
  /// 中等外邊距
  static const EdgeInsets marginM = EdgeInsets.all(space16);
  
  /// 大外邊距
  static const EdgeInsets marginL = EdgeInsets.all(space24);
  
  /// 特大外邊距
  static const EdgeInsets marginXL = EdgeInsets.all(space32);

  // === 圓角半徑 === //
  /// 無圓角
  static const double radiusNone = 0.0;
  
  /// 極小圓角
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

  // === 陰影樣式 === //
  /// 無陰影
  static const List<BoxShadow> shadowNone = [];

  /// 輕微陰影 - 用於按鈕等
  static const List<BoxShadow> shadowS = [
    BoxShadow(
      color: Color(0x14000000), // AppColors.shadowLight
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// 中等陰影 - 用於卡片
  static const List<BoxShadow> shadowM = [
    BoxShadow(
      color: Color(0x14000000), // AppColors.shadowLight
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// 明顯陰影 - 用於彈出元素等
  static const List<BoxShadow> shadowL = [
    BoxShadow(
      color: Color(0x29000000), // AppColors.shadowMedium
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// 大陰影 - 用於重要組件
  static const List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Color(0x29000000), // AppColors.shadowMedium
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// 超大陰影 - 用於頂層對話框
  static const List<BoxShadow> shadowXXL = [
    BoxShadow(
      color: Color(0x3D000000), // AppColors.shadowDark
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // === 組件尺寸 === //
  /// 按鈕高度
  static const double buttonHeight = 48.0;
  
  /// 按鈕最小寬度
  static const double buttonMinWidth = 88.0;
  
  /// 輸入框高度
  static const double inputHeight = 48.0;
  
  /// 應用欄高度
  static const double appBarHeight = 56.0;
  
  /// 標籤欄高度
  static const double tabBarHeight = 48.0;
  
  /// 底部導航欄高度
  static const double bottomNavHeight = 56.0;
  
  /// 浮動按鈕大小
  static const double fabSize = 56.0;
  
  /// 頭像大小 - 小
  static const double avatarS = 32.0;
  
  /// 頭像大小 - 中
  static const double avatarM = 48.0;
  
  /// 頭像大小 - 大
  static const double avatarL = 64.0;
  
  /// 頭像大小 - 特大
  static const double avatarXL = 96.0;

  // === 圖標尺寸 === //
  /// 小圖標
  static const double iconS = 16.0;
  
  /// 標準圖標
  static const double iconM = 24.0;
  
  /// 大圖標
  static const double iconL = 32.0;
  
  /// 特大圖標
  static const double iconXL = 48.0;

  // === 響應式斷點 === //
  /// 手機螢幕最大寬度
  static const double mobileMaxWidth = 480.0;
  
  /// 平板螢幕最大寬度
  static const double tabletMaxWidth = 768.0;
  
  /// 桌面螢幕最小寬度
  static const double desktopMinWidth = 769.0;

  // === 動畫時長 === //
  /// 快速動畫 - 100ms
  static const Duration animationFast = Duration(milliseconds: 100);
  
  /// 標準動畫 - 200ms
  static const Duration animationNormal = Duration(milliseconds: 200);
  
  /// 緩慢動畫 - 300ms
  static const Duration animationSlow = Duration(milliseconds: 300);
  
  /// 頁面轉場動畫 - 400ms
  static const Duration animationPageTransition = Duration(milliseconds: 400);

  // === 實用方法 === //
  /// 根據螢幕寬度判斷是否為手機
  static bool isMobile(double width) => width <= mobileMaxWidth;
  
  /// 根據螢幕寬度判斷是否為平板
  static bool isTablet(double width) => width > mobileMaxWidth && width <= tabletMaxWidth;
  
  /// 根據螢幕寬度判斷是否為桌面
  static bool isDesktop(double width) => width > tabletMaxWidth;
  
  /// 根據螢幕寬度獲取水平邊距
  static double getHorizontalPadding(double width) {
    if (isMobile(width)) return space16;
    if (isTablet(width)) return space24;
    return space32;
  }
  
  /// 根據螢幕寬度獲取內容最大寬度
  static double getContentMaxWidth(double width) {
    if (isMobile(width)) return width;
    if (isTablet(width)) return width * 0.8;
    return 1200.0; // 桌面版內容最大寬度
  }
} 
