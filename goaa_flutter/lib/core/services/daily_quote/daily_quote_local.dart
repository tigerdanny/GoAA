import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../models/daily_quote.dart' as models;
import '../../database/database_service.dart';

/// 每日金句本地資料庫服務
class DailyQuoteLocal {
  static final DailyQuoteLocal _instance = DailyQuoteLocal._internal();
  factory DailyQuoteLocal() => _instance;
  
  final DatabaseService _dbService;
  static const int maxQuotesInDatabase = 100;
  
  // 🎲 修復隨機數問題：使用時間種子的隨機數生成器
  late final Random _random;

  DailyQuoteLocal._internal() : _dbService = DatabaseService.instance {
    // 使用當前時間的微秒級時間戳作為種子
    final seed = DateTime.now().microsecondsSinceEpoch;
    _random = Random(seed);
    debugPrint('🎲 DailyQuoteLocal 隨機數種子: $seed');
  }

  /// 初始化
  Future<void> initialize() async {
    try {
      final db = _dbService.database;
      final quotes = await db.select(db.dailyQuotes).get();
      if (quotes.isEmpty) {
        await _insertDefaultQuotes();
      }
    } catch (e) {
      debugPrint('本地資料初始化失敗: $e');
    }
  }

  /// 插入預設金句
  Future<void> _insertDefaultQuotes() async {
    const defaultQuotes = [
      {
        'contentZh': '成功不是終點，失敗不是致命的，重要的是繼續前進的勇氣。',
        'contentEn': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        'author': 'Winston Churchill',
        'category': 'inspirational'
      },
      {
        'contentZh': '生活不是等待暴風雨過去，而是學會在雨中起舞。',
        'contentEn': 'Life is not about waiting for the storm to pass, but learning to dance in the rain.',
        'author': 'Vivian Greene',
        'category': 'inspirational'
      }
    ];

    final db = _dbService.database;
    for (final quote in defaultQuotes) {
      final dailyQuote = models.DailyQuoteModel(
        id: 0, // 臨時 ID，會被資料庫自動生成
        contentZh: quote['contentZh'] as String,
        contentEn: quote['contentEn'] as String,
        author: quote['author'] as String,
        category: quote['category'] as String,
        createdAt: DateTime.now(),
      );
      await db.into(db.dailyQuotes).insert(dailyQuote.toCompanion());
    }
  }

  /// 取得隨機金句 - 🎲 使用真正的隨機數
  Future<models.DailyQuoteModel?> getRandomQuote() async {
    final db = _dbService.database;
    final quotes = await db.select(db.dailyQuotes).get();
    if (quotes.isNotEmpty) {
      // 使用基於時間種子的隨機數生成器
      final randomIndex = _random.nextInt(quotes.length);
      debugPrint('🎲 隨機選擇金句索引: $randomIndex / ${quotes.length}');
      return models.DailyQuoteModel.fromRow(quotes[randomIndex]);
    }
    return null;
  }

  /// 取得指定分類金句
  Future<models.DailyQuoteModel?> getQuoteByCategory(String category) async {
    final db = _dbService.database;
    final result = await (db.select(db.dailyQuotes)
      ..where((tbl) => tbl.category.equals(category)))
      .getSingleOrNull();
    
    if (result != null) {
      return models.DailyQuoteModel.fromRow(result);
    }
    return null;
  }

  /// 儲存金句
  Future<void> saveQuote(models.DailyQuoteModel quote, [String? category]) async {
    final db = _dbService.database;
    final updatedQuote = category != null ? quote.copyWith(category: category) : quote;
    await db.into(db.dailyQuotes).insert(updatedQuote.toCompanion());
  }

  /// 清理多餘金句（保留最新100條）
  Future<void> cleanup() async {
    final db = _dbService.database;
    final quotes = await (db.select(db.dailyQuotes)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
    
    if (quotes.length > maxQuotesInDatabase) {
      final idsToDelete = quotes.skip(maxQuotesInDatabase).map((q) => q.id).toList();
      if (idsToDelete.isNotEmpty) {
        await (db.delete(db.dailyQuotes)
          ..where((tbl) => tbl.id.isIn(idsToDelete)))
          .go();
      }
    }
  }

  /// 檢查指定分類是否有金句
  Future<bool> hasQuoteWithCategory(String category) async {
    final db = _dbService.database;
    final result = await (db.select(db.dailyQuotes)
      ..where((tbl) => tbl.category.equals(category)))
      .getSingleOrNull();
    return result != null;
  }
} 
