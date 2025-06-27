import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/friends_controller.dart';

/// 搜索類型枚舉
enum SearchType {
  name('姓名'),
  email('信箱'),
  phone('電話');
  
  const SearchType(this.displayName);
  final String displayName;
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
  final _searchController = TextEditingController();
  SearchType _selectedSearchType = SearchType.name;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final searchValue = _searchController.text.trim();
      
      if (searchValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('請輸入搜索內容'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final searchInfo = FriendSearchInfo(
        query: searchValue,
        searchTime: DateTime.now(),
      );
      Navigator.pop(context);
      widget.onConfirm(searchInfo);
    }
  }

  // 根據搜索類型獲取鍵盤類型
  TextInputType _getKeyboardType() {
    switch (_selectedSearchType) {
      case SearchType.email:
        return TextInputType.emailAddress;
      case SearchType.phone:
        return TextInputType.phone;
      case SearchType.name:
        return TextInputType.text;
    }
  }

  // 根據搜索類型獲取提示文字
  String _getHintText() {
    switch (_selectedSearchType) {
      case SearchType.name:
        return '請輸入好友的姓名';
      case SearchType.email:
        return '請輸入好友的信箱地址';
      case SearchType.phone:
        return '請輸入好友的電話號碼';
    }
  }

  // 根據搜索類型獲取圖標
  IconData _getIcon() {
    switch (_selectedSearchType) {
      case SearchType.name:
        return Icons.person;
      case SearchType.email:
        return Icons.email;
      case SearchType.phone:
        return Icons.phone;
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
              '請輸入好友信息並選擇搜索類型',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 搜索輸入框
            TextFormField(
              controller: _searchController,
              keyboardType: _getKeyboardType(),
              decoration: InputDecoration(
                labelText: '請輸入${_selectedSearchType.displayName}',
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(_getIcon(), color: AppColors.primary),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return '請輸入${_selectedSearchType.displayName}';
                }
                
                // 根據搜索類型進行格式驗證
                switch (_selectedSearchType) {
                  case SearchType.email:
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value!)) {
                      return '請輸入有效的信箱格式';
                    }
                    break;
                  case SearchType.phone:
                    final phoneRegex = RegExp(r'^[\+]?[0-9\-\s\(\)]{8,}$');
                    if (!phoneRegex.hasMatch(value!)) {
                      return '請輸入有效的電話格式';
                    }
                    break;
                  case SearchType.name:
                    if (value!.trim().length < 2) {
                      return '姓名至少需要2個字符';
                    }
                    break;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 搜索類型選擇器
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '搜索類型',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: SearchType.values.map((type) {
                      return Expanded(
                        child: RadioListTile<SearchType>(
                          title: Text(
                            type.displayName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: type,
                          groupValue: _selectedSearchType,
                          onChanged: (value) {
                            setState(() {
                              _selectedSearchType = value!;
                              _searchController.clear(); // 清空輸入框
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
