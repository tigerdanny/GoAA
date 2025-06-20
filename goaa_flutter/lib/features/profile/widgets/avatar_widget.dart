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
            onTap: () {
              debugPrint('🎯 頭像被點擊');
              onTap?.call();
            },
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
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: _buildAvatarImage(),
                    ),
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
    debugPrint('🖼️ 建構頭像圖片 - avatarPath: $avatarPath, avatarType: $avatarType');
    
    // 優先顯示傳入的頭像路徑
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      // 檢查是否為自定義頭像文件路徑
      if (avatarPath!.startsWith('/')) {
        final file = File(avatarPath!);
        if (file.existsSync()) {
          debugPrint('✅ 顯示自定義頭像文件: $avatarPath');
          return Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ 自定義頭像加載失敗: $error');
              return _buildDefaultAvatar();
            },
          );
        } else {
          debugPrint('⚠️ 自定義頭像文件不存在: $avatarPath');
        }
      } 
      // 檢查是否為預設頭像類型（如 'male_01'）
      else if (!avatarPath!.contains('/') && !avatarPath!.contains('.')) {
        debugPrint('✅ 顯示預設頭像類型: $avatarPath');
        return Image.asset(
          AvatarService.getAvatarPath(avatarPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ 預設頭像加載失敗: $error');
            return _buildDefaultAvatar();
          },
        );
      }
      // 檢查是否為 assets 路徑
      else if (avatarPath!.startsWith('assets/')) {
        debugPrint('✅ 顯示 assets 頭像: $avatarPath');
        return Image.asset(
          avatarPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Assets 頭像加載失敗: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }

    // 顯示預設頭像類型
    if (avatarType != null && avatarType!.isNotEmpty) {
      debugPrint('✅ 顯示 avatarType 頭像: $avatarType');
      return Image.asset(
        AvatarService.getAvatarPath(avatarType!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ AvatarType 頭像加載失敗: $error');
          return _buildDefaultAvatar();
        },
      );
    }

    // 顯示預設圖標
    debugPrint('🔄 顯示預設頭像圖標');
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
