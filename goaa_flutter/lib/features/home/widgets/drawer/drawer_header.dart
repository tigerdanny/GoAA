import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/avatar_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'drawer_user_code_row.dart';

/// 抽屜頭部組件
/// 包含用戶頭像、姓名和代碼
class DrawerHeader extends StatelessWidget {
  final User? currentUser;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const DrawerHeader({
    super.key,
    required this.currentUser,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
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
          width: 80,
          height: 80,
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
        width: 80,
        height: 80,
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
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }

  /// 建構用戶名稱
  Widget _buildUserName(BuildContext context, AppLocalizations? l10n) {
    return Text(
      currentUser?.name ?? l10n?.defaultUser ?? '用戶',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
} 
