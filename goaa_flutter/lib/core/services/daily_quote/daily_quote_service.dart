import 'dart:async';
import '../logger_service.dart';
import 'daily_quote_repository.dart';
import '../../models/daily_quote.dart';

/// 每日金句服務
class DailyQuoteService {
  static final DailyQuoteService _instance = DailyQuoteService._internal();
  factory DailyQuoteService() => _instance;
  
  final DailyQuoteRepository _repository;
  final LoggerService _logger;

  DailyQuoteService._internal()
      : _repository = DailyQuoteRepository(),
        _logger = LoggerService();

  /// 初始化服務
  Future<void> initialize() async {
    // 初始化邏輯
  }

  /// 獲取今日金句
  Future<DailyQuoteModel> getTodayQuote() async {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayCategory = 'daily_${todayStart.year}_${todayStart.month}_${todayStart.day}';

    try {
      final quote = await _repository.getTodayQuote(todayCategory);
      if (quote != null) {
        return quote;
      }
      return await getRandomQuote();
    } catch (e) {
      _logger.error('獲取今日金句失敗', e);
      return getRandomQuote();
    }
  }

  /// 獲取隨機金句
  Future<DailyQuoteModel> getRandomQuote() async {
    final quote = await _repository.getRandomQuote();
    if (quote != null) {
      return quote;
    }
    return _getDefaultQuote();
  }

  /// 獲取預設金句
  DailyQuoteModel _getDefaultQuote() {
    return DailyQuoteModel(
      id: 0,
      contentZh: '每一天都是新的開始，充滿無限可能。',
      contentEn: 'Every day is a new beginning full of infinite possibilities.',
      author: 'GOAA',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 獲取網路狀態
  Map<String, dynamic> getNetworkStatus() {
    return {
      'isOffline': false,
      'lastCheck': DateTime.now().toIso8601String(),
    };
  }
} 
