import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// 介面設定頁面
class InterfaceSettingsScreen extends StatefulWidget {
  const InterfaceSettingsScreen({super.key});

  @override
  State<InterfaceSettingsScreen> createState() => _InterfaceSettingsScreenState();
}

class _InterfaceSettingsScreenState extends State<InterfaceSettingsScreen> {
  // 介面设定状态
  bool _darkMode = false;
  bool _useSystemTheme = true;
  String _fontSize = 'medium';
  String _colorTheme = 'default';
  bool _hapticFeedback = true;
  bool _animations = true;
  bool _showBalance = true;
  String _dateFormat = 'yyyy/MM/dd';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.interface ?? '介面設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设定
              _buildSectionTitle('主題設定'),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '跟隨系統主題',
                subtitle: '自動切換深色/淺色模式',
                child: Switch(
                  value: _useSystemTheme,
                  onChanged: (value) {
                    setState(() => _useSystemTheme = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              if (!_useSystemTheme)
                _buildSettingCard(
                  title: '深色模式',
                  subtitle: '使用深色主題',
                  child: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                      HapticFeedback.lightImpact();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              if (!_useSystemTheme) const SizedBox(height: 16),
              
              _buildDropdownCard(
                title: '主題顏色',
                subtitle: '選擇應用的主色調',
                value: _colorTheme,
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('預設藍色')),
                  DropdownMenuItem(value: 'green', child: Text('清新綠色')),
                  DropdownMenuItem(value: 'purple', child: Text('優雅紫色')),
                  DropdownMenuItem(value: 'orange', child: Text('活力橙色')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _colorTheme = value);
                    HapticFeedback.lightImpact();
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // 字体设定
              _buildSectionTitle('字體設定'),
              const SizedBox(height: 16),
              
              _buildDropdownCard(
                title: '字體大小',
                subtitle: '調整應用內文字大小',
                value: _fontSize,
                items: const [
                  DropdownMenuItem(value: 'small', child: Text('小字體')),
                  DropdownMenuItem(value: 'medium', child: Text('標準字體')),
                  DropdownMenuItem(value: 'large', child: Text('大字體')),
                  DropdownMenuItem(value: 'extra_large', child: Text('超大字體')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _fontSize = value);
                    HapticFeedback.lightImpact();
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // 交互设定
              _buildSectionTitle('交互設定'),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '觸覺回饋',
                subtitle: '按鈕點擊時的震動反饋',
                child: Switch(
                  value: _hapticFeedback,
                  onChanged: (value) {
                    setState(() => _hapticFeedback = value);
                    if (value) HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '動畫效果',
                subtitle: '介面切換和元素動畫',
                child: Switch(
                  value: _animations,
                  onChanged: (value) {
                    setState(() => _animations = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // 显示设定
              _buildSectionTitle('顯示設定'),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                title: '顯示餘額',
                subtitle: '在首頁顯示帳戶餘額',
                child: Switch(
                  value: _showBalance,
                  onChanged: (value) {
                    setState(() => _showBalance = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDropdownCard(
                title: '日期格式',
                subtitle: '選擇日期顯示格式',
                value: _dateFormat,
                items: const [
                  DropdownMenuItem(value: 'yyyy/MM/dd', child: Text('2024/12/31')),
                  DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('31/12/2024')),
                  DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('12/31/2024')),
                  DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('2024-12-31')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateFormat = value);
                    HapticFeedback.lightImpact();
                  }
                },
              ),
              const SizedBox(height: 32),
              
              // 重置设定
              _buildSectionTitle('重置設定'),
              const SizedBox(height: 16),
              
              _buildActionCard(
                icon: Icons.refresh,
                title: '重置介面設定',
                subtitle: '恢復所有介面設定為預設值',
                onTap: () => _showResetDialog(),
                color: AppColors.warning,
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

  Widget _buildDropdownCard({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
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
          DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ),
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
              Icon(
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

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('重置介面設定', style: TextStyle(color: AppColors.warning)),
        content: const Text('此操作將恢復所有介面設定為預設值。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            child: Text('重置', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _darkMode = false;
      _useSystemTheme = true;
      _fontSize = 'medium';
      _colorTheme = 'default';
      _hapticFeedback = true;
      _animations = true;
      _showBalance = true;
      _dateFormat = 'yyyy/MM/dd';
    });
    
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('介面設定已重置為預設值'),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 
