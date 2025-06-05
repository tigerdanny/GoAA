import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/repositories/group_repository.dart';
import '../../../core/services/daily_quote_service.dart';

/// 首頁控制器
/// 管理首頁的數據載入、狀態管理和業務邏輯
class HomeController extends ChangeNotifier {
  // 數據相關
  bool _isLoading = false;
  User? _currentUser;
  List<Group> _groups = [];
  final Map<int, Map<String, dynamic>> _groupStats = {};
  Map<String, dynamic> _stats = {};
  DailyQuote? _dailyQuote;

  // Repository實例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();

  // Getters
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  List<Group> get groups => _groups;
  Map<int, Map<String, dynamic>> get groupStats => _groupStats;
  Map<String, dynamic> get stats => _stats;
  DailyQuote? get dailyQuote => _dailyQuote;

  /// 使用預載入的數據初始化
  void usePreloadedData({
    User? preloadedUser,
    List<Group>? preloadedGroups,
    Map<int, Map<String, dynamic>>? preloadedGroupStats,
    Map<String, dynamic>? preloadedStats,
  }) {
    _currentUser = preloadedUser;
    _groups = preloadedGroups ?? [];
    _groupStats.clear();
    _groupStats.addAll(preloadedGroupStats ?? {});
    _stats = preloadedStats ?? {};
    
    _isLoading = false;
    notifyListeners();
  }

  /// 載入所有數據
  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _userRepository.getCurrentUser();
      
      // 如果没有当前用户，尝试创建一个
      if (_currentUser == null) {
        debugPrint('未找到當前用戶，嘗試創建新用戶');
        await DatabaseService.instance.initialize();
        _currentUser = await _userRepository.getCurrentUser();
        
        if (_currentUser == null) {
          debugPrint('創建用戶失敗，使用默認資料');
        } else {
          debugPrint('成功創建用戶: ${_currentUser!.name}');
        }
      }
      
      if (_currentUser != null) {
        _groups = await _groupRepository.getUserGroups(_currentUser!.id);
        
        _groupStats.clear();
        for (final group in _groups) {
          _groupStats[group.id] = await _groupRepository.getGroupStats(group.id);
        }
        
        _stats = await _userRepository.getUserStats(_currentUser!.id);
      }

      await _loadDailyQuote();
      
      _isLoading = false;
      notifyListeners();
      
      // 查詢並顯示資料庫中的所有每日金句
      await _showAllDailyQuotesInDatabase();
    } catch (e) {
      debugPrint('加載數據失敗: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 載入每日金句
  Future<void> _loadDailyQuote() async {
    try {
      debugPrint('\n🌐 正在抓取今天的每日金句...');
      _dailyQuote = await DailyQuoteService().getDailyQuote();
      
      if (_dailyQuote != null) {
        debugPrint('\n📅 成功獲取今天的每日金句:');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🇨🇳 中文: ${_dailyQuote!.contentZh}');
        debugPrint('🇺🇸 英文: ${_dailyQuote!.contentEn}');
        debugPrint('✍️  作者: ${_dailyQuote!.author ?? '未知'}');
        debugPrint('🏷️  分類: ${_dailyQuote!.category}');
        debugPrint('⏰ 時間: ${_dailyQuote!.createdAt.toString().substring(0, 19)}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        // 測試語言切換
        debugPrint('\n🌍 語言測試:');
        final zhContent = DailyQuoteService().getQuoteContent(_dailyQuote!, 'zh');
        final enContent = DailyQuoteService().getQuoteContent(_dailyQuote!, 'en');
        debugPrint('中文版本: $zhContent');
        debugPrint('英文版本: $enContent');
        debugPrint('');
      } else {
        debugPrint('⚠️  未能獲取每日金句，將使用默認內容');
      }
    } catch (e) {
      debugPrint('获取每日金句失败: $e');
      debugPrint('❌ 獲取每日金句失敗: $e');
      _dailyQuote = null;
    }
  }

  /// 查詢並顯示資料庫中的所有每日金句
  Future<void> _showAllDailyQuotesInDatabase() async {
    try {
      final database = DatabaseService.instance.database;
      final allQuotes = await database.select(database.dailyQuotes).get();
      
      debugPrint('\n📚 資料庫中的每日金句總覽:');
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('總共有 ${allQuotes.length} 條每日金句');
      debugPrint('═══════════════════════════════════════════════\n');
      
      for (int i = 0; i < allQuotes.length; i++) {
        final quote = allQuotes[i];
        debugPrint('📝 第 ${i + 1} 條金句:');
        debugPrint('   ID: ${quote.id}');
        debugPrint('   🇨🇳 中文: ${quote.contentZh}');
        debugPrint('   🇺🇸 英文: ${quote.contentEn}');
        debugPrint('   ✍️  作者: ${quote.author ?? '未知'}');
        debugPrint('   🏷️  分類: ${quote.category}');
        debugPrint('   ⏰ 創建時間: ${quote.createdAt.toString().substring(0, 19)}');
        debugPrint('   ─────────────────────────────────────────────\n');
      }
      
      // 統計不同分類的金句數量
      final Map<String, int> categoryStats = {};
      for (final quote in allQuotes) {
        categoryStats[quote.category] = (categoryStats[quote.category] ?? 0) + 1;
      }
      
      debugPrint('📊 金句分類統計:');
      categoryStats.forEach((category, count) {
        debugPrint('   $category: $count 條');
      });
      debugPrint('═══════════════════════════════════════════════\n');
      
    } catch (e) {
      debugPrint('查詢資料庫金句失敗: $e');
    }
  }
} 
