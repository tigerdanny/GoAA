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

  /// 獲取基於當前時間微秒的隨機數生成器，確保真正的隨機性
  Random _getTimeBasedRandom() {
    final microseconds = DateTime.now().microsecondsSinceEpoch;
    debugPrint('🎲 生成隨機種子: $microseconds');
    return Random(microseconds);
  }

  /// 預設的繁體中文金句（當無法上網且資料庫為空時使用）
  static const String defaultChineseQuote = '每一天都是新的開始，充滿無限可能。';
  static const String defaultEnglishQuote = 'Every day is a new beginning full of infinite possibilities.';
  
  /// 資料庫最大金句容量
  static const int maxQuotesInDatabase = 100;

  /// 獲取資料庫實例（直接使用已初始化的資料庫）
  AppDatabase get _database => DatabaseService.instance.database;

  /// 初始化服務（簡化版，無需重複初始化資料庫）
  void initialize() {
    // 使用簡單的 then 而不是 await，保持一致性
    _initializeDefaultQuotes().then((_) {
      debugPrint('✅ 預設金句初始化完成');
    }).catchError((e) {
      debugPrint('⚠️ 預設金句初始化失敗: $e');
    });
  }

  /// 獲取每日金句（完全簡化版，無await）
  Future<DailyQuote> getDailyQuote() {
    debugPrint('🎲 獲取每日金句...');
    
    // 1. 先檢查網路更新，然後 2. 從資料庫隨機取得金句
    return _checkAndFetchTodayQuoteFromNetwork().then((_) {
      return _getRandomQuoteFromLocal();
    }).then((randomQuote) {
      debugPrint('🎯 隨機選取: ${randomQuote.contentZh.length > 20 ? '${randomQuote.contentZh.substring(0, 20)}...' : randomQuote.contentZh}');
      return randomQuote;
    });
  }

  /// 檢查並從網路獲取今日新金句（修正版）
  Future<void> _checkAndFetchTodayQuoteFromNetwork() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // 檢查今日是否已獲取過金句
      final todayNetworkQuote = await _getTodayQuoteFromLocal(todayStart);
      
      if (todayNetworkQuote != null) {
        debugPrint('✅ 今日已從網路獲取過金句，無需重複獲取');
        return;
      }

      debugPrint('🌐 今日尚未從網路獲取金句，開始網路請求...');
      
      // 嘗試從網路獲取今日新金句
      final networkQuote = await _fetchQuoteFromNetwork();
      
      if (networkQuote != null) {
        final todayQuoteData = DailyQuote(
          id: 0,
          contentZh: networkQuote.contentZh,
          contentEn: networkQuote.contentEn,
          author: networkQuote.author,
          category: 'daily_${todayStart.millisecondsSinceEpoch}',
          createdAt: todayStart,
        );
        
        // 保存金句（不等待完成，保持非阻塞）
        _saveQuoteToLocal(todayQuoteData).then((_) {
          _maintainDatabaseSize();
          debugPrint('✅ 成功從網路獲取並存儲今日金句');
          debugPrint('🆕 新金句: ${networkQuote.contentZh}');
        }).catchError((saveError) {
          debugPrint('❌ 保存今日金句失敗: $saveError');
        });
      } else {
        debugPrint('⚠️  網路請求返回空結果');
      }
    } catch (e) {
      debugPrint('❌ 網路獲取今日金句失敗: $e');
    }
  }

  /// 檢查今日是否已有金句（簡化版）
  Future<DailyQuote?> _getTodayQuoteFromLocal(DateTime todayStart) {
    final todayCategory = 'daily_${todayStart.millisecondsSinceEpoch}';
    return (_database.select(_database.dailyQuotes)
          ..where((q) => q.category.equals(todayCategory)))
        .getSingleOrNull()
        .catchError((e) {
      debugPrint('查詢今日金句失敗: $e');
      return null;
    });
  }

  /// 從網路獲取金句（改進版，使用多個API備份）
  Future<DailyQuote?> _fetchQuoteFromNetwork() async {
    // API列表，按優先順序排列（ZenQuotes優先，因為Quotable證書有問題）
    final apiEndpoints = [
      {
        'url': 'https://zenquotes.io/api/random',
        'parser': _parseZenQuotesResponse,
        'name': 'ZenQuotes'
      },
      // Quotable API暫時停用，因為SSL證書過期
      // {
      //   'url': 'https://api.quotable.io/random?minLength=30&maxLength=120',
      //   'parser': _parseQuotableResponse,
      //   'name': 'Quotable'
      // },
    ];

    // 嘗試每個API
    for (final api in apiEndpoints) {
      try {
        debugPrint('🌐 嘗試 ${api['name']}: ${api['url']}');
        
        final response = await http.get(
          Uri.parse(api['url'] as String),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'GoAA Flutter App/1.0',
          },
        ).timeout(const Duration(seconds: 8));

        debugPrint('📡 ${api['name']} 回應狀態: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint('✅ ${api['name']} 請求成功，解析回應內容...');
          
          final parser = api['parser'] as DailyQuote? Function(String);
          final quote = parser(response.body);
          
          if (quote != null) {
            debugPrint('🎉 成功從 ${api['name']} 獲取金句！');
            return quote;
          }
        } else {
          debugPrint('❌ ${api['name']} 請求失敗，狀態碼: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ ${api['name']} 請求異常: $e');
        continue; // 嘗試下一個API
      }
    }

    debugPrint('❌ 所有API都失敗，返回null');
    return null;
  }

  /// 解析ZenQuotes API回應
  DailyQuote? _parseZenQuotesResponse(String responseBody) {
    try {
      final List<dynamic> data = json.decode(responseBody);
      if (data.isNotEmpty) {
        final quote = data[0];
        final englishContent = quote['q'] as String;
        final author = quote['a'] as String;

        debugPrint('📝 ZenQuotes英文金句: $englishContent');
        debugPrint('✍️  作者: $author');

        final chineseContent = _getChineseTranslationSync(englishContent);
        debugPrint('🈳 產生中文版本: $chineseContent');

        return DailyQuote(
          id: 0,
          contentZh: chineseContent,
          contentEn: englishContent,
          author: author,
          category: 'network',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('❌ 解析ZenQuotes回應失敗: $e');
    }
    return null;
  }

  /// 解析Quotable API回應
  DailyQuote? _parseQuotableResponse(String responseBody) {
    try {
      final data = json.decode(responseBody);
      final englishContent = data['content'] as String;
      final author = data['author'] as String;

      debugPrint('📝 Quotable英文金句: $englishContent');
      debugPrint('✍️  作者: $author');

      final chineseContent = _getChineseTranslationSync(englishContent);
      debugPrint('🈳 產生中文版本: $chineseContent');

      return DailyQuote(
        id: 0,
        contentZh: chineseContent,
        contentEn: englishContent,
        author: author,
        category: 'network',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ 解析Quotable回應失敗: $e');
    }
    return null;
  }

  /// 獲取繁體中文翻譯（同步版本，使用預設繁體中文金句庫）
  String _getChineseTranslationSync(String englishContent) {
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
    
    // 使用當前時間微秒作為種子，確保每次翻譯都是真正隨機的
    final tempRandom = _getTimeBasedRandom();
    final randomIndex = tempRandom.nextInt(traditionalChineseQuotes.length);
    debugPrint('🎯 中文翻譯隨機索引: $randomIndex (總共 ${traditionalChineseQuotes.length} 條)');
    
    return traditionalChineseQuotes[randomIndex];
  }

  /// 保存金句到本地資料庫（簡化版）
  Future<void> _saveQuoteToLocal(DailyQuote quote) {
    debugPrint('💾 開始保存金句到資料庫...');
    debugPrint('📝 金句內容: ${quote.contentZh}');
    debugPrint('🏷️  分類: ${quote.category}');
    
    return _database.into(_database.dailyQuotes).insert(
      DailyQuotesCompanion(
        contentZh: Value(quote.contentZh),
        contentEn: Value(quote.contentEn),
        author: Value(quote.author),
        category: Value(quote.category),
        createdAt: Value(quote.createdAt),
      ),
    ).then((_) {
      debugPrint('✅ 金句保存成功！');
      
      // 顯示目前資料庫總數（非阻塞）
      _database.select(_database.dailyQuotes).get().then((totalCount) {
        debugPrint('📊 資料庫現有金句總數: ${totalCount.length}');
      });
    }).catchError((e) {
      debugPrint('❌ 保存金句到本地失敗: $e');
    });
  }

  /// 維護資料庫大小（簡化版，保持100句以內）
  void _maintainDatabaseSize() {
    (_database.select(_database.dailyQuotes)
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
        .get()
        .then((allQuotes) {
      if (allQuotes.length > maxQuotesInDatabase) {
        // 刪除最舊的金句，保留最新的100句
        final quotesToDelete = allQuotes.skip(maxQuotesInDatabase);
        for (final quote in quotesToDelete) {
          (_database.delete(_database.dailyQuotes)
                ..where((q) => q.id.equals(quote.id)))
              .go();
        }
        debugPrint('🗑️ 清理了 ${quotesToDelete.length} 條舊金句，保持資料庫在 $maxQuotesInDatabase 句以內');
      }
    }).catchError((e) {
      debugPrint('維護資料庫大小失敗: $e');
    });
  }

  /// 從本地資料庫隨機獲取金句（時間種子版）
  Future<DailyQuote> _getRandomQuoteFromLocal() {
    debugPrint('📚 從資料庫查詢金句...');
    return _database.select(_database.dailyQuotes).get().then((quotes) {
      debugPrint('📊 資料庫中共有 ${quotes.length} 條金句');
      
      if (quotes.isNotEmpty) {
        // 使用當前時間微秒作為新的隨機種子，確保真正的隨機性
        final timeBasedRandom = _getTimeBasedRandom();
        final randomIndex = timeBasedRandom.nextInt(quotes.length);
        final randomQuote = quotes[randomIndex];
        
        debugPrint('🎯 隨機選擇第 ${randomIndex + 1} 條金句 (共 ${quotes.length} 條)');
        debugPrint('📝 選中的金句: ${randomQuote.contentZh}');
        debugPrint('🏷️  分類: ${randomQuote.category}');
        debugPrint('⏰ 創建時間: ${randomQuote.createdAt.toString().substring(0, 19)}');
        
        return randomQuote;
      } else {
        debugPrint('⚠️  資料庫中沒有金句，使用預設金句');
        return _getDefaultQuote();
      }
    }).catchError((e) {
      debugPrint('❌ 從本地獲取金句失敗: $e');
      return _getDefaultQuote();
    });
  }

  /// 獲取預設金句
  DailyQuote _getDefaultQuote() {
    debugPrint('🔄 使用預設金句');
    return DailyQuote(
      id: 0,
      contentZh: defaultChineseQuote,
      contentEn: defaultEnglishQuote,
      author: 'GOAA Team',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 初始化預設金句庫（簡化版）
  Future<void> _initializeDefaultQuotes() {
    return _database.select(_database.dailyQuotes).get().then((existingQuotes) {
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

      // 簡化：順序插入預設金句，不使用await
      for (final quote in defaultQuotes) {
        _database.into(_database.dailyQuotes).insert(
          DailyQuotesCompanion(
            contentZh: Value(quote['zh']!),
            contentEn: Value(quote['en']!),
            author: Value(quote['author']!),
            category: const Value('preset'),
          ),
        );
      }

      debugPrint('📚 預設繁體中文金句庫初始化完成，共 ${defaultQuotes.length} 條金句');
    }).catchError((e) {
      debugPrint('初始化預設金句庫失敗: $e');
    });
  }

  /// 獲取指定語言的金句內容
  String getQuoteContent(DailyQuote quote, String languageCode) {
    return languageCode.startsWith('zh') ? quote.contentZh : quote.contentEn;
  }

  /// 獲取資料庫統計資訊（簡化版）
  Future<Map<String, int>> getDatabaseStats() {
    return _database.select(_database.dailyQuotes).get().then((allQuotes) {
      final Map<String, int> stats = {};
      
      for (final quote in allQuotes) {
        final category = quote.category.startsWith('daily_') ? 'daily' : quote.category;
        stats[category] = (stats[category] ?? 0) + 1;
      }
      
      stats['total'] = allQuotes.length;
      return stats;
    }).catchError((e) {
      debugPrint('獲取資料庫統計失敗: $e');
      return {'total': 0};
    });
  }

  /// 清理舊的每日金句（簡化版，保留最近30天）
  void cleanupOldDailyQuotes() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    // 只刪除 daily_ 開頭的金句，保留預設金句
    (_database.delete(_database.dailyQuotes)
          ..where((q) => 
            q.category.like('daily_%') & 
            q.createdAt.isSmallerThanValue(thirtyDaysAgo)
          ))
        .go()
        .then((_) {
      debugPrint('🧹 清理了30天前的每日金句');
    }).catchError((e) {
      debugPrint('清理舊每日金句失敗: $e');
    });
  }
} 
