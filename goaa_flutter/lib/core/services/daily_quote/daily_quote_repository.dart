import 'package:flutter/foundation.dart';
import '../../models/daily_quote.dart';
import 'daily_quote_local.dart';
import 'daily_quote_network.dart';

/// 每日金句資料存取層
class DailyQuoteRepository {
  final DailyQuoteLocal _local = DailyQuoteLocal();

  /// 初始化
  Future<void> initialize() async {
    await _local.initialize();
  }

  /// 取得今日金句（優先本地，否則網路）
  Future<DailyQuoteModel?> getTodayQuote(String todayCategory) async {
    final local = await _local.getQuoteByCategory(todayCategory);
    if (local != null) return local;
    final network = await DailyQuoteNetwork.fetchQuote();
    if (network != null) {
      await _local.saveQuote(network);
      return network;
    }
    return null;
  }

  /// 取得隨機金句
  Future<DailyQuoteModel?> getRandomQuote() => _local.getRandomQuote();

  /// 清理本地金句
  Future<void> cleanup() => _local.cleanup();

  /// 獲取預設金句
  DailyQuoteModel getDefaultQuote() {
    return DailyQuoteModel(
      id: 0,
      contentZh: '每一天都是新的開始，充滿無限可能。',
      contentEn: 'Every day is a new beginning full of infinite possibilities.',
      author: 'GOAA',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 檢查今日是否已有金句
  Future<bool> hasTodayQuote(DateTime todayStart) async {
    try {
      final todayCategory = 'daily_${todayStart.year}_${todayStart.month}_${todayStart.day}';
      return await _local.hasQuoteWithCategory(todayCategory);
    } catch (e) {
      debugPrint('檢查今日金句失敗: $e');
      return false;
    }
  }

  /// 保存金句
  Future<void> saveQuote(DailyQuoteModel quote, DateTime date) async {
    try {
      final category = 'daily_${date.year}_${date.month}_${date.day}';
      await _local.saveQuote(quote, category);
    } catch (e) {
      debugPrint('保存金句失敗: $e');
    }
  }
} 
