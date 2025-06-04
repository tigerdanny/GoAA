import 'package:flutter/material.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'drawer_user_code_row.dart';
import 'drawer_daily_quote.dart';

/// 抽屜頭部組件
/// 包含用戶頭像、姓名、代碼和每日金句
class DrawerHeader extends StatelessWidget {
  final User? currentUser;
  final DailyQuote? dailyQuote;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const DrawerHeader({
    super.key,
    required this.currentUser,
    required this.dailyQuote,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 用戶頭像
          _buildUserAvatar(),
          const SizedBox(height: 16),
          
          // 用戶名稱
          _buildUserName(context, l10n),
          const SizedBox(height: 8),
          
          // 用戶代碼和操作
          DrawerUserCodeRow(
            currentUser: currentUser,
            onShowQRCode: onShowQRCode,
            onScanQRCode: onScanQRCode,
          ),
          const SizedBox(height: 16),
          
          // 每日金句
          DrawerDailyQuote(dailyQuote: dailyQuote),
        ],
      ),
    );
  }

  /// 建構用戶頭像
  Widget _buildUserAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/goaa_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 建構用戶名稱
  Widget _buildUserName(BuildContext context, AppLocalizations? l10n) {
    return Text(
      currentUser?.name ?? l10n?.defaultUser ?? '用戶',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
} 
