import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/theme/app_dimensions.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';

/// 好友卡片組件
class FriendCard extends StatelessWidget {
  final OnlineUser user;
  final bool isFriend;
  final VoidCallback? onAddFriend;
  final VoidCallback? onOpenChat;

  const FriendCard({
    super.key,
    required this.user,
    required this.isFriend,
    this.onAddFriend,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRecent = DateTime.now().difference(user.lastSeen).inMinutes < 5;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecent
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isFriend ? null : onAddFriend,
        child: Padding(
          padding: AppDimensions.paddingM,
          child: Row(
            children: [
              // 頭像
              _buildAvatar(isRecent),
              const SizedBox(width: 16),
              
              // 用戶信息
              Expanded(
                child: _buildUserInfo(context, isRecent),
              ),
              
              // 操作按鈕
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isRecent) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        if (isRecent)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, bool isRecent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isFriend)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '已是好友',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.userCode,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatLastSeen(user.lastSeen),
          style: TextStyle(
            fontSize: 12,
            color: isRecent ? AppColors.success : AppColors.textSecondary,
            fontWeight: isRecent ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (isFriend) {
      // 好友狀態下不顯示任何按鈕（聊天功能已移除）
      return const SizedBox(width: 48); // 保持佈局一致
    } else {
      return IconButton(
        onPressed: onAddFriend,
        icon: const Icon(
          Icons.person_add,
          color: AppColors.primary,
        ),
      );
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final difference = DateTime.now().difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return '剛剛在線';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${lastSeen.month}/${lastSeen.day}';
    }
  }
} 
