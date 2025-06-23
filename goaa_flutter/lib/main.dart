import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/language_service.dart';
import 'core/services/daily_quote/daily_quote_repository.dart';
import 'core/utils/performance_monitor.dart';
import 'features/splash/splash_screen.dart';
import 'core/services/friend_request_service.dart';
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

  // 🎲 修復問題2：初始化隨機數種子
  _initializeRandomSeed();
  
  // 🚀 修復問題1：簡化主線程初始化，只做必要操作
  try {
    debugPrint('🚀 開始快速啟動模式...');
    
    // 1. 輕量級語言服務初始化（同步，快速）
    final languageService = LanguageService();
    languageService.initialize();
    debugPrint('✅ 語言服務初始化完成');
    PerformanceMonitor.recordTimestamp('語言服務完成');
    
    // 2. 設置基本UI樣式（同步，快速）
    _setupBasicUI();
    
    PerformanceMonitor.recordTimestamp('基本初始化完成');
    
    // 🚀 立即啟動應用，重型初始化移到後台
    runApp(GoAAApp(languageService: languageService));
    
    // 3. 在後台進行重型初始化（不阻塞UI顯示）
    _backgroundInitialization();
    
  } catch (e, stackTrace) {
    debugPrint('❌ 啟動過程出錯: $e');
    debugPrint('📚 錯誤堆疊: $stackTrace');
    
    // 即使出錯也要能啟動基本應用
    try {
      final languageService = LanguageService();
      languageService.initialize();
      runApp(GoAAApp(languageService: languageService));
    } catch (fallbackError) {
      debugPrint('❌ 後備啟動也失敗: $fallbackError');
      // 最後的後備方案 - 基本的錯誤顯示應用
      runApp(_createErrorApp());
    }
  }
}

/// 🎲 初始化隨機數種子
void _initializeRandomSeed() {
  final now = DateTime.now();
  final seed = now.microsecondsSinceEpoch;
  final random = Random(seed);
  debugPrint('🎲 隨機數種子初始化: $seed');
  // 進行一次測試以確保種子生效
  final testValue = random.nextInt(1000000);
  debugPrint('🎲 隨機數測試值: $testValue');
}

/// 🚀 設置基本UI樣式（快速，同步）
void _setupBasicUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  debugPrint('✅ 基本UI設置完成');
}

/// 🚀 後台重型初始化（不阻塞UI）
Future<void> _backgroundInitialization() async {
  debugPrint('🔄 開始後台初始化...');
  
  try {
    // 1. Android修復（可能耗時）
    await _fixMobileIssues();
    PerformanceMonitor.recordTimestamp('Android修復完成');
    
    // 2. 資料庫初始化（可能耗時）
    await DatabaseService.instance.initialize();
    debugPrint('✅ 資料庫初始化完成');
    PerformanceMonitor.recordTimestamp('資料庫初始化完成');
    
    // 3. 啟動全局好友請求監聽（獨立且隨時監聽）
    final friendRequestService = FriendRequestService();
    await friendRequestService.startService();
    PerformanceMonitor.recordTimestamp('好友請求監聽啟動完成');
    
    // 4. 每日金句服務（可選，失敗不影響）
    final quoteRepository = DailyQuoteRepository();
    unawaited(quoteRepository.initialize().catchError((e) {
      debugPrint('⚠️ 金句服務初始化失敗（非關鍵）: $e');
    }));
    
    PerformanceMonitor.recordTimestamp('後台初始化完成');
    debugPrint('✅ 後台初始化全部完成');
    
  } catch (e, stackTrace) {
    debugPrint('❌ 後台初始化失敗: $e');
    debugPrint('📚 錯誤堆疊: $stackTrace');
    // 後台初始化失敗不應該影響應用運行
  }
}

/// 🚀 創建錯誤應用（最後的後備方案）
Widget _createErrorApp() {
  return MaterialApp(
    title: 'GOAA',
    home: Scaffold(
      body: Container(
        color: Colors.red.shade50,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                '應用啟動遇到問題',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('請重新啟動應用或聯繫支援'),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 修復手機端問題（移到後台）
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

/// 輔助函數：延遲執行而不等待
void unawaited(Future<void> future) {
  // 故意不等待這個Future
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
            
            // 🚀 使用快速啟動的SplashScreen
            home: const SplashScreen(),
            
            // 路由配置
            routes: {
              '/splash': (context) => const SplashScreen(),
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
