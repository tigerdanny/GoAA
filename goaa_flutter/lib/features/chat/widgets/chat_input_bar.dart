import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/theme/app_dimensions.dart';

/// 聊天輸入欄組件
class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingM,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: widget.isEnabled,
                  decoration: InputDecoration(
                    hintText: widget.isEnabled ? '輸入消息...' : '連接中...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: (_hasText && widget.isEnabled) ? _sendMessage : null,
              icon: Icon(
                Icons.send,
                color: (_hasText && widget.isEnabled) 
                    ? AppColors.primary 
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
