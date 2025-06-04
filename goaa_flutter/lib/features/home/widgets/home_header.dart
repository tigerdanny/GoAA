import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/database/database.dart';
import '../../../core/services/daily_quote_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 首页顶部标题区域组件
class HomeHeader extends StatelessWidget {
  final User? currentUser;
  final DailyQuote? dailyQuote;
  final VoidCallback onMenuTap;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const HomeHeader({
    super.key,
    required this.currentUser,
    required this.dailyQuote,
    required this.onMenuTap,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 调试信息
    debugPrint('HomeHeader - currentUser: ${currentUser?.name ?? 'null'}, userCode: ${currentUser?.userCode ?? 'null'}');
    
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：選單+小箭頭，問候語和每日金句
            Row(
              children: [
                // 菜单图标 + 箭头
                GestureDetector(
                  onTap: () {
                    debugPrint('菜單圖標被點擊');
                    onMenuTap();
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 问候语和每日金句
                Expanded(
                  child: _buildGreeting(context, l10n),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 第二行：用户头像，用户名称，用户代码，二维码图标
            Row(
              children: [
                // 用户头像
                Container(
                  width: 56,
                  height: 56,
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
                const SizedBox(width: 16),
                
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户名
                      Text(
                        currentUser?.name ?? '歡迎使用 GOAA',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // 用户代码 + 二维码图标
                      _buildUserCodeRow(l10n),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建问候语和每日金句
  Widget _buildGreeting(BuildContext context, AppLocalizations? l10n) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 问候语
        Text(
          timeGreeting,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        
        // 每日金句（小字体）
        Text(
          quoteContent,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建用户代码行
  Widget _buildUserCodeRow(AppLocalizations? l10n) {
    return Row(
      children: [
        Text(
          currentUser?.userCode ?? '點擊設定完善資料',
          style: TextStyle(
            color: currentUser?.userCode != null 
              ? AppColors.textSecondary 
              : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        
        if (currentUser?.userCode != null) ...[
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
                LucideIcons.scan,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
} 
