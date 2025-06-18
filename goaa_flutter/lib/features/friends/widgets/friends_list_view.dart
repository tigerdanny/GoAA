import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/theme/app_dimensions.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';
import 'friend_card.dart';

/// 好友列表視圖組件
class FriendsListView extends StatelessWidget {
  final List<OnlineUser> users;
  final List<String> friends;
  final String title;
  final bool isSearching;
  final Function(OnlineUser) onAddFriend;
  final Function(OnlineUser) onOpenChat;

  const FriendsListView({
    super.key,
    required this.users,
    required this.friends,
    required this.title,
    this.isSearching = false,
    required this.onAddFriend,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: AppDimensions.paddingM,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView.separated(
            padding: AppDimensions.paddingHorizontalM,
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => FriendCard(
              user: users[index],
              isFriend: friends.contains(users[index].userId),
              onAddFriend: () => onAddFriend(users[index]),
              onOpenChat: () => onOpenChat(users[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            '暫無用戶',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '當有用戶上線時會顯示在這裡',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 
