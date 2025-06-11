import 'dart:io';
import 'goaa_flutter/lib/core/services/daily_quote_service.dart';
import 'goaa_flutter/lib/core/database/database_service.dart';

void main() async {
  print('🧪 開始網路修復測試...');
  
  try {
    // 初始化資料庫服務
    print('📚 初始化資料庫服務...');
    await DatabaseService.instance.initialize();
    
    // 初始化每日金句服務
    print('🚀 初始化每日金句服務...');
    final quoteService = DailyQuoteService();
    await quoteService.initialize();
    
    // 顯示當前狀態
    print('📊 服務狀態:');
    final status = quoteService.getServiceStatus();
    status.forEach((key, value) {
      print('  $key: $value');
    });
    
    // 強制網路測試
    print('\n🧪 執行強制網路測試...');
    final networkTest = await quoteService.forceNetworkTest();
    
    print('📋 測試結果:');
    networkTest.forEach((key, value) {
      if (key == 'tests') {
        print('  測試項目:');
        for (final test in value) {
          print('    - ${test['test']}: ${test['result']} (${test['message']})');
          if (test.containsKey('error')) {
            print('      錯誤: ${test['error']}');
          }
        }
      } else {
        print('  $key: $value');
      }
    });
    
    // 嘗試獲取金句
    print('\n📝 嘗試獲取金句...');
    final quote = await quoteService.getDailyQuote();
    print('✅ 成功獲取金句: ${quote.contentZh}');
    print('🏷️  分類: ${quote.category}');
    print('👤 作者: ${quote.author}');
    
    // 運行診斷
    print('\n🔍 運行網路診斷...');
    final diagnosis = await quoteService.diagnoseNetworkPermissions();
    print('📊 診斷摘要: ${diagnosis['summary']}');
    
  } catch (e, stackTrace) {
    print('❌ 測試失敗: $e');
    print('📋 堆疊跟蹤: $stackTrace');
  } finally {
    print('\n🔚 測試完成');
    exit(0);
  }
} 
