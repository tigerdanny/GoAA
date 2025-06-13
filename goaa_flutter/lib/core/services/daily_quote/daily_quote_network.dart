import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'daily_quote_translator.dart';
import '../../models/daily_quote.dart';

/// 每日金句網路服務
class DailyQuoteNetwork {
  static final DailyQuoteNetwork _instance = DailyQuoteNetwork._internal();
  factory DailyQuoteNetwork() => _instance;
  
  DailyQuoteNetwork._internal();

  static const String _apiUrl = 'https://zenquotes.io/api/random';
  static const String _testUrl = 'https://httpbin.org/get';

  /// 網路診斷
  static Future<Map<String, dynamic>> diagnoseNetwork() async {
    final results = <String, dynamic>{};
    
    debugPrint('🔍 開始網路診斷...');
    
    // 1. 檢查網路連接
    try {
      final result = await InternetAddress.lookup('google.com');
      results['dns_lookup'] = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      debugPrint('✅ DNS 查詢: ${results['dns_lookup']}');
    } catch (e) {
      results['dns_lookup'] = false;
      results['dns_error'] = e.toString();
      debugPrint('❌ DNS 查詢失敗: $e');
    }
    
    // 2. 測試HTTP連接
    try {
      final response = await http.get(Uri.parse(_testUrl))
          .timeout(const Duration(seconds: 10));
      results['http_test'] = response.statusCode == 200;
      results['http_status'] = response.statusCode;
      debugPrint('✅ HTTP 測試: ${response.statusCode}');
    } catch (e) {
      results['http_test'] = false;
      results['http_error'] = e.toString();
      debugPrint('❌ HTTP 測試失敗: $e');
    }
    
    // 3. 測試目標API
    try {
      final response = await http.head(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));
      results['api_reachable'] = response.statusCode < 400;
      results['api_status'] = response.statusCode;
      debugPrint('✅ API 可達性: ${response.statusCode}');
    } catch (e) {
      results['api_reachable'] = false;
      results['api_error'] = e.toString();
      debugPrint('❌ API 可達性測試失敗: $e');
    }
    
    // 4. 檢查用戶代理和頭部
    try {
      final headers = {
        'User-Agent': 'GOAA-Flutter-App/1.0 (Android)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      };
      
      final response = await http.get(
        Uri.parse(_testUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      results['headers_test'] = response.statusCode == 200;
      debugPrint('✅ 頭部測試: ${response.statusCode}');
    } catch (e) {
      results['headers_test'] = false;
      results['headers_error'] = e.toString();
      debugPrint('❌ 頭部測試失敗: $e');
    }
    
    return results;
  }

  /// 從網路獲取金句 - 增強版本
  static Future<DailyQuoteModel?> fetchQuote() async {
    try {
      debugPrint('🌐 開始網路請求: $_apiUrl');
      
      // 首先進行快速診斷
      final diagnosis = await diagnoseNetwork();
      debugPrint('📊 網路診斷結果: $diagnosis');
      
      if (!diagnosis['dns_lookup']) {
        debugPrint('❌ DNS查詢失敗，無法繼續');
        return null;
      }
      
      // 使用增強的請求頭
      final headers = {
        'User-Agent': 'GOAA-Flutter-App/1.0 (Android)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
      };
      
      debugPrint('📤 請求頭: $headers');
      
      final response = await http.get(
        Uri.parse(_apiUrl), 
        headers: headers
      ).timeout(const Duration(seconds: 20)); // 增加到20秒
      
      debugPrint('🌐 網路回應狀態: ${response.statusCode}');
      debugPrint('📥 回應頭: ${response.headers}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint('📄 回應內容長度: ${responseBody.length}');
        
        final data = json.decode(responseBody)[0];
        final englishContent = data['q'] as String;
        final author = data['a'] as String;
        
        debugPrint('✅ 網路獲取成功: $englishContent');
        
        return DailyQuoteModel(
          id: 0,
          contentZh: DailyQuoteTranslator.toChinese(englishContent),
          contentEn: englishContent,
          author: author,
          category: 'network',
          createdAt: DateTime.now(),
        );
      } else {
        debugPrint('❌ HTTP 狀態錯誤: ${response.statusCode}');
        debugPrint('📄 錯誤內容: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 網路獲取異常: $e');
      if (e is TimeoutException) {
        debugPrint('⏰ 網路請求超時 - 建議檢查網路連接或防火牆設置');
      } else if (e is SocketException) {
        debugPrint('🔌 網路連接異常 - 建議檢查網路設置');
      } else if (e is HttpException) {
        debugPrint('🌐 HTTP協議異常 - 建議檢查服務器狀態');
      } else {
        debugPrint('❓ 未知網路異常: ${e.runtimeType}');
      }
      
      // 進行詳細診斷
      final diagnosis = await diagnoseNetwork();
      debugPrint('🔍 詳細診斷: $diagnosis');
    }
    return null;
  }

  /// 測試網路連接
  static Future<bool> testConnection() async {
    try {
      final diagnosis = await diagnoseNetwork();
      return diagnosis['dns_lookup'] && diagnosis['http_test'];
    } catch (e) {
      debugPrint('❌ 連接測試失敗: $e');
      return false;
    }
  }
}
