import 'dart:async';
import '../logger_service.dart';
import 'daily_quote_repository.dart';
import 'daily_quote_network.dart';
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

  /// 獲取今日金句 - 優先從網路取得，取消每日只取一次限制
  Future<DailyQuoteModel> getTodayQuote() async {
    try {
      _logger.info('🌐 優先從網路獲取金句...');
      
      // 優先從網路獲取
      final networkQuote = await DailyQuoteNetwork.fetchQuote();
      if (networkQuote != null) {
        _logger.info('✅ 網路獲取成功: ${networkQuote.contentZh}');
        // 保存到本地作為備用
        await _repository.saveQuote(networkQuote, DateTime.now());
        return networkQuote;
      }
      
      _logger.info('❌ 網路獲取失敗，嘗試本地隨機金句...');
      
      // 網路失敗時使用本地隨機金句
      final localQuote = await _repository.getRandomQuote();
      if (localQuote != null) {
        _logger.info('✅ 本地金句獲取成功: ${localQuote.contentZh}');
        return localQuote;
      }
      
      _logger.info('❌ 本地金句也無法獲取，使用預設金句');
      return _getDefaultQuote();
      
    } catch (e) {
      _logger.error('獲取今日金句失敗', e);
      
      // 異常情況下嘗試本地金句
      try {
        final localQuote = await _repository.getRandomQuote();
        if (localQuote != null) {
          return localQuote;
        }
      } catch (localError) {
        _logger.error('本地金句獲取也失敗', localError);
      }
      
      return _getDefaultQuote();
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

  /// 強制從網路獲取金句（測試用）
  Future<DailyQuoteModel?> forceNetworkFetch() async {
    _logger.info('🔄 強制從網路獲取金句...');
    try {
      final networkQuote = await DailyQuoteNetwork.fetchQuote();
      if (networkQuote != null) {
        _logger.info('✅ 強制網路獲取成功: ${networkQuote.contentZh}');
        await _repository.saveQuote(networkQuote, DateTime.now());
        return networkQuote;
      }
      _logger.info('❌ 強制網路獲取失敗');
      return null;
    } catch (e) {
      _logger.error('強制網路獲取異常', e);
      return null;
    }
  }

  /// 獲取網路狀態
  Map<String, dynamic> getNetworkStatus() {
    return {
      'isOffline': false,
      'lastCheck': DateTime.now().toIso8601String(),
      'strategy': 'network_first', // 標明當前策略為網路優先
    };
  }
} 
