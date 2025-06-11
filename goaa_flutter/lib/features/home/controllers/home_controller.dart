import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
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
    
    // 🚀 異步載入每日金句和剩餘群組統計
    _loadAdditionalDataAsync();
  }

  /// 🚀 重新設計：完全使用 async/await 載入所有數據
  Future<void> loadDataAsync() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 載入用戶資料
      await _loadUserDataAsync();
      
      // 2. 如果有用戶，並行載入相關數據
      if (_currentUser != null) {
        await _loadAllRelatedDataAsync();
      }
      
      // 3. 載入每日金句（不阻塞主流程）
      _loadDailyQuoteAsync();
      
    } catch (e) {
      debugPrint('❌ 數據載入失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🚀 新增：異步載入用戶資料
  Future<void> _loadUserDataAsync() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
      if (_currentUser == null) {
        debugPrint('⚠️ 未找到用戶，使用預設資料');
      }
    } catch (e) {
      debugPrint('❌ 載入用戶失敗: $e');
    }
  }

  /// 🚀 新增：並行載入所有相關數據
  Future<void> _loadAllRelatedDataAsync() async {
    if (_currentUser == null) return;
    
    try {
      // 🚀 並行任務：同時載入群組列表和用戶統計
      final futures = await Future.wait([
        _groupRepository.getUserGroups(_currentUser!.id),
        _userRepository.getUserStats(_currentUser!.id),
      ]);
      
      // 處理結果
      _groups = futures[0] as List<Group>;
      _stats = futures[1] as Map<String, dynamic>;
      
      // 🚀 並行載入群組統計
      if (_groups.isNotEmpty) {
        await _loadAllGroupStatsAsync();
      }
      
    } catch (e) {
      debugPrint('❌ 相關數據載入失敗: $e');
    }
  }

  /// 🚀 新增：並行載入所有群組統計
  Future<void> _loadAllGroupStatsAsync() async {
    try {
      final groupStatsFutures = _groups.map((group) => 
        _loadSingleGroupStatsAsync(group.id)
      );
      
      // 等待所有群組統計載入完成
      await Future.wait(groupStatsFutures);
      
    } catch (e) {
      debugPrint('❌ 群組統計載入失敗: $e');
    }
  }

  /// 🚀 新增：載入單個群組統計的輔助方法
  Future<void> _loadSingleGroupStatsAsync(int groupId) async {
    try {
      final stats = await _groupRepository.getGroupStats(groupId);
      _groupStats[groupId] = stats;
    } catch (e) {
      debugPrint('⚠️ 群組 $groupId 統計載入失敗: $e');
      _groupStats[groupId] = <String, dynamic>{};
    }
  }

  /// 🚀 新增：異步載入每日金句（不阻塞主流程）
  Future<void> _loadDailyQuoteAsync() async {
    try {
      _dailyQuote = await DailyQuoteService().getDailyQuote();
      debugPrint('✅ 每日金句載入: ${_dailyQuote?.contentZh}');
      notifyListeners(); // 金句載入完成後通知UI更新
    } catch (e) {
      debugPrint('❌ 每日金句載入失敗: $e');
      _dailyQuote = null;
    }
  }

  /// 🚀 新增：載入額外數據（用於預載入模式）
  Future<void> _loadAdditionalDataAsync() async {
    // 並行載入每日金句和剩餘群組統計
    final futures = <Future>[];
    
    // 任務1：載入每日金句
    futures.add(_loadDailyQuoteAsync());
    
    // 任務2：載入剩餘群組統計（如果有的話）
    final remainingGroups = _groups.where((group) => 
      !_groupStats.containsKey(group.id)
    ).toList();
    
    if (remainingGroups.isNotEmpty) {
      final remainingStatsFutures = remainingGroups.map((group) => 
        _loadSingleGroupStatsAsync(group.id)
      );
      futures.addAll(remainingStatsFutures);
    }
    
    // 等待所有額外任務完成
    await Future.wait(futures);
    notifyListeners();
  }

  /// 🚀 保留舊方法以兼容性（標記為廢棄）
  @Deprecated('使用 loadDataAsync() 替代')
  void loadData() {
    loadDataAsync();
  }
} 
