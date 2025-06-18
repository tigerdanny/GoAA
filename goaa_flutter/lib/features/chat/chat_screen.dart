import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'controllers/chat_controller.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';

/// 聊天頁面
class ChatScreen extends StatefulWidget {
  final String friendUserId;
  final String friendUserName;

  const ChatScreen({
    super.key,
    required this.friendUserId,
    required this.friendUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController(
      friendUserId: widget.friendUserId,
      friendUserName: widget.friendUserName,
    );
    _controller.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 滾動到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// 發送消息
  void _sendMessage(String message) {
    _controller.sendMessage(message);
    HapticFeedback.lightImpact();
  }

  /// 顯示更多選項
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('清除聊天記錄'),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('用戶信息'),
              onTap: () {
                Navigator.pop(context);
                _showUserInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示清除確認對話框
  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除聊天記錄'),
        content: const Text('確定要清除所有聊天記錄嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.clearMessages();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('聊天記錄已清除'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  /// 顯示用戶信息
  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用戶信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用戶名: ${widget.friendUserName}'),
            const SizedBox(height: 8),
            Text('用戶ID: ${widget.friendUserId}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('狀態: '),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _controller.isConnected ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(_controller.isConnected ? '在線' : '離線'),
              ],
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                widget.friendUserName.isNotEmpty 
                    ? widget.friendUserName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.friendUserName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, child) => Text(
                      _controller.isConnected ? '在線' : '離線',
                      style: TextStyle(
                        fontSize: 12,
                        color: _controller.isConnected ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                if (_controller.messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '開始聊天吧！',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = _controller.messages[index];
                    return MessageBubble(
                      message: message.message,
                      isMe: message.isMe,
                      timestamp: message.timestamp,
                      senderName: message.senderName,
                    );
                  },
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) => ChatInputBar(
              onSendMessage: _sendMessage,
              isEnabled: _controller.isConnected,
            ),
          ),
        ],
      ),
    );
  }
}
