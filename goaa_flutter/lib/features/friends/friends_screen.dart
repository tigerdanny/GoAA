import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/theme/app_dimensions.dart';
import 'package:goaa_flutter/core/services/mqtt/mqtt_models.dart';
import 'controllers/friends_controller.dart';
import 'widgets/friends_list_view.dart';
import 'widgets/friend_request_dialog.dart';
import 'dart:async';

/// 好友資訊頁面
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  late FriendsController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = FriendsController();
    _initializeController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller.reconnect();
    }
  }

  /// 初始化控制器
  Future<void> _initializeController() async {
    // 控制器會自動初始化
  }

  /// 搜索變化處理
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _controller.searchUsers(query);
    } else {
      _controller.clearSearch();
    }
    setState(() {});
  }



  /// 發送好友請求
  void _sendFriendRequest(OnlineUser user) {
    FriendRequestDialogs.showAddFriendDialog(
      context,
      user,
      () async {
        await _controller.sendFriendRequest(user.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已向 ${user.userName} 發送好友請求'),
              backgroundColor: AppColors.success,
            ),
          );
          HapticFeedback.lightImpact();
        }
      },
    );
  }

  /// 顯示好友請求列表
  void _showFriendRequestsList() {
    FriendRequestDialogs.showFriendRequestsList(
      context,
      _controller.friendRequests,
      (String userId) {
        // 根據 userId 找到對應的請求
        final request = _controller.friendRequests.firstWhere(
          (req) => req.fromUserId == userId,
        );
        _controller.acceptFriendRequest(request);
      },
      (String userId) {
        // 根據 userId 找到對應的請求
        final request = _controller.friendRequests.firstWhere(
          (req) => req.fromUserId == userId,
        );
        _controller.rejectFriendRequest(request);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          // 只在有好友且未連接時顯示連接指示器
          if (_controller.hasFriends && !_controller.isConnected) _buildConnectingIndicator(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// 構建應用欄
  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Text('好友'),
          // 只在有好友時顯示在線狀態
          if (_controller.hasFriends) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _controller.isConnected ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _controller.isConnected ? '在線' : '離線',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _controller.isConnected ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_controller.friendRequests.isNotEmpty) _buildNotificationBadge(),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller.reconnect,
        ),
      ],
    );
  }

  /// 構建通知徽章
  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showFriendRequestsList,
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              '${_controller.friendRequests.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// 構建搜索欄
  Widget _buildSearchBar() {
    return Container(
      padding: AppDimensions.paddingM,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索用戶 (姓名或用戶代碼)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _controller.clearSearch();
                  },
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  /// 構建連接指示器
  Widget _buildConnectingIndicator() {
    return const Padding(
      padding: AppDimensions.paddingM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('正在連接到網絡...'),
        ],
      ),
    );
  }

  /// 構建內容區域
  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        // 如果在搜索模式
        if (_searchController.text.trim().isNotEmpty) {
          return FriendsListView(
            users: _controller.searchResults.cast<OnlineUser>(),
            friends: _controller.friends,
            title: '',
            isSearching: _controller.isSearching,
            onAddFriend: _sendFriendRequest,
          );
        }

        // 如果沒有好友，顯示空狀態（不嘗試連接）
        if (!_controller.hasFriends) {
          return _buildNoFriendsState();
        }

        // 有好友但離線時，顯示離線狀態
        if (!_controller.isConnected) {
          return _buildOfflineState();
        }

        // 顯示好友列表
        return FriendsListView(
          users: _controller.getFriendUsers(),
          friends: _controller.friends,
          title: '好友列表 (${_controller.getFriendUsers().length})',
          onAddFriend: _sendFriendRequest,
        );
      },
    );
  }

  /// 構建無好友狀態
  Widget _buildNoFriendsState() {
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
            '尚無好友',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '使用搜索功能尋找並添加好友',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// 構建離線狀態（僅在有好友時顯示）
  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            '網絡連接失敗',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '無法連接到服務器\n好友上線狀態不可用',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _controller.reconnect,
            icon: const Icon(Icons.refresh),
            label: const Text('重新連接'),
          ),
        ],
      ),
    );
  }
} 
