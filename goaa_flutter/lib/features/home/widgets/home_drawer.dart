import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/services/daily_quote_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 首页侧边栏菜单组件
class HomeDrawer extends StatelessWidget {
  final User? currentUser;
  final DailyQuote? dailyQuote;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const HomeDrawer({
    super.key,
    required this.currentUser,
    required this.dailyQuote,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outlined, color: AppColors.primary),
                    title: Text(l10n?.personalInfo ?? '個人資訊'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings_outlined, color: AppColors.primary),
                    title: Text(l10n?.settings ?? '設定'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建菜单头部
  Widget _buildHeader(BuildContext context, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // 用户头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/goaa_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 问候语和金句
          Text(
            _getGreeting(l10n),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // 用户名
          Text(
            currentUser?.name ?? '用戶',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // 用户代码行
          _buildUserCodeRow(),
        ],
      ),
    );
  }

  /// 获取问候语
  String _getGreeting(AppLocalizations? l10n) {
    final now = DateTime.now();
    final hour = now.hour;
    
    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = '早安~';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = '午安~';
    } else if (hour >= 17 && hour < 21) {
      timeGreeting = '晚安~';
    } else {
      timeGreeting = '深夜好~';
    }

    String quoteContent = '';
    if (dailyQuote != null) {
      final languageCode = l10n?.localeName ?? 'zh';
      quoteContent = DailyQuoteService().getQuoteContent(dailyQuote!, languageCode);
    } else {
      final localeName = l10n?.localeName;
      quoteContent = (localeName != null && localeName.startsWith('zh'))
          ? '每一天都是新的開始，充滿無限可能。'
          : 'Every day is a new beginning full of infinite possibilities.';
    }

    return '$timeGreeting $quoteContent';
  }

  /// 构建用户代码行
  Widget _buildUserCodeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentUser?.userCode ?? 'N/A',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        
        // 二维码图标
        GestureDetector(
          onTap: onShowQRCode,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.qr_code,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // 扫描图标
        GestureDetector(
          onTap: onScanQRCode,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
} 
