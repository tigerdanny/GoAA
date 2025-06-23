import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/mqtt/mqtt_models.dart';

/// 用戶搜索結果對話框
class SearchResultsDialog extends StatelessWidget {
  final List<UserSearchResult> searchResults;
  final Function(UserSearchResult) onSendRequest;
  final bool isLoading;

  const SearchResultsDialog({
    super.key,
    required this.searchResults,
    required this.onSendRequest,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '搜索結果',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _buildContent(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('關閉', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              '正在搜索用戶...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到匹配的用戶',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '請嘗試其他搜索條件',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.divider,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _buildUserItem(context, user);
      },
    );
  }

  Widget _buildUserItem(BuildContext context, UserSearchResult user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.userName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.email?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.email!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (user.phone?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  user.phone!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.analytics, size: 14, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                '匹配度: ${(user.matchScore * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          onSendRequest(user);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          '添加',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 
