import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/friends_controller.dart';
import '../../../core/services/mqtt/mqtt_models.dart';

/// 好友列表視圖組件
class FriendsListView extends StatelessWidget {
  final FriendsController controller;

  const FriendsListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final friendRequests = controller.friendRequests;
    final pendingRequests = controller.pendingRequests;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 好友名單區域
          _buildFriendsSection(context),
          
          // 要求添加好友名單區域（有請求時才顯示）
          if (friendRequests.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildFriendRequestsSection(context),
          ],
          
          // 等待添加好友名單區域（有等待中的請求時才顯示）
          if (pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPendingRequestsSection(context),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 建構好友名單區域
  Widget _buildFriendsSection(BuildContext context) {
    final friendUsers = controller.getFriendUsers();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 區域標題
        Row(
          children: [
            const Icon(
              Icons.people,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '好友名單',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${friendUsers.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 分隔線
        Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 好友列表
        if (friendUsers.isEmpty)
          _buildEmptyState(
            context,
            icon: Icons.people_outline,
            title: '暫無好友',
            subtitle: '點擊右上角的 + 號來添加好友',
          )
        else
          ...friendUsers.map((user) => _buildFriendItem(context, user)),
      ],
    );
  }

  /// 建構要求添加好友區域
  Widget _buildFriendRequestsSection(BuildContext context) {
    final friendRequests = controller.friendRequests;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 區域標題
        Row(
          children: [
            const Icon(
              Icons.person_add_alt_1,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '要求添加好友名單',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${friendRequests.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 分隔線
        Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 好友請求列表
        ...friendRequests.map((request) => _buildFriendRequestItem(context, request)),
      ],
    );
  }

  /// 建構等待添加好友名單區域
  Widget _buildPendingRequestsSection(BuildContext context) {
    final pendingRequests = controller.pendingRequests;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 區域標題
        Row(
          children: [
            const Icon(
              Icons.hourglass_empty,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '等待添加好友名單',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pendingRequests.where((r) => r.status == 'pending').length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 分隔線
        Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 等待中的請求列表
        ...pendingRequests.map((request) => _buildPendingRequestItem(context, request)),
      ],
    );
  }

  /// 建構好友項目
  Widget _buildFriendItem(BuildContext context, OnlineUser user) {
    final isOnline = controller.onlineUsers.any((u) => u.userId == user.userId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline 
            ? AppColors.success.withValues(alpha: 0.3)
            : AppColors.textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 頭像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 用戶信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.userCode.length > 8 
                    ? '${user.userCode.substring(0, 8)}...'
                    : user.userCode,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          // 在線狀態
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline 
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? '上線' : '下線',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOnline ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建構好友請求項目
  Widget _buildFriendRequestItem(BuildContext context, GoaaMqttMessage request) {
    final fromUserName = request.data['fromUserName'] as String? ?? '未知用戶';
    final fromUserId = request.fromUserId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 頭像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.info,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 用戶信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fromUserName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fromUserId.length > 8 
                    ? '${fromUserId.substring(0, 8)}...'
                    : fromUserId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          // 狀態標籤
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.info,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '要求中',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 操作按鈕
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 接受按鈕
              Container(
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => controller.acceptFriendRequest(request),
                  icon: const Icon(Icons.check, size: 18),
                  color: AppColors.success,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              
              const SizedBox(width: 4),
              
              // 拒絕按鈕
              Container(
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => controller.rejectFriendRequest(request),
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.error,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 建構等待中請求項目
  Widget _buildPendingRequestItem(BuildContext context, PendingFriendRequest request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (request.status) {
      case 'accepted':
        statusColor = AppColors.success;
        statusText = '已接受';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = '已拒絕';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.warning;
        statusText = '等待中';
        statusIcon = Icons.hourglass_empty;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 頭像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: statusColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 用戶信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.targetName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (request.targetEmail.isNotEmpty)
                  Text(
                    request.targetEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (request.targetPhone.isNotEmpty)
                  Text(
                    request.targetPhone,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // 狀態
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 操作按鈕（只對已處理的請求顯示）
          if (request.status != 'pending') ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => controller.removePendingRequest(request.id),
              icon: const Icon(Icons.close, size: 16),
              color: AppColors.textSecondary,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  /// 建構空狀態
  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
