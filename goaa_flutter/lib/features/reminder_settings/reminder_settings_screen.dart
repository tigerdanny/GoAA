import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// 提醒設定頁面
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  // 提醒设定状态
  bool _enableReminders = true;
  bool _dailyReminder = false;
  bool _weeklyReminder = true;
  bool _settlementReminder = true;
  bool _debtReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  // 周日到周六的提醒日期设定，需要可修改所以不能是final
  // ignore: prefer_final_fields
  List<bool> _reminderDays = [false, true, true, true, true, true, false];

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 总开关
              _buildSettingCard(
                title: '啟用提醒',
                subtitle: '接收分帳相關的提醒通知',
                child: Switch(
                  value: _enableReminders,
                  onChanged: (value) {
                    setState(() => _enableReminders = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // 提醒类型
              _buildSectionTitle('提醒類型'),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '每日提醒',
                subtitle: '每天固定時間提醒檢查帳務',
                child: Switch(
                  value: _enableReminders && _dailyReminder,
                  onChanged: _enableReminders ? (value) {
                    setState(() => _dailyReminder = value);
                    HapticFeedback.lightImpact();
                  } : null,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '每週提醒',
                subtitle: '每週提醒處理未結算費用',
                child: Switch(
                  value: _enableReminders && _weeklyReminder,
                  onChanged: _enableReminders ? (value) {
                    setState(() => _weeklyReminder = value);
                    HapticFeedback.lightImpact();
                  } : null,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '結算提醒',
                subtitle: '當有費用可以結算時通知',
                child: Switch(
                  value: _enableReminders && _settlementReminder,
                  onChanged: _enableReminders ? (value) {
                    setState(() => _settlementReminder = value);
                    HapticFeedback.lightImpact();
                  } : null,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '欠款提醒',
                subtitle: '提醒處理未償還的欠款',
                child: Switch(
                  value: _enableReminders && _debtReminder,
                  onChanged: _enableReminders ? (value) {
                    setState(() => _debtReminder = value);
                    HapticFeedback.lightImpact();
                  } : null,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // 提醒时间
              if (_enableReminders && (_dailyReminder || _weeklyReminder))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('提醒時間'),
                    const SizedBox(height: 16),
                    
                    _buildActionCard(
                      icon: Icons.access_time,
                      title: '提醒時間',
                      subtitle: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                      onTap: () => _selectTime(),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              
              // 提醒日期（周提醒）
              if (_enableReminders && _weeklyReminder)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('提醒日期'),
                    const SizedBox(height: 16),
                    _buildWeekDaySelector(),
                    const SizedBox(height: 24),
                  ],
                ),
              
              // 测试提醒
              _buildSectionTitle('測試提醒'),
              const SizedBox(height: 16),
              
              _buildActionCard(
                icon: Icons.notifications_active,
                title: '發送測試提醒',
                subtitle: '立即發送一個測試通知',
                onTap: () => _sendTestNotification(),
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '選擇提醒日期',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isSelected = _reminderDays[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _reminderDays[index] = !_reminderDays[index]);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      weekDays[index],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 🚀 選擇時間（重新設計使用 async/await）
  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selectedTime != null) {
      setState(() => _reminderTime = selectedTime);
      HapticFeedback.lightImpact();
    }
  }

  void _sendTestNotification() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('測試提醒已發送！請檢查通知面板'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: '確定',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
} 
