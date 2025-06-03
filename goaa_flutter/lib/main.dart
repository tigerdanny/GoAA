import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/language_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化語言服務
  final languageService = LanguageService();
  await languageService.initialize();
  
  // 初始化資料庫
  try {
    await DatabaseService.instance.initialize();
    debugPrint('資料庫初始化成功');
  } catch (e) {
    debugPrint('資料庫初始化失敗: $e');
  }
  
  // 設置系統UI樣式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 設置偏好的螢幕方向（僅豎屏）
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(GoAAApp(languageService: languageService));
}

/// GOAA分帳應用主類
class GoAAApp extends StatelessWidget {
  final LanguageService languageService;
  
  const GoAAApp({
    super.key,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>.value(
      value: languageService,
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            // 應用資訊
            title: 'GOAA分帳神器',
            debugShowCheckedModeBanner: false,
            
            // 主題配置
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            
            // 本地化配置
            locale: languageService.currentLocale,
            supportedLocales: LanguageService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // 使用SplashScreen作為初始頁面
            home: const SplashScreen(),
            
            // 路由配置（暫時使用簡單路由，後續會改用 go_router）
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              // 後續添加其他路由
            },
            
            // Material App 配置
            builder: (context, child) {
              return MediaQuery(
                // 禁用系統字體縮放，確保UI一致性
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
