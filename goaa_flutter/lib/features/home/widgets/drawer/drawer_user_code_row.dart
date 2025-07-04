import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_id_dialog.dart';

/// 抽屜用戶代碼行組件
/// 包含用戶代碼和QR碼操作按鈕
class DrawerUserCodeRow extends StatelessWidget {
  final User? currentUser;
  final VoidCallback onShowQRCode;
  final VoidCallback onScanQRCode;

  const DrawerUserCodeRow({
    super.key,
    required this.currentUser,
    required this.onShowQRCode,
    required this.onScanQRCode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUserCode(),
        const SizedBox(width: 12),
        _buildQRCodeButton(context),
        const SizedBox(width: 8),
        _buildScanButton(context),
      ],
    );
  }

  /// 建構用戶代碼點擊按鈕
  Widget _buildUserCode() {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            if (currentUser?.userCode != null && currentUser!.userCode.isNotEmpty) {
              UserIdDialog.show(
                context,
                currentUser!.userCode,
                userName: currentUser?.name,
              );
            }
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
        );
      },
    );
  }

  /// 建構QR碼按鈕 - 適配白色背景
  Widget _buildQRCodeButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onShowQRCode();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.qr_code,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// 建構掃描按鈕 - 適配白色背景
  Widget _buildScanButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onScanQRCode();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          LucideIcons.scan,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
