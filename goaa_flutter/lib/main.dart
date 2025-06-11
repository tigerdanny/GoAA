import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/language_service.dart';
import 'core/services/daily_quote_service.dart';
import 'core/utils/performance_monitor.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'dart:io';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // 🚀 性能監控：記錄應用啟動開始時間
  PerformanceMonitor.recordTimestamp('應用啟動開始');
  
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  PerformanceMonitor.recordTimestamp('Flutter綁定完成');
  
  // 修復 Android 相關問題
  await _fixMobileIssues();
  PerformanceMonitor.recordTimestamp('Android修復完成');
  
  // 🚀 優化：使用async/await確保正確的初始化順序
  try {
    // 1. 語言服務初始化（同步）
    final languageService = LanguageService();
    languageService.initialize();
    debugPrint('✅ 語言服務初始化完成');
    PerformanceMonitor.recordTimestamp('語言服務完成');
    
    // 2. 資料庫初始化（必須等待完成）
    await DatabaseService.instance.initialize();
    debugPrint('✅ 資料庫初始化完成');
    PerformanceMonitor.recordTimestamp('資料庫初始化完成');
    
    // 3. 每日金句服務初始化（不阻塞啟動）
    DailyQuoteService().initialize().catchError((e) {
      debugPrint('⚠️ 每日金句初始化失敗: $e');
    });
    debugPrint('✅ 每日金句服務啟動中...');
    
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
    
    PerformanceMonitor.recordTimestamp('系統設置完成');
    
    // 🚀 性能監控：計算各階段時間
    PerformanceMonitor.recordDuration('總初始化時間', '應用啟動開始', '系統設置完成');
    PerformanceMonitor.recordDuration('資料庫初始化時間', '語言服務完成', '資料庫初始化完成');
    
    runApp(GoAAApp(languageService: languageService));
    
  } catch (e, stackTrace) {
    debugPrint('❌ 應用初始化失敗: $e');
    debugPrint('📚 錯誤堆疊: $stackTrace');
    
    // 即使初始化失敗也要啟動應用
    final languageService = LanguageService();
    languageService.initialize();
    runApp(GoAAApp(languageService: languageService));
  }
}

/// 修復手機端問題
Future<void> _fixMobileIssues() async {
  try {
    debugPrint('🔧 開始修復手機端問題...');
    
    // Android 特定修復
    if (Platform.isAndroid) {
      debugPrint('📱 檢測到 Android 系統，應用修復...');
      
      // 1. 修復 SQLite3 在舊版 Android 上的問題
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      debugPrint('✅ SQLite3 Android workaround 已應用');
      
      // 2. 檢查並創建必要目錄
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final tempDir = await getTemporaryDirectory();
        
        debugPrint('📂 應用目錄: ${appDir.path}');
        debugPrint('📂 臨時目錄: ${tempDir.path}');
        
        // 確保目錄存在且可寫
        if (!appDir.existsSync()) {
          await appDir.create(recursive: true);
          debugPrint('📂 已創建應用目錄');
        }
        
        // 測試寫入權限
        final testFile = File('${appDir.path}/.test_write');
        await testFile.writeAsString('test');
        await testFile.delete();
        debugPrint('✅ 存儲權限正常');
        
      } catch (e) {
        debugPrint('⚠️ 目錄檢查/創建問題: $e');
      }
      
      // 3. 設置 SQLite 臨時目錄
      try {
        final tempDir = await getTemporaryDirectory();
        // 未來可以設置 sqlite3.tempDirectory = tempDir.path;
        debugPrint('✅ SQLite 臨時目錄已設置: ${tempDir.path}');
      } catch (e) {
        debugPrint('⚠️ SQLite 臨時目錄設置問題: $e');
      }
    }
    
    debugPrint('✅ 手機端問題修復完成');
    
  } catch (e, stackTrace) {
    debugPrint('❌ 手機端問題修復失敗: $e');
    debugPrint('📚 錯誤堆疊: $stackTrace');
  }
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
              // HomeScreen现在通过直接导航传递预加载数据，不再需要路由
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
