import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/avatar_service.dart';

/// 頭像顯示組件
class AvatarWidget extends StatelessWidget {
  final String? avatarType;
  final String? avatarPath;
  final VoidCallback? onTap;
  final double size;

  const AvatarWidget({
    super.key,
    this.avatarType,
    this.avatarPath,
    this.onTap,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3), 
                      width: 3
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildAvatarImage(),
                  ),
                ),
                if (onTap != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt, 
                        color: Colors.white, 
                        size: 20
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 16),
            Text(
              '點擊更換頭像',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    // 優先顯示自定義頭像
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }

    // 顯示預設頭像
    if (avatarType != null && avatarType!.isNotEmpty) {
      return Image.asset(
        AvatarService.getAvatarPath(avatarType!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    // 顯示預設圖標
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      color: AppColors.surface,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}
