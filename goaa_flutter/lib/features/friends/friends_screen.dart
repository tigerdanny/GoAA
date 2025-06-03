import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/index.dart';

/// 好友資訊頁面
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, String>> _friends = [
    {
      'name': '室友小王',
      'userCode': 'GA123456',
      'email': 'wang@example.com',
      'phone': '+886 912345678',
      'avatar': 'assets/images/goaa_logo.png',
    },
    {
      'name': '室友小李',
      'userCode': 'GA789012',
      'email': 'li@example.com',
      'phone': '+886 987654321',
      'avatar': 'assets/images/goaa_logo.png',
    },
  ];

  List<Map<String, String>> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _friends;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends.where((friend) {
          return friend['name']!.toLowerCase().contains(query.toLowerCase()) ||
                 friend['userCode']!.toLowerCase().contains(query.toLowerCase()) ||
                 friend['email']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: FriendsAppBar(onAddFriend: _addFriend),
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            FriendsSearchBar(
              controller: _searchController,
              onChanged: _filterFriends,
            ),
            
            // 好友列表
            Expanded(
              child: FriendsList(
                friends: _filteredFriends,
                onFriendTap: _viewFriendDetail,
                onMenuAction: _handleFriendAction,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  void _addFriend() {
    HapticFeedback.lightImpact();
    AddFriendDialog.show(context, () {
      _showMessage('添加好友功能開發中...');
    });
  }

  void _scanQRCode() {
    HapticFeedback.lightImpact();
    _showMessage('掃描二維碼功能開發中...');
  }

  void _viewFriendDetail(Map<String, String> friend) {
    HapticFeedback.lightImpact();
    _showMessage('查看好友詳情功能開發中...');
  }

  void _handleFriendAction(String action, Map<String, String> friend) {
    switch (action) {
      case 'view':
        _viewFriendDetail(friend);
        break;
      case 'edit':
        _showMessage('編輯好友功能開發中...');
        break;
      case 'delete':
        _confirmDeleteFriend(friend);
        break;
    }
  }

  void _confirmDeleteFriend(Map<String, String> friend) {
    DeleteConfirmDialog.show(context, friend, () {
      setState(() {
        _friends.remove(friend);
        _filteredFriends.remove(friend);
      });
      _showMessage('已刪除好友');
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 
