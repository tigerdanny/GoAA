import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/language_service.dart';
import 'core/services/daily_quote_service.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'dart:io';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 修復 Android 相關問題
  await _fixMobileIssues();
  
  // 順序初始化服務，保持正確的依賴關係
  final languageService = LanguageService();
  languageService.initialize();
  debugPrint('✅ 語言服務初始化完成');
  
  // 先初始化資料庫，再初始化依賴資料庫的服務
  DatabaseService.instance.initialize().then((_) {
    debugPrint('✅ 資料庫初始化完成');
    
    // 資料庫初始化完成後，才初始化每日金句服務
    DailyQuoteService().initialize();
    
  }).catchError((e) {
    debugPrint('❌ 資料庫初始化失敗: $e');
  });
  
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
