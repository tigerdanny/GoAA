import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// 頭像存儲管理器
class AvatarStorage {
  static const String _avatarKey = 'user_avatar';
  static const String _lastUpdateKey = 'avatar_last_update';
  
  /// 保存用戶頭像
  static Future<bool> saveUserAvatar(String avatarPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_avatarKey, avatarPath);
      
      if (success) {
        await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
      }
      
      return success;
    } catch (e) {
      debugPrint('保存頭像失敗: $e');
      return false;
    }
  }
  
  /// 獲取用戶頭像
  static Future<String?> getUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatarKey);
    } catch (e) {
      debugPrint('獲取頭像失敗: $e');
      return null;
    }
  }
  
  /// 清除用戶頭像
  static Future<bool> clearUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success1 = await prefs.remove(_avatarKey);
      final success2 = await prefs.remove(_lastUpdateKey);
      return success1 && success2;
    } catch (e) {
      debugPrint('清除頭像失敗: $e');
      return false;
    }
  }
  
  /// 獲取最後更新時間
  static Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastUpdateKey);
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      debugPrint('獲取更新時間失敗: $e');
      return null;
    }
  }
  
  /// 檢查是否有頭像
  static Future<bool> hasUserAvatar() async {
    final avatar = await getUserAvatar();
    return avatar != null && avatar.isNotEmpty;
  }
} 
