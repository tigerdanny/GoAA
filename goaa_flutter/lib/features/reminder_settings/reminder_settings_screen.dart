import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'controllers/reminder_controller.dart';
import 'widgets/reminder_toggle_section.dart';
import 'widgets/time_picker_section.dart';

/// 提醒設定頁面 - 重構版
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late ReminderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReminderController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.reminderSettings ?? '提醒設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 記帳提醒區塊
                  ReminderToggleSection(
                    title: '記帳提醒',
                    description: '每天提醒您記錄支出',
                    value: _controller.expenseReminderEnabled,
                    onChanged: _controller.setExpenseReminder,
                    icon: Icons.receipt_long,
                  ),
                  
                  // 記帳提醒時間設置
                  TimePickerSection(
                    title: '記帳提醒時間',
                    description: '設置每日記帳提醒的時間',
                    selectedTime: _controller.expenseReminderTime,
                    onTimeChanged: (time) {
                      if (time != null) {
                        _controller.setExpenseReminderTime(time);
                      }
                    },
                    icon: Icons.schedule,
                    enabled: _controller.expenseReminderEnabled,
                  ),
                  
                  // 結算提醒區塊
                  ReminderToggleSection(
                    title: '結算提醒',
                    description: '提醒您處理待結算的費用',
                    value: _controller.settlementReminderEnabled,
                    onChanged: _controller.setSettlementReminder,
                    icon: Icons.account_balance_wallet,
                  ),
                  
                  // 結算提醒時間設置
                  TimePickerSection(
                    title: '結算提醒時間',
                    description: '設置結算提醒的時間',
                    selectedTime: _controller.settlementReminderTime,
                    onTimeChanged: (time) {
                      if (time != null) {
                        _controller.setSettlementReminderTime(time);
                      }
                    },
                    icon: Icons.schedule,
                    enabled: _controller.settlementReminderEnabled,
                  ),
                  
                  // 每日報告區塊
                  ReminderToggleSection(
                    title: '每日報告',
                    description: '每天發送支出統計報告',
                    value: _controller.dailyReportEnabled,
                    onChanged: _controller.setDailyReport,
                    icon: Icons.assessment,
                  ),
                  
                  // 每日報告時間設置
                  TimePickerSection(
                    title: '每日報告時間',
                    description: '設置每日報告發送的時間',
                    selectedTime: _controller.dailyReportTime,
                    onTimeChanged: (time) {
                      if (time != null) {
                        _controller.setDailyReportTime(time);
                      }
                    },
                    icon: Icons.schedule,
                    enabled: _controller.dailyReportEnabled,
                  ),
                  
                  // 每週報告區塊
                  ReminderToggleSection(
                    title: '每週報告',
                    description: '每週發送詳細的支出分析報告',
                    value: _controller.weeklyReportEnabled,
                    onChanged: _controller.setWeeklyReport,
                    icon: Icons.bar_chart,
                  ),
                  
                  // 每月報告區塊
                  ReminderToggleSection(
                    title: '每月報告',
                    description: '每月發送完整的財務總結報告',
                    value: _controller.monthlyReportEnabled,
                    onChanged: _controller.setMonthlyReport,
                    icon: Icons.pie_chart,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 測試提醒按鈕
                  _buildTestReminderSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 構建測試提醒區塊
  Widget _buildTestReminderSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_active,
            color: AppColors.info,
            size: 24,
          ),
        ),
        title: const Text(
          '測試提醒',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('發送一個測試通知以確認提醒功能正常'),
        trailing: ElevatedButton(
          onPressed: _sendTestNotification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
          ),
          child: const Text('測試'),
        ),
      ),
    );
  }

  /// 發送測試通知
  void _sendTestNotification() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('測試通知已發送！'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
