import 'dart:async';
import 'dart:convert';
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
      final response = await http.get(Uri.parse(_apiUrl), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)[0];
        final englishContent = data['q'] as String;
        return DailyQuoteModel(
          id: 0,
          contentZh: DailyQuoteTranslator.toChinese(englishContent),
          contentEn: englishContent,
          author: data['a'] as String,
          category: 'network',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      // 可加日誌
    }
    return null;
  }
} 
