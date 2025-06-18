import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 提醒設置控制器
class ReminderController extends ChangeNotifier {
  // 提醒設置鍵值
  static const String _expenseReminderKey = 'expense_reminder_enabled';
  static const String _expenseReminderTimeKey = 'expense_reminder_time';
  static const String _settlementReminderKey = 'settlement_reminder_enabled';
  static const String _settlementReminderTimeKey = 'settlement_reminder_time';
  static const String _dailyReportKey = 'daily_report_enabled';
  static const String _dailyReportTimeKey = 'daily_report_time';
  static const String _weeklyReportKey = 'weekly_report_enabled';
  static const String _monthlyReportKey = 'monthly_report_enabled';

  // 提醒設置狀態
  bool _expenseReminderEnabled = false;
  TimeOfDay _expenseReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _settlementReminderEnabled = false;
  TimeOfDay _settlementReminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _dailyReportEnabled = false;
  TimeOfDay _dailyReportTime = const TimeOfDay(hour: 22, minute: 0);
  bool _weeklyReportEnabled = false;
  bool _monthlyReportEnabled = false;

  bool _isLoading = false;

  // Getters
  bool get expenseReminderEnabled => _expenseReminderEnabled;
  TimeOfDay get expenseReminderTime => _expenseReminderTime;
  bool get settlementReminderEnabled => _settlementReminderEnabled;
  TimeOfDay get settlementReminderTime => _settlementReminderTime;
  bool get dailyReportEnabled => _dailyReportEnabled;
  TimeOfDay get dailyReportTime => _dailyReportTime;
  bool get weeklyReportEnabled => _weeklyReportEnabled;
  bool get monthlyReportEnabled => _monthlyReportEnabled;
  bool get isLoading => _isLoading;

  /// 初始化設置
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadSettings();
    } catch (e) {
      debugPrint('初始化提醒設置失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 設置記帳提醒
  Future<void> setExpenseReminder(bool enabled) async {
    _expenseReminderEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置記帳提醒時間
  Future<void> setExpenseReminderTime(TimeOfDay time) async {
    _expenseReminderTime = time;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置結算提醒
  Future<void> setSettlementReminder(bool enabled) async {
    _settlementReminderEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置結算提醒時間
  Future<void> setSettlementReminderTime(TimeOfDay time) async {
    _settlementReminderTime = time;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置每日報告
  Future<void> setDailyReport(bool enabled) async {
    _dailyReportEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置每日報告時間
  Future<void> setDailyReportTime(TimeOfDay time) async {
    _dailyReportTime = time;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置每週報告
  Future<void> setWeeklyReport(bool enabled) async {
    _weeklyReportEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// 設置每月報告
  Future<void> setMonthlyReport(bool enabled) async {
    _monthlyReportEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  /// 載入設置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _expenseReminderEnabled = prefs.getBool(_expenseReminderKey) ?? false;
    _settlementReminderEnabled = prefs.getBool(_settlementReminderKey) ?? false;
    _dailyReportEnabled = prefs.getBool(_dailyReportKey) ?? false;
    _weeklyReportEnabled = prefs.getBool(_weeklyReportKey) ?? false;
    _monthlyReportEnabled = prefs.getBool(_monthlyReportKey) ?? false;

    // 載入時間設置
    final expenseTimeString = prefs.getString(_expenseReminderTimeKey);
    if (expenseTimeString != null) {
      _expenseReminderTime = _parseTimeString(expenseTimeString);
    }

    final settlementTimeString = prefs.getString(_settlementReminderTimeKey);
    if (settlementTimeString != null) {
      _settlementReminderTime = _parseTimeString(settlementTimeString);
    }

    final dailyReportTimeString = prefs.getString(_dailyReportTimeKey);
    if (dailyReportTimeString != null) {
      _dailyReportTime = _parseTimeString(dailyReportTimeString);
    }
  }

  /// 保存設置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await Future.wait([
      prefs.setBool(_expenseReminderKey, _expenseReminderEnabled),
      prefs.setString(_expenseReminderTimeKey, _formatTimeOfDay(_expenseReminderTime)),
      prefs.setBool(_settlementReminderKey, _settlementReminderEnabled),
      prefs.setString(_settlementReminderTimeKey, _formatTimeOfDay(_settlementReminderTime)),
      prefs.setBool(_dailyReportKey, _dailyReportEnabled),
      prefs.setString(_dailyReportTimeKey, _formatTimeOfDay(_dailyReportTime)),
      prefs.setBool(_weeklyReportKey, _weeklyReportEnabled),
      prefs.setBool(_monthlyReportKey, _monthlyReportEnabled),
    ]);
  }

  /// 格式化時間
  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  /// 解析時間字符串
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// 設置加載狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 
