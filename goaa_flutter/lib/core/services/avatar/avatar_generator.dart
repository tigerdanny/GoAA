import 'package:flutter/foundation.dart';

/// 頭像生成器
class AvatarGenerator {
  /// 預設頭像類型
  static const List<String> _avatarCategories = ['cat', 'dog', 'girl', 'man'];
  static const int _avatarsPerCategory = 10;

  /// 獲取所有預設頭像
  static List<String> getAllDefaultAvatars() {
    final List<String> avatars = [];
    for (String category in _avatarCategories) {
      for (int i = 0; i < _avatarsPerCategory; i++) {
        avatars.add('${category}_$i');
      }
    }
    return avatars;
  }

  /// 根據分類獲取頭像
  static List<String> getAvatarsByCategory(String category) {
    if (!_avatarCategories.contains(category)) {
      debugPrint('警告: 未知的頭像分類: $category');
      return [];
    }
    
    final List<String> avatars = [];
    for (int i = 0; i < _avatarsPerCategory; i++) {
      avatars.add('${category}_$i');
    }
    return avatars;
  }

  /// 獲取頭像資源路徑
  static String getAvatarPath(String avatarType) {
    return 'assets/images/$avatarType.png';
  }

  /// 獲取可用的頭像分類
  static List<String> getAvailableCategories() {
    return List.from(_avatarCategories);
  }

  /// 獲取隨機頭像
  static String getRandomAvatar() {
    final allAvatars = getAllDefaultAvatars();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % allAvatars.length;
    return allAvatars[randomIndex];
  }

  /// 驗證頭像類型是否有效
  static bool isValidAvatarType(String avatarType) {
    return getAllDefaultAvatars().contains(avatarType);
  }

  /// 從頭像類型獲取分類
  static String? getCategoryFromAvatarType(String avatarType) {
    for (String category in _avatarCategories) {
      if (avatarType.startsWith('${category}_')) {
        return category;
      }
    }
    return null;
  }

  /// 獲取每個分類的頭像數量
  static int getAvatarsPerCategory() {
    return _avatarsPerCategory;
  }
}



