import 'package:flutter/material.dart';
import '../../../core/database/database.dart' as db;
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/repositories/group_repository.dart';
import '../../../core/database/repositories/expense_repository.dart';
import '../../../core/services/daily_quote/daily_quote_service.dart';
import '../../../core/models/daily_quote.dart';

/// 首頁控制器
/// 管理首頁的數據載入、狀態管理和業務邏輯
class HomeController extends ChangeNotifier {
  // 數據相關
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  db.User? _currentUser;
  List<db.Group> _groups = [];
  List<db.Expense> _expenses = [];
  final Map<int, Map<String, dynamic>> _groupStats = {};
  final Map<String, dynamic> _stats = {};
  DailyQuoteModel? _dailyQuote;

  // Repository實例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  db.User? get currentUser => _currentUser;
  List<db.Group> get groups => _groups;
  List<db.Expense> get expenses => _expenses;
  Map<int, Map<String, dynamic>> get groupStats => _groupStats;
  Map<String, dynamic> get stats => _stats;
  DailyQuoteModel? get dailyQuote => _dailyQuote;

  /// 使用預載入的數據初始化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadCurrentUser(),
        _loadGroups(),
        _loadExpenses(),
        _loadDailyQuote(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 使用預載入數據
  void usePreloadedData({
    db.User? preloadedUser,
    List<db.Group>? preloadedGroups,
    Map<int, Map<String, dynamic>>? preloadedGroupStats,
    Map<String, dynamic>? preloadedStats,
  }) {
    if (preloadedUser != null) _currentUser = preloadedUser;
    if (preloadedGroups != null) _groups = preloadedGroups;
    if (preloadedGroupStats != null) _groupStats.addAll(preloadedGroupStats);
    if (preloadedStats != null) _stats.addAll(preloadedStats);
    _isLoading = false;
    
    // 異步載入每日金句和帳務
    Future.wait([
      _loadDailyQuote(),
      _loadExpenses(),
    ]).then((_) {
      notifyListeners();
    });
    
    notifyListeners();
  }

  /// 異步載入數據
  Future<void> loadDataAsync() async {
    await initialize();
  }

  /// 重新整理數據
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadCurrentUser(),
        _loadGroups(),
        _loadExpenses(),
        _loadDailyQuote(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// 只刷新用戶資料
  Future<void> refreshUserOnly() async {
    try {
      await _loadCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('刷新用戶資料失敗: $e');
    }
  }

  /// 載入當前用戶
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      debugPrint('載入當前用戶失敗: $e');
      rethrow;
    }
  }

  /// 載入群組列表
  Future<void> _loadGroups() async {
    try {
      _groups = await _groupRepository.getGroups();
      await _loadGroupStats();
      await _loadUserStats();
    } catch (e) {
      debugPrint('載入群組列表失敗: $e');
      rethrow;
    }
  }

  /// 載入群組統計數據
  Future<void> _loadGroupStats() async {
    try {
      for (final group in _groups) {
        final stats = await _groupRepository.getGroupStats(group.id);
        _groupStats[group.id] = stats;
      }
    } catch (e) {
      debugPrint('載入群組統計數據失敗: $e');
      rethrow;
    }
  }

  /// 載入用戶統計數據
  Future<void> _loadUserStats() async {
    try {
      if (_currentUser != null) {
        final userStats = await _userRepository.getUserStats(_currentUser!.id);
        _stats.addAll(userStats);
        debugPrint('🔍 用戶統計數據: $_stats');
      }
    } catch (e) {
      debugPrint('載入用戶統計數據失敗: $e');
    }
  }

  /// 載入每日金句
  Future<void> _loadDailyQuote() async {
    try {
      debugPrint('🔍 開始載入每日金句（網路優先模式）...');
      
      // 使用新的網路優先策略，每次都嘗試從網路獲取
      final quoteService = DailyQuoteService();
      _dailyQuote = await quoteService.getTodayQuote();
      
      if (_dailyQuote != null) {
        debugPrint('✅ 成功獲取金句: ${_dailyQuote!.contentZh}');
        debugPrint('📊 金句來源: ${_dailyQuote!.category}');
      } else {
        debugPrint('❌ 金句獲取失敗，這不應該發生');
        // 備用方案
        _dailyQuote = DailyQuoteModel(
          id: 0,
          contentZh: '每一天都是新的開始，充滿無限可能。',
          contentEn: 'Every day is a new beginning full of infinite possibilities.',
          author: 'GOAA',
          category: 'fallback',
          createdAt: DateTime.now(),
        );
      }
      
      debugPrint('🔍 最終顯示金句: ${_dailyQuote?.contentZh ?? "null"}');
    } catch (e) {
      debugPrint('❌ 載入每日金句異常: $e');
      // 異常情況下的備用金句
      _dailyQuote = DailyQuoteModel(
        id: 0,
        contentZh: '保持積極，迎接挑戰。',
        contentEn: 'Stay positive and embrace challenges.',
        author: 'GOAA',
        category: 'error_fallback',
        createdAt: DateTime.now(),
      );
      debugPrint('🔍 使用異常備用金句: ${_dailyQuote?.contentZh}');
    }
  }

  /// 載入帳務列表
  Future<void> _loadExpenses() async {
    try {
      if (_currentUser != null) {
        _expenses = await _expenseRepository.getUserGroupExpenses(_currentUser!.id, limit: 10);
        debugPrint('🔍 載入帳務記錄: ${_expenses.length} 筆');
      }
    } catch (e) {
      debugPrint('❌ 載入帳務列表失敗: $e');
      _expenses = [];
    }
  }
} 
