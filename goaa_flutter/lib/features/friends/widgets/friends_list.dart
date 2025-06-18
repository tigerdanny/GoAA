import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';
import 'friends_empty_state.dart';
import 'friend_card.dart';

/// 好友列表组件
class FriendsList extends StatelessWidget {
  final List<OnlineUser> friends;
  final Function(OnlineUser) onFriendTap;
  final Function(String, OnlineUser) onMenuAction;

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
          user: friend,
          isFriend: true, // 在好友列表中，都是已確認的好友
          onOpenChat: () => onFriendTap(friend),
        );
      },
    );
  }
} 
