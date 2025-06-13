import 'package:flutter/material.dart';
import '../../../core/database/database.dart' as db;
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/repositories/group_repository.dart';
import '../../../core/services/daily_quote/daily_quote_repository.dart';
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
  final Map<int, Map<String, dynamic>> _groupStats = {};
  final Map<String, dynamic> _stats = {};
  DailyQuoteModel? _dailyQuote;

  // Repository實例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();
  final DailyQuoteRepository _quoteRepository = DailyQuoteRepository();

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  db.User? get currentUser => _currentUser;
  List<db.Group> get groups => _groups;
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
        _loadDailyQuote(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
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

  /// 載入每日金句
  Future<void> _loadDailyQuote() async {
    try {
      final today = DateTime.now();
      final todayCategory = 'daily_${today.year}_${today.month}_${today.day}';
      
      if (!await _quoteRepository.hasTodayQuote(today)) {
        _dailyQuote = await _quoteRepository.getTodayQuote(todayCategory);
        if (_dailyQuote != null) {
          await _quoteRepository.saveQuote(_dailyQuote!, today);
        }
      } else {
        _dailyQuote = await _quoteRepository.getTodayQuote(todayCategory);
      }
    } catch (e) {
      debugPrint('載入每日金句失敗: $e');
      _dailyQuote = _quoteRepository.getDefaultQuote();
    }
  }
} 
