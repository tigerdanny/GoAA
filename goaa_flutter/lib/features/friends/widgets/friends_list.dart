import 'package:flutter/material.dart';
import 'friends_empty_state.dart';
import 'friend_card.dart';

/// 好友列表组件
class FriendsList extends StatelessWidget {
  final List<Map<String, String>> friends;
  final Function(Map<String, String>) onFriendTap;
  final Function(String, Map<String, String>) onMenuAction;

  const FriendsList({
    super.key,
    required this.friends,
    required this.onFriendTap,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const FriendsEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendCard(
          friend: friend,
          index: index,
          onTap: () => onFriendTap(friend),
          onMenuAction: (action) => onMenuAction(action, friend),
        );
      },
    );
  }
} 
