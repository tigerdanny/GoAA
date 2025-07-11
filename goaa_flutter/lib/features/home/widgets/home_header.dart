import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/database/database.dart' as db;
import '../../../core/models/daily_quote.dart' as model;
import '../../../core/theme/app_colors.dart';
import '../../../core/services/avatar_service.dart';
import '../../../core/widgets/user_id_dialog.dart';

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
    final now = DateTime.now();
    final hour = now.hour;
    String timeGreeting = '';

    if (hour >= 5 && hour < 12) {
      timeGreeting = '午安~';
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = '午安~';
    } else if (hour >= 18 && hour < 22) {
      timeGreeting = '晚安~';
    } else {
      timeGreeting = '深夜好~';
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 頂部選單按鈕和問候語區域
            Container(
              padding: const EdgeInsets.fromLTRB(0, 16, 20, 16),
              child: Row(
                children: [
                  // 選單按鈕 - 緊貼左邊螢幕邊緣，無任何空白
                  GestureDetector(
                    onTap: onMenuTap,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 問候語和每日金句
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeGreeting,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (dailyQuote != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            getQuoteContent(dailyQuote!, languageCode),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            '每一天都是新的開始，充滿無限可能。',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 用戶信息區域
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // 用戶頭像 - 與選單頁一致的圓形圖片頭像
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 用戶信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用戶名稱
                        Text(
                          currentUser?.name ?? '用戶',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 用戶ID + 操作按鈕
                        Row(
                          children: [
                            // 用戶ID（點擊顯示）
                            if (currentUser?.userCode != null) ...[
                              GestureDetector(
                                onTap: () {
                                  UserIdDialog.show(
                                    context,
                                    currentUser!.userCode,
                                    userName: currentUser?.name,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '用戶ID',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(
                                        Icons.touch_app,
                                        size: 10,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'N/A',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            // QR碼按鈕
                            GestureDetector(
                              onTap: onShowQRCode,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  LucideIcons.qrCode,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 掃一掃按鈕
                            GestureDetector(
                              onTap: onScanQRCode,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  LucideIcons.scan,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 建構頭像圖片
  Widget _buildAvatarImage() {
    // 優先顯示自定義頭像
    final avatarSource = currentUser?.avatarSource;
    if (avatarSource != null && avatarSource.isNotEmpty) {
      final file = File(avatarSource);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }

    // 顯示預設頭像
    final avatarType = currentUser?.avatarType;
    if (avatarType != null && avatarType.isNotEmpty) {
      return Image.asset(
        AvatarService.getAvatarPath(avatarType),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    // 顯示預設圖標
    return _buildDefaultAvatar();
  }

  /// 建構預設頭像
  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/goaa_logo.png',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }
} 
