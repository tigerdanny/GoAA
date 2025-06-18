import 'dart:async';
import 'dart:math';

/// 好友搜尋結果模型
class FriendSearchResult {
  final String name;
  final String userCode;
  final String email;
  final String? phone;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;

  FriendSearchResult({
    required this.name,
    required this.userCode,
    required this.email,
    this.phone,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
  });
}

/// 好友搜尋服務
class FriendSearchService {
  static final FriendSearchService _instance = FriendSearchService._internal();
  factory FriendSearchService() => _instance;
  FriendSearchService._internal();

  // 模擬的用戶數據庫
  final List<FriendSearchResult> _mockUsers = [
    FriendSearchResult(
      name: '張小明',
      userCode: 'GA001234',
      email: 'zhang@example.com',
      phone: '+886 912345678',
      avatar: 'assets/images/goaa_logo.png',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    FriendSearchResult(
      name: '李小花',
      userCode: 'GA005678',
      email: 'li@example.com',
      phone: '+886 987654321',
      avatar: 'assets/images/goaa_logo.png',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FriendSearchResult(
      name: '王大力',
      userCode: 'GA009876',
      email: 'wang@example.com',
      avatar: 'assets/images/goaa_logo.png',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    FriendSearchResult(
      name: '陳美麗',
      userCode: 'GA543210',
      email: 'chen@example.com',
      phone: '+886 955666777',
      avatar: 'assets/images/goaa_logo.png',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FriendSearchResult(
      name: 'John Smith',
      userCode: 'GA112233',
      email: 'john@example.com',
      avatar: 'assets/images/goaa_logo.png',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  /// 根據姓名或用戶代碼搜尋好友
  Future<List<FriendSearchResult>> searchFriends(String query) async {
    // 模擬網路延遲
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));

    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    
    return _mockUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
             user.userCode.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 根據用戶代碼精確搜尋用戶
  Future<FriendSearchResult?> searchByUserCode(String userCode) async {
    // 模擬網路延遲
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(700)));

    try {
      return _mockUsers.firstWhere(
        (user) => user.userCode.toLowerCase() == userCode.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 檢查用戶代碼是否存在
  Future<bool> isUserCodeValid(String userCode) async {
    final result = await searchByUserCode(userCode);
    return result != null;
  }
} 
