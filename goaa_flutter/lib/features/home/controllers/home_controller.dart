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
  }

  /// 載入所有數據（完全簡化版，無await）
  void loadData() {
    _isLoading = true;
    notifyListeners();

    // 1. 順序載入用戶資料
    _loadUserData();
    
    // 2. 如果有用戶，順序載入群組資料
    if (_currentUser != null) {
      _loadGroupData();
    }
    
    // 3. 載入每日金句（簡化版）
    _loadDailyQuote();
    
    _isLoading = false;
    notifyListeners();
  }

  /// 載入用戶資料（同步化）
  void _loadUserData() {
    try {
      // 使用同步方式，避免await
      _userRepository.getCurrentUser().then((user) {
        _currentUser = user;
        if (user == null) {
          debugPrint('未找到用戶，使用預設資料');
        }
      }).catchError((e) {
        debugPrint('載入用戶失敗: $e');
      });
    } catch (e) {
      debugPrint('用戶資料載入錯誤: $e');
    }
  }

  /// 載入群組資料（同步化）
  void _loadGroupData() {
    if (_currentUser == null) return;
    
    try {
      // 順序載入群組列表
      _groupRepository.getUserGroups(_currentUser!.id).then((groups) {
        _groups = groups;
        
        // 簡單的群組統計，不使用複雜的for await
        for (final group in groups) {
          _groupRepository.getGroupStats(group.id).then((stats) {
            _groupStats[group.id] = stats;
          });
        }
      });
      
      // 載入用戶統計
      _userRepository.getUserStats(_currentUser!.id).then((stats) {
        _stats = stats;
      });
      
    } catch (e) {
      debugPrint('群組資料載入錯誤: $e');
    }
  }

  /// 載入每日金句（簡化版，無複雜非同步）
  void _loadDailyQuote() {
    try {
      // 使用簡單的 then 而不是 await，避免阻塞
      DailyQuoteService().getDailyQuote().then((quote) {
        _dailyQuote = quote;
        debugPrint('✅ 每日金句載入: ${quote.contentZh}');
        // 載入完成後通知UI更新
        notifyListeners();
      }).catchError((e) {
        debugPrint('❌ 每日金句載入失敗: $e');
        _dailyQuote = null;
      });
    } catch (e) {
      debugPrint('每日金句載入錯誤: $e');
      _dailyQuote = null;
    }
  }


} 
