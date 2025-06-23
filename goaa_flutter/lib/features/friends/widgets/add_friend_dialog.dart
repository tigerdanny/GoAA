import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 好友搜索信息
class FriendSearchInfo {
  final String name;
  final String email;
  final String phone;
  
  FriendSearchInfo({
    required this.name,
    required this.email,
    required this.phone,
  });
}

/// 添加好友对话框组件
class AddFriendDialog extends StatefulWidget {
  final Function(FriendSearchInfo) onConfirm;

  const AddFriendDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final searchInfo = FriendSearchInfo(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      Navigator.pop(context);
      widget.onConfirm(searchInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.person_add, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '添加好友',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '請輸入好友的資訊以搜索並添加',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 姓名輸入框
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '姓名 *',
                hintText: '請輸入好友的姓名',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person, color: AppColors.primary),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return '請輸入姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // 信箱輸入框
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '信箱',
                hintText: '請輸入好友的信箱（選填）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email, color: AppColors.primary),
              ),
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value!)) {
                    return '請輸入有效的信箱格式';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // 電話輸入框
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '電話',
                hintText: '請輸入好友的電話（選填）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
              ),
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  final phoneRegex = RegExp(r'^[\+]?[0-9\-\s\(\)]{8,}$');
                  if (!phoneRegex.hasMatch(value!)) {
                    return '請輸入有效的電話格式';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            Text(
              '* 必填項目，信箱和電話至少填寫一項',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('搜索並添加', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 
