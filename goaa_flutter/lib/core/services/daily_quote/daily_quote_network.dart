import 'dart:async';
import 'dart:convert';
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

  /// 從網路獲取金句
  static Future<DailyQuoteModel?> fetchQuote() async {
    try {
      debugPrint('🌐 開始網路請求: $_apiUrl');
      final response = await http.get(
        Uri.parse(_apiUrl), 
        headers: {'Accept': 'application/json'}
      ).timeout(const Duration(seconds: 15)); // 增加超時時間到15秒
      
      debugPrint('🌐 網路回應狀態: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)[0];
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
      }
    } catch (e) {
      debugPrint('❌ 網路獲取異常: $e');
      if (e is TimeoutException) {
        debugPrint('⏰ 網路請求超時');
      }
    }
    return null;
  }
} 
