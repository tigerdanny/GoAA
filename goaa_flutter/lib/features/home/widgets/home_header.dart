import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/database/database.dart' as db;
import '../../../core/models/daily_quote.dart' as model;
import '../../../core/theme/app_colors.dart';

/// 首页顶部标题区域组件
class HomeHeader extends StatelessWidget {
  final db.User? currentUser;
  final model.DailyQuoteModel? dailyQuote;
  final VoidCallback onMenuTap;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;
  final String languageCode;

  const HomeHeader({
    Key? key,
    required this.currentUser,
    required this.dailyQuote,
    required this.onMenuTap,
    required this.onShowQRCode,
    required this.onScanQRCode,
    required this.languageCode,
  }) : super(key: key);

  String getQuoteContent(model.DailyQuoteModel quote, String languageCode) {
    return languageCode == 'zh' ? quote.contentZh : quote.contentEn;
  }

  @override
  Widget build(BuildContext context) {
    // 调试信息
    debugPrint('HomeHeader - currentUser: ${currentUser?.name ?? 'null'}, userCode: ${currentUser?.userCode ?? 'null'}');
    
    final now = DateTime.now();
    final hour = now.hour;
    String timeGreeting = '';

    if (hour >= 5 && hour < 12) {
      timeGreeting = '早安~';
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = '午安~';
    } else if (hour >= 18 && hour < 22) {
      timeGreeting = '晚安~';
    } else {
      timeGreeting = '深夜好~';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部操作栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(
                    LucideIcons.menu,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onShowQRCode,
                      icon: const Icon(
                        LucideIcons.qrCode,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: onScanQRCode,
                      icon: const Icon(
                        LucideIcons.scan,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 问候语和用户信息
            Text(
              timeGreeting,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              currentUser?.name ?? '訪客',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (currentUser?.userCode != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: currentUser!.userCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('用戶代碼已複製'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: ${currentUser!.userCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.copy,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 每日金句
            if (dailyQuote != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.quote,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '每日金句',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      getQuoteContent(dailyQuote!, languageCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    if (dailyQuote!.author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${dailyQuote!.author}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
