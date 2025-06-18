import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';

/// 時間選擇區塊
class TimePickerSection extends StatelessWidget {
  final String title;
  final String description;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final IconData icon;
  final bool enabled;

  const TimePickerSection({
    super.key,
    required this.title,
    required this.description,
    required this.selectedTime,
    required this.onTimeChanged,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 圖標
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled ? AppColors.primary : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // 文字內容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled ? AppColors.textSecondary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // 時間顯示和選擇按鈕
            GestureDetector(
              onTap: enabled ? () => _showTimePicker(context) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: enabled ? AppColors.primary : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  selectedTime != null
                      ? _formatTime(selectedTime!)
                      : '選擇時間',
                  style: TextStyle(
                    color: enabled ? AppColors.primary : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示時間選擇器
  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
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

    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  /// 格式化時間顯示
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 
