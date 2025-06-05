import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/database_service.dart';

/// 每日金句服務類
class DailyQuoteService {
  static final DailyQuoteService _instance = DailyQuoteService._internal();
  factory DailyQuoteService() => _instance;
  DailyQuoteService._internal();

  late final AppDatabase _database;
  final Random _random = Random();

  /// 預設的繁體中文金句（當無法上網且資料庫為空時使用）
  static const String defaultChineseQuote = '每一天都是新的開始，充滿無限可能。';
  static const String defaultEnglishQuote = 'Every day is a new beginning full of infinite possibilities.';
  
  /// 資料庫最大金句容量
  static const int maxQuotesInDatabase = 100;

  /// 初始化服務
  Future<void> initialize() async {
    _database = DatabaseService.instance.database;
    await _initializeDefaultQuotes();
  }

  /// 獲取每日金句（每日只獲取一次，優先從網路獲取）
  Future<DailyQuote> getDailyQuote() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    // 檢查今日是否已獲取過金句
    final todayQuote = await _getTodayQuoteFromLocal(todayStart);
    if (todayQuote != null) {
      debugPrint('📖 使用今日已獲取的金句: ${todayQuote.contentZh.substring(0, 20)}...');
      return todayQuote;
    }

    try {
      // 嘗試從網路獲取今日新金句
      final networkQuote = await _fetchQuoteFromNetwork();
      if (networkQuote != null) {
        // 標記為今日獲取的金句
        final todayQuoteData = DailyQuote(
          id: 0,
          contentZh: networkQuote.contentZh,
          contentEn: networkQuote.contentEn,
          author: networkQuote.author,
          category: 'daily_${todayStart.millisecondsSinceEpoch}',
          createdAt: todayStart,
        );
        
        await _saveQuoteToLocal(todayQuoteData);
        await _maintainDatabaseSize();
        debugPrint('🌐 從網路獲取今日金句: ${networkQuote.contentZh.substring(0, 20)}...');
        return todayQuoteData;
      }
    } catch (e) {
      debugPrint('❌ 網路獲取金句失敗: $e');
    }

    // 網路獲取失敗，從本地資料庫隨機選取
    final localQuote = await _getRandomQuoteFromLocal();
    debugPrint('📚 從本地資料庫獲取金句: ${localQuote.contentZh.substring(0, 20)}...');
    return localQuote;
  }

  /// 檢查今日是否已有金句
  Future<DailyQuote?> _getTodayQuoteFromLocal(DateTime todayStart) async {
    try {
      final todayCategory = 'daily_${todayStart.millisecondsSinceEpoch}';
      final quote = await (_database.select(_database.dailyQuotes)
            ..where((q) => q.category.equals(todayCategory)))
          .getSingleOrNull();
      return quote;
    } catch (e) {
      debugPrint('查詢今日金句失敗: $e');
      return null;
    }
  }

  /// 從網路獲取金句
  Future<DailyQuote?> _fetchQuoteFromNetwork() async {
    try {
      // 使用免費的金句API
      const apiUrl = 'https://api.quotable.io/random?minLength=30&maxLength=120';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final englishContent = data['content'] as String;
        final author = data['author'] as String;

        // 獲取繁體中文翻譯（使用預設的繁體中文金句）
        final chineseContent = await _getChineseTranslation(englishContent);

        return DailyQuote(
          id: 0, // 臨時ID
          contentZh: chineseContent,
          contentEn: englishContent,
          author: author,
          category: 'network',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('網路請求失敗: $e');
    }
    return null;
  }

  /// 獲取繁體中文翻譯（使用預設繁體中文金句庫）
  Future<String> _getChineseTranslation(String englishContent) async {
    // 預設繁體中文金句庫
    final traditionalChineseQuotes = [
      '成功不是終點，失敗不是致命的，重要的是繼續前進的勇氣。',
      '生活不是等待暴風雨過去，而是學會在雨中起舞。',
      '每一個偉大的成就都始於決定去嘗試。',
      '困難不會持續太久，但堅強的人會。',
      '相信自己，你比想像中更強大。',
      '今天的努力是明天成功的基石。',
      '夢想不會逃跑，逃跑的永遠是你自己。',
      '每一次挫折都是成長的機會。',
      '保持積極的心態，好運自然會來。',
      '堅持下去，最好的還在後頭。',
      '勇敢不是沒有恐懼，而是面對恐懼依然前行。',
      '智慧不在於知道答案，而在於問對問題。',
      '改變從接受現實開始，成長從走出舒適圈開始。',
      '機會總是留給有準備的人。',
      '幸福不是擁有的多，而是計較的少。',
      '每一天都是新的開始，充滿無限可能。',
      '成功的秘訣在於堅持不懈的努力。',
      '善待他人，就是善待自己。',
      '學會感恩，生活會更美好。',
      '時間是最公平的，給每個人都是二十四小時。',
    ];
    
    return traditionalChineseQuotes[_random.nextInt(traditionalChineseQuotes.length)];
  }

  /// 保存金句到本地資料庫
  Future<void> _saveQuoteToLocal(DailyQuote quote) async {
    try {
      await _database.into(_database.dailyQuotes).insert(
        DailyQuotesCompanion(
          contentZh: Value(quote.contentZh),
          contentEn: Value(quote.contentEn),
          author: Value(quote.author),
          category: Value(quote.category),
          createdAt: Value(quote.createdAt),
        ),
      );
    } catch (e) {
      debugPrint('保存金句到本地失敗: $e');
    }
  }

  /// 維護資料庫大小（保持100句以內）
  Future<void> _maintainDatabaseSize() async {
    try {
      final allQuotes = await (_database.select(_database.dailyQuotes)
            ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
          .get();

      if (allQuotes.length > maxQuotesInDatabase) {
        // 刪除最舊的金句，保留最新的100句
        final quotesToDelete = allQuotes.skip(maxQuotesInDatabase);
        for (final quote in quotesToDelete) {
          await (_database.delete(_database.dailyQuotes)
                ..where((q) => q.id.equals(quote.id)))
              .go();
        }
        debugPrint('🗑️ 清理了 ${quotesToDelete.length} 條舊金句，保持資料庫在 $maxQuotesInDatabase 句以內');
      }
    } catch (e) {
      debugPrint('維護資料庫大小失敗: $e');
    }
  }

  /// 從本地資料庫隨機獲取金句
  Future<DailyQuote> _getRandomQuoteFromLocal() async {
    try {
      final quotes = await _database.select(_database.dailyQuotes).get();
      
      if (quotes.isNotEmpty) {
        final randomQuote = quotes[_random.nextInt(quotes.length)];
        return randomQuote;
      }
    } catch (e) {
      debugPrint('從本地獲取金句失敗: $e');
    }

    // 如果本地也沒有，返回預設繁體中文金句
    return DailyQuote(
      id: 0,
      contentZh: defaultChineseQuote,
      contentEn: defaultEnglishQuote,
      author: 'GOAA Team',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 初始化預設金句庫（繁體中文版本）
  Future<void> _initializeDefaultQuotes() async {
    try {
      // 檢查是否已有資料
      final existingQuotes = await _database.select(_database.dailyQuotes).get();
      if (existingQuotes.isNotEmpty) return;

      // 預設繁體中文金句庫
      final defaultQuotes = [
        {
          'zh': '成功不是終點，失敗不是致命的，重要的是繼續前進的勇氣。',
          'en': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
          'author': 'Winston Churchill',
        },
        {
          'zh': '生活不是等待暴風雨過去，而是學會在雨中起舞。',
          'en': 'Life is not about waiting for the storm to pass, but learning to dance in the rain.',
          'author': 'Vivian Greene',
        },
        {
          'zh': '每一個偉大的成就都始於決定去嘗試。',
          'en': 'Every great achievement was once considered impossible.',
          'author': 'Unknown',
        },
        {
          'zh': '困難不會持續太久，但堅強的人會。',
          'en': 'Tough times never last, but tough people do.',
          'author': 'Robert H. Schuller',
        },
        {
          'zh': '相信自己，你比想像中更強大。',
          'en': 'Believe in yourself. You are braver than you think.',
          'author': 'A.A. Milne',
        },
        {
          'zh': '今天的努力是明天成功的基石。',
          'en': 'Today\'s effort is tomorrow\'s success.',
          'author': 'Unknown',
        },
        {
          'zh': '夢想不會逃跑，逃跑的永遠是你自己。',
          'en': 'Dreams don\'t run away. It\'s you who runs away from them.',
          'author': 'Unknown',
        },
        {
          'zh': '每一次挫折都是成長的機會。',
          'en': 'Every setback is an opportunity to grow.',
          'author': 'Unknown',
        },
        {
          'zh': '保持積極的心態，好運自然會來。',
          'en': 'Stay positive, and good things will come.',
          'author': 'Unknown',
        },
        {
          'zh': '堅持下去，最好的還在後頭。',
          'en': 'Keep going. The best is yet to come.',
          'author': 'Unknown',
        },
        {
          'zh': '每一天都是新的開始，充滿無限可能。',
          'en': 'Every day is a new beginning full of infinite possibilities.',
          'author': 'GOAA Team',
        },
        {
          'zh': '勇敢不是沒有恐懼，而是面對恐懼依然前行。',
          'en': 'Courage is not the absence of fear, but action in spite of it.',
          'author': 'Mark Twain',
        },
        {
          'zh': '智慧不在於知道答案，而在於問對問題。',
          'en': 'Wisdom is not about knowing the answers, but asking the right questions.',
          'author': 'Unknown',
        },
        {
          'zh': '改變從接受現實開始，成長從走出舒適圈開始。',
          'en': 'Change begins with accepting reality, growth begins with leaving your comfort zone.',
          'author': 'Unknown',
        },
        {
          'zh': '機會總是留給有準備的人。',
          'en': 'Opportunity favors the prepared mind.',
          'author': 'Louis Pasteur',
        },
      ];

      // 批量插入預設金句
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

      debugPrint('📚 預設繁體中文金句庫初始化完成，共 ${defaultQuotes.length} 條金句');
    } catch (e) {
      debugPrint('初始化預設金句庫失敗: $e');
    }
  }

  /// 獲取指定語言的金句內容
  String getQuoteContent(DailyQuote quote, String languageCode) {
    return languageCode.startsWith('zh') ? quote.contentZh : quote.contentEn;
  }

  /// 獲取資料庫統計資訊
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final allQuotes = await _database.select(_database.dailyQuotes).get();
      final Map<String, int> stats = {};
      
      for (final quote in allQuotes) {
        final category = quote.category.startsWith('daily_') ? 'daily' : quote.category;
        stats[category] = (stats[category] ?? 0) + 1;
      }
      
      stats['total'] = allQuotes.length;
      return stats;
    } catch (e) {
      debugPrint('獲取資料庫統計失敗: $e');
      return {'total': 0};
    }
  }

  /// 清理舊的每日金句（保留最近30天）
  Future<void> cleanupOldDailyQuotes() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // 只刪除 daily_ 開頭的金句，保留預設金句
      await (_database.delete(_database.dailyQuotes)
            ..where((q) => 
              q.category.like('daily_%') & 
              q.createdAt.isSmallerThanValue(thirtyDaysAgo)
            ))
          .go();
      
      debugPrint('🧹 清理了30天前的每日金句');
    } catch (e) {
      debugPrint('清理舊每日金句失敗: $e');
    }
  }
} 
