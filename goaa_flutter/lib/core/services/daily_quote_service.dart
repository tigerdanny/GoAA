import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/database_service.dart';

/// 每日金句服务类
class DailyQuoteService {
  static final DailyQuoteService _instance = DailyQuoteService._internal();
  factory DailyQuoteService() => _instance;
  DailyQuoteService._internal();

  late final AppDatabase _database;
  final Random _random = Random();

  /// 初始化服务
  Future<void> initialize() async {
    _database = DatabaseService.instance.database;
    await _initializeDefaultQuotes();
  }

  /// 获取每日金句（优先从网络获取，失败则从本地随机选择）
  Future<DailyQuote> getDailyQuote() async {
    try {
      // 尝试从网络获取
      final networkQuote = await _fetchQuoteFromNetwork();
      if (networkQuote != null) {
        // 保存到本地数据库
        await _saveQuoteToLocal(networkQuote);
        return networkQuote;
      }
    } catch (e) {
      debugPrint('网络获取金句失败: $e');
    }

    // 从本地数据库随机获取
    return await _getRandomQuoteFromLocal();
  }

  /// 从网络获取金句
  Future<DailyQuote?> _fetchQuoteFromNetwork() async {
    try {
      // 使用免费的金句API
      const apiUrl = 'https://api.quotable.io/random?minLength=50&maxLength=150';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final englishContent = data['content'] as String;
        final author = data['author'] as String;

        // 创建中英文版本（这里英文是原文，中文可以用简单的翻译或预设内容）
        final chineseContent = await _translateOrGetPreset(englishContent);

        return DailyQuote(
          id: 0, // 临时ID
          contentZh: chineseContent,
          contentEn: englishContent,
          author: author,
          category: 'network',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('网络请求失败: $e');
    }
    return null;
  }

  /// 翻译或获取预设中文内容
  Future<String> _translateOrGetPreset(String englishContent) async {
    // 这里可以集成翻译API，现在先用预设的中文金句
    final presetQuotes = [
      '成功不是终点，失败不是致命的，重要的是继续前进的勇气。',
      '生活不是等待暴风雨过去，而是学会在雨中起舞。',
      '每一个伟大的成就都始于决定去尝试。',
      '困难不会持续太久，但坚强的人会。',
      '相信自己，你比想象中更强大。',
      '今天的努力是明天成功的基石。',
      '梦想不会逃跑，逃跑的永远是你自己。',
      '每一次挫折都是成长的机会。',
      '保持积极的心态，好运自然会来。',
      '坚持下去，最好的还在后头。',
    ];
    
    return presetQuotes[_random.nextInt(presetQuotes.length)];
  }

  /// 保存金句到本地数据库
  Future<void> _saveQuoteToLocal(DailyQuote quote) async {
    try {
      await _database.into(_database.dailyQuotes).insert(
        DailyQuotesCompanion(
          contentZh: Value(quote.contentZh),
          contentEn: Value(quote.contentEn),
          author: Value(quote.author),
          category: Value(quote.category),
        ),
      );
    } catch (e) {
      debugPrint('保存金句到本地失败: $e');
    }
  }

  /// 从本地数据库随机获取金句
  Future<DailyQuote> _getRandomQuoteFromLocal() async {
    try {
      final quotes = await _database.select(_database.dailyQuotes).get();
      
      if (quotes.isNotEmpty) {
        final randomQuote = quotes[_random.nextInt(quotes.length)];
        return randomQuote;
      }
    } catch (e) {
      debugPrint('从本地获取金句失败: $e');
    }

    // 如果本地也没有，返回默认金句
    return DailyQuote(
      id: 0,
      contentZh: '每一天都是新的开始，充满无限可能。',
      contentEn: 'Every day is a new beginning full of infinite possibilities.',
      author: 'GOAA Team',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 初始化默认金句库
  Future<void> _initializeDefaultQuotes() async {
    try {
      // 检查是否已有数据
      final existingQuotes = await _database.select(_database.dailyQuotes).get();
      if (existingQuotes.isNotEmpty) return;

      // 预设金句库
      final defaultQuotes = [
        {
          'zh': '成功不是终点，失败不是致命的，重要的是继续前进的勇气。',
          'en': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
          'author': 'Winston Churchill',
        },
        {
          'zh': '生活不是等待暴风雨过去，而是学会在雨中起舞。',
          'en': 'Life is not about waiting for the storm to pass, but learning to dance in the rain.',
          'author': 'Vivian Greene',
        },
        {
          'zh': '每一个伟大的成就都始于决定去尝试。',
          'en': 'Every great achievement was once considered impossible.',
          'author': 'Unknown',
        },
        {
          'zh': '困难不会持续太久，但坚强的人会。',
          'en': 'Tough times never last, but tough people do.',
          'author': 'Robert H. Schuller',
        },
        {
          'zh': '相信自己，你比想象中更强大。',
          'en': 'Believe in yourself. You are braver than you think.',
          'author': 'A.A. Milne',
        },
        {
          'zh': '今天的努力是明天成功的基石。',
          'en': 'Today\'s effort is tomorrow\'s success.',
          'author': 'Unknown',
        },
        {
          'zh': '梦想不会逃跑，逃跑的永远是你自己。',
          'en': 'Dreams don\'t run away. It\'s you who runs away from them.',
          'author': 'Unknown',
        },
        {
          'zh': '每一次挫折都是成长的机会。',
          'en': 'Every setback is an opportunity to grow.',
          'author': 'Unknown',
        },
        {
          'zh': '保持积极的心态，好运自然会来。',
          'en': 'Stay positive, and good things will come.',
          'author': 'Unknown',
        },
        {
          'zh': '坚持下去，最好的还在后头。',
          'en': 'Keep going. The best is yet to come.',
          'author': 'Unknown',
        },
      ];

      // 批量插入默认金句
      for (final quote in defaultQuotes) {
        await _database.into(_database.dailyQuotes).insert(
          DailyQuotesCompanion(
            contentZh: Value(quote['zh']!),
            contentEn: Value(quote['en']!),
            author: Value(quote['author']!),
            category: const Value('preset'),
          ),
        );
      }

      debugPrint('默认金句库初始化完成，共 ${defaultQuotes.length} 条金句');
    } catch (e) {
      debugPrint('初始化默认金句库失败: $e');
    }
  }

  /// 获取指定语言的金句内容
  String getQuoteContent(DailyQuote quote, String languageCode) {
    return languageCode.startsWith('zh') ? quote.contentZh : quote.contentEn;
  }

  /// 清理旧的网络金句（保留最近30条）
  Future<void> cleanupOldQuotes() async {
    try {
      final allQuotes = await (_database.select(_database.dailyQuotes)
            ..where((q) => q.category.equals('network'))
            ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
          .get();

      if (allQuotes.length > 30) {
        final quotesToDelete = allQuotes.skip(30);
        for (final quote in quotesToDelete) {
          await (_database.delete(_database.dailyQuotes)
                ..where((q) => q.id.equals(quote.id)))
              .go();
        }
      }
    } catch (e) {
      debugPrint('清理旧金句失败: $e');
    }
  }
} 
