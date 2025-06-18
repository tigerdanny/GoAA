import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';

/// 消息氣泡組件
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe && senderName != null) ...[
                    Text(
                      senderName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe 
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isMe ? AppColors.primary : AppColors.primaryLight,
      child: Text(
        isMe ? 'Me' : (senderName?.isNotEmpty == true ? senderName![0] : '?'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isMe ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.month}/${time.day}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }
} 
