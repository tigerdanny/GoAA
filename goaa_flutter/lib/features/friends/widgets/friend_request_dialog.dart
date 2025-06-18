import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';

/// 好友請求對話框組件
class FriendRequestDialogs {
  
  /// 顯示添加好友對話框
  static void showAddFriendDialog(
    BuildContext context,
    OnlineUser user,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('發送好友請求'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('向 ${user.userName} 發送好友請求？'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '用戶名: ${user.userName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('用戶代碼: ${user.userCode}'),
                  Text('最後在線: ${_formatLastSeen(user.lastSeen)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('發送請求'),
          ),
        ],
      ),
    );
  }

  /// 顯示好友請求列表對話框
  static void showFriendRequestsList(
    BuildContext context,
    List<GoaaMqttMessage> friendRequests,
    Function(String) onAccept,
    Function(String) onReject,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('好友請求 (${friendRequests.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: friendRequests.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final request = friendRequests[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(request.data['userName'][0].toUpperCase()),
                ),
                title: Text(request.data['userName']),
                subtitle: Text(request.data['userCode']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        onReject(request.fromUserId);
                        Navigator.pop(context);
                      },
                      child: const Text('拒絕'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onAccept(request.fromUserId);
                        Navigator.pop(context);
                      },
                      child: const Text('接受'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  /// 顯示好友請求接收對話框
  static void showFriendRequestReceived(
    BuildContext context,
    GoaaMqttMessage message,
    VoidCallback onAccept,
    VoidCallback onReject,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('好友請求'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(
                message.data['userName'][0].toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${message.data['userName']} 想要加您為好友',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '用戶代碼: ${message.data['userCode']}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onReject();
            },
            child: const Text('拒絕'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept();
            },
            child: const Text('接受'),
          ),
        ],
      ),
    );
  }

  static String _formatLastSeen(DateTime lastSeen) {
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
