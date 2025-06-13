import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// 帳務設定頁面
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // 帐务设定状态
  bool _autoSettlement = false;
  bool _shareExpenses = true;
  String _defaultCurrency = 'NT\$';
  double _reminderThreshold = 1000.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.accountSettings ?? '帳務設定'),
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
              // 自动结算设定
              _buildSettingCard(
                title: '自動結算',
                subtitle: '當群組費用平衡時自動結算',
                child: Switch(
                  value: _autoSettlement,
                  onChanged: (value) {
                    setState(() => _autoSettlement = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // 费用分享设定
              _buildSettingCard(
                title: '費用分享',
                subtitle: '允許與群組成員分享費用詳情',
                child: Switch(
                  value: _shareExpenses,
                  onChanged: (value) {
                    setState(() => _shareExpenses = value);
                    HapticFeedback.lightImpact();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // 默认货币设定
              _buildSettingCard(
                title: '預設貨幣',
                subtitle: '新建群組時的預設貨幣',
                child: DropdownButton<String>(
                  value: _defaultCurrency,
                  items: const [
                    DropdownMenuItem(value: 'NT', child: Text('新台幣 (NT)')),
                    DropdownMenuItem(value: 'USD', child: Text('美元 (USD)')),
                    DropdownMenuItem(value: 'CNY', child: Text('人民幣 (CNY)')),
                    DropdownMenuItem(value: 'JPY', child: Text('日圓 (JPY)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _defaultCurrency = value);
                      HapticFeedback.lightImpact();
                    }
                  },
                  underline: const SizedBox(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 提醒阈值设定
              _buildSettingCard(
                title: '提醒閾值',
                subtitle: '超過此金額時發送提醒通知',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_reminderThreshold.toInt()} NT',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 150,
                      child: Slider(
                        value: _reminderThreshold,
                        min: 100,
                        max: 10000,
                        divisions: 99,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _reminderThreshold = value);
                        },
                        onChangeEnd: (value) {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 数据管理区域
              _buildSectionTitle('數據管理'),
              const SizedBox(height: 16),
              
              _buildActionCard(
                icon: Icons.backup,
                title: '備份數據',
                subtitle: '將帳務數據備份到雲端',
                onTap: () => _showBackupDialog(),
                color: AppColors.info,
              ),
              const SizedBox(height: 16),
              
              _buildActionCard(
                icon: Icons.restore,
                title: '恢復數據',
                subtitle: '從雲端恢復之前的備份',
                onTap: () => _showRestoreDialog(),
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              
              _buildActionCard(
                icon: Icons.delete_forever,
                title: '清除所有數據',
                subtitle: '永久刪除所有帳務記錄',
                onTap: () => _showClearDataDialog(),
                color: AppColors.error,
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

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('備份數據'),
        content: const Text('此功能將在未來版本中推出，敬請期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('恢復數據'),
        content: const Text('此功能將在未來版本中推出，敬請期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清除所有數據', style: TextStyle(color: AppColors.error)),
        content: const Text('此操作將永久刪除所有帳務記錄，且無法恢復。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 实际清除数据的逻辑
              _clearAllData();
            },
            child: const Text('確定清除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('此功能將在未來版本中實現'),
        backgroundColor: AppColors.info,
      ),
    );
  }
} 
