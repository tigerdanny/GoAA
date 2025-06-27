import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/core/theme/app_dimensions.dart';
import 'controllers/friends_controller.dart';
import 'widgets/friends_list_view.dart';
import 'widgets/add_friend_dialog.dart';
import 'widgets/search_results_dialog.dart';
import 'widgets/search_progress_dialog.dart';
import 'dart:async';

/// 好友資訊頁面
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with WidgetsBindingObserver {
  late FriendsController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = FriendsController();
    _initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller.reconnect?.call();
    }
  }

  /// 初始化控制器
  Future<void> _initializeController() async {
    await _controller.initialize();
  }

  /// 顯示添加好友對話框
  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddFriendDialog(
        onConfirm: (FriendSearchInfo searchInfo) async {
          // 顯示搜索進度對話框
          _showSearchProgressDialog(searchInfo);
        },
      ),
    );
  }

  /// 顯示搜索進度對話框
  void _showSearchProgressDialog(FriendSearchInfo searchInfo) {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止用戶在搜索過程中關閉
      builder: (dialogContext) => SearchProgressDialog(
        searchFuture: _controller.searchUsers(searchInfo),
        onSearchComplete: () {
          if (mounted) {
            // 搜索完成後顯示搜索結果對話框
            _showSearchResultsDialog();
          }
        },
      ),
    );
  }

  /// 顯示搜索結果對話框
  void _showSearchResultsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SearchResultsDialog(
            searchResults: _controller.searchResults,
            isLoading: _controller.isSearching,
            onSendRequest: (user) async {
              final success = await _controller.sendFriendRequestToUser(user);
              if (mounted && context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已向 ${user.userName} 發送好友請求'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  HapticFeedback.lightImpact();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('發送好友請求失敗，請重試'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
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
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: _showAddFriendDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _controller.reconnect?.call();
          },
        ),
      ],
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
        // 顯示好友列表和等待中的請求
        return FriendsListView(
          controller: _controller,
        );
      },
    );
  }
} 
