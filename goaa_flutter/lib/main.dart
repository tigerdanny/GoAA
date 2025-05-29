import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  runApp(const GoAAApp());
}

/// GoAA分帳應用主類
class GoAAApp extends StatelessWidget {
  const GoAAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 應用資訊
      title: 'GoAA分帳神器',
      debugShowCheckedModeBanner: false,
      
      // 主題配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // 本地化配置
      locale: const Locale('en', 'US'), // 改為英文避免測試問題
      supportedLocales: const [
        Locale('en', 'US'), // 英文
        Locale('zh', 'TW'), // 繁體中文
        Locale('zh', 'CN'), // 簡體中文
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // 初始路由
      home: const SplashScreen(),
      
      // 路由配置（暫時使用簡單路由，後續會改用 go_router）
      routes: {
        '/splash': (context) => const SplashScreen(),
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
  }
}
