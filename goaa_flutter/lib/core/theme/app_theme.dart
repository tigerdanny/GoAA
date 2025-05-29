import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// GoAA應用的主題配置
/// 整合所有設計系統元素
class AppTheme {
  // 私有構造函數，防止實例化
  AppTheme._();

  /// 亮色主題
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dialogTheme: _dialogTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      navigationBarTheme: _navigationBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      listTileTheme: _listTileTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme,
      tabBarTheme: _tabBarTheme,
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  /// 深色主題
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationThemeDark,
      cardTheme: _cardThemeDark,
      dialogTheme: _dialogThemeDark,
      bottomNavigationBarTheme: _bottomNavigationBarThemeDark,
      navigationBarTheme: _navigationBarThemeDark,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      chipTheme: _chipThemeDark,
      dividerTheme: _dividerThemeDark,
      listTileTheme: _listTileThemeDark,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      sliderTheme: _sliderTheme,
      tabBarTheme: _tabBarThemeDark,
      bottomSheetTheme: _bottomSheetThemeDark,
      snackBarTheme: _snackBarThemeDark,
    );
  }

  // === 顏色方案 === //
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.info,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.onSurface,
    onBackground: AppColors.onSurface,
    onError: AppColors.onError,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.info,
    surface: AppColors.surfaceDark,
    background: Color(0xFF0A0A0A),
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.white,
    onBackground: AppColors.white,
    onError: AppColors.onError,
    outline: AppColors.neutral600,
    outlineVariant: AppColors.neutral700,
    surfaceVariant: AppColors.neutral800,
    onSurfaceVariant: AppColors.neutral300,
  );

  // === 文字主題 === //
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.h1,
    displayMedium: AppTextStyles.h2,
    displaySmall: AppTextStyles.h3,
    headlineLarge: AppTextStyles.h3,
    headlineMedium: AppTextStyles.h4,
    headlineSmall: AppTextStyles.h5,
    titleLarge: AppTextStyles.h4,
    titleMedium: AppTextStyles.h5,
    titleSmall: AppTextStyles.h6,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  // === AppBar主題 === //
  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: AppTextStyles.h5,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    toolbarHeight: AppDimensions.appBarHeight,
  );

  static const AppBarTheme _appBarThemeDark = AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    toolbarHeight: AppDimensions.appBarHeight,
  );

  // === 按鈕主題 === //
  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
      minimumSize: const Size(double.infinity, AppDimensions.buttonHeightL),
      textStyle: AppTextStyles.buttonPrimary,
      padding: AppDimensions.paddingHorizontalM,
    ),
  );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTextStyles.buttonText,
      minimumSize: const Size(0, AppDimensions.buttonHeightM),
      padding: AppDimensions.paddingHorizontalM,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
    ),
  );

  static OutlinedButtonThemeData get _outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: AppDimensions.borderThin),
      textStyle: AppTextStyles.buttonSecondary,
      minimumSize: const Size(double.infinity, AppDimensions.buttonHeightL),
      padding: AppDimensions.paddingHorizontalM,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
    ),
  );

  // === 輸入框主題 === //
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.primary, width: AppDimensions.borderMedium),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: AppDimensions.paddingM,
    hintStyle: AppTextStyles.hint,
    labelStyle: AppTextStyles.labelLarge,
    errorStyle: AppTextStyles.error,
  );

  static InputDecorationTheme get _inputDecorationThemeDark => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.neutral800,
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.neutral600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.neutral600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.primary, width: AppDimensions.borderMedium),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: AppDimensions.paddingM,
    hintStyle: const TextStyle(color: AppColors.neutral400),
    labelStyle: const TextStyle(color: AppColors.neutral300),
    errorStyle: AppTextStyles.error,
  );

  // === 卡片主題 === //
  static const CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusL,
    ),
    margin: AppDimensions.marginS,
  );

  static const CardThemeData _cardThemeDark = CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusL,
    ),
    margin: AppDimensions.marginS,
  );

  // === 對話框主題 === //
  static const DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusXL,
    ),
    titleTextStyle: AppTextStyles.h4,
    contentTextStyle: AppTextStyles.bodyMedium,
  );

  static const DialogThemeData _dialogThemeDark = DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusXL,
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: AppColors.neutral300,
    ),
  );

  // === 其他組件主題 === //
  static const BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarThemeDark = BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.neutral400,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static NavigationBarThemeData get _navigationBarTheme => NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryWithOpacity20,
    labelTextStyle: MaterialStatePropertyAll(AppTextStyles.navigation),
    iconTheme: const MaterialStatePropertyAll(
      IconThemeData(color: AppColors.onSurfaceVariant, size: AppDimensions.iconM),
    ),
  );

  static NavigationBarThemeData get _navigationBarThemeDark => NavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: AppColors.primaryWithOpacity20,
    labelTextStyle: const MaterialStatePropertyAll(
      TextStyle(fontSize: 14, color: AppColors.neutral400),
    ),
    iconTheme: const MaterialStatePropertyAll(
      IconThemeData(color: AppColors.neutral400, size: AppDimensions.iconM),
    ),
  );

  static const FloatingActionButtonThemeData _floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 6,
    shape: CircleBorder(),
  );

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    labelStyle: AppTextStyles.labelMedium,
    shape: StadiumBorder(),
    side: BorderSide(color: AppColors.outline),
  );

  static const ChipThemeData _chipThemeDark = ChipThemeData(
    backgroundColor: AppColors.neutral800,
    labelStyle: TextStyle(fontSize: 12, color: AppColors.neutral300),
    shape: StadiumBorder(),
    side: BorderSide(color: AppColors.neutral600),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: AppDimensions.borderThin,
    space: AppDimensions.space16,
  );

  static const DividerThemeData _dividerThemeDark = DividerThemeData(
    color: AppColors.neutral700,
    thickness: AppDimensions.borderThin,
    space: AppDimensions.space16,
  );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: AppDimensions.paddingListItem,
    minVerticalPadding: AppDimensions.space8,
    style: ListTileStyle.list,
    titleTextStyle: AppTextStyles.bodyLarge,
    subtitleTextStyle: AppTextStyles.bodySmall,
  );

  static const ListTileThemeData _listTileThemeDark = ListTileThemeData(
    contentPadding: AppDimensions.paddingListItem,
    minVerticalPadding: AppDimensions.space8,
    style: ListTileStyle.list,
    titleTextStyle: TextStyle(fontSize: 16, color: AppColors.white),
    subtitleTextStyle: TextStyle(fontSize: 12, color: AppColors.neutral400),
  );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return AppColors.primary;
      return AppColors.neutral400;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return AppColors.primaryWithOpacity20;
      return AppColors.neutral200;
    }),
  );

  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return AppColors.primary;
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(AppColors.onPrimary),
    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusS),
  );

  static RadioThemeData get _radioTheme => RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return AppColors.primary;
      return AppColors.neutral400;
    }),
  );

  static SliderThemeData get _sliderTheme => SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.neutral200,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primaryWithOpacity20,
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.onPrimary),
  );

  static const TabBarThemeData _tabBarTheme = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    indicatorColor: AppColors.primary,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
  );

  static const TabBarThemeData _tabBarThemeDark = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.neutral400,
    indicatorColor: AppColors.primary,
    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXL),
      ),
    ),
    elevation: 8,
    modalElevation: 16,
  );

  static const BottomSheetThemeData _bottomSheetThemeDark = BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXL),
      ),
    ),
    elevation: 8,
    modalElevation: 16,
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.neutral800,
    contentTextStyle: TextStyle(color: AppColors.white),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusM,
    ),
  );

  static const SnackBarThemeData _snackBarThemeDark = SnackBarThemeData(
    backgroundColor: AppColors.neutral200,
    contentTextStyle: TextStyle(color: AppColors.black),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusM,
    ),
  );
} 
