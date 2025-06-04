import 'package:flutter/material.dart';
import '../../../../core/database/database.dart';
import '../../../../core/services/daily_quote_service.dart';

/// 抽屜每日金句組件
/// 顯示今日金句內容和作者
class DrawerDailyQuote extends StatelessWidget {
  final DailyQuote? dailyQuote;

  const DrawerDailyQuote({
    super.key,
    required this.dailyQuote,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyQuote == null) return const SizedBox.shrink();
    
    final content = DailyQuoteService().getQuoteContent(
      dailyQuote!,
      Localizations.localeOf(context).languageCode,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildQuoteHeader(context),
          const SizedBox(height: 8),
          _buildQuoteContent(context, content),
          if (dailyQuote!.author != null) ...[
            const SizedBox(height: 8),
            _buildQuoteAuthor(context),
          ],
        ],
      ),
    );
  }

  /// 建構金句標題
  Widget _buildQuoteHeader(BuildContext context) {
    return Text(
      '💭 今日金句',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 建構金句內容
  Widget _buildQuoteContent(BuildContext context, String content) {
    return Text(
      '"$content"',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.white,
        fontStyle: FontStyle.italic,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 建構金句作者
  Widget _buildQuoteAuthor(BuildContext context) {
    return Text(
      '— ${dailyQuote!.author}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 11,
      ),
    );
  }
} 
