import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/database.dart';
import '../../../core/services/avatar_service.dart';

/// 個人資料用戶管理器
class ProfileUserManager extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  
  bool _isSaving = false;

  // Getters
  bool get isSaving => _isSaving;

  /// 生成唯一的用戶代碼
  String generateUserCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final randomPart = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return 'U${timestamp.toString().padLeft(4, '0')}$randomPart';
  }

  /// 創建新用戶
  Future<User?> createUser({
    required String name,
    String? userCode,
    String avatarType = 'male_01',
    String? avatarSource,
  }) async {
    if (name.trim().isEmpty) return null;

    // 如果沒有提供用戶代碼，則自動生成
    final finalUserCode = userCode?.trim().isNotEmpty == true ? userCode!.trim() : generateUserCode();

    _setSaving(true);
    try {
      final userId = await _userRepository.createUser(
        userCode: finalUserCode,
        name: name.trim(),
        avatarType: avatarType,
        avatarSource: avatarSource,
        isCurrentUser: true,
      );

      if (userId > 0) {
        // 重新獲取創建的用戶
        final newUser = await _userRepository.getCurrentUser();
        
        // 保存頭像到 AvatarService
        if (avatarSource != null) {
          await AvatarService.saveUserAvatar(avatarSource);
        }
        
        return newUser;
      }
      return null;
    } catch (e) {
      debugPrint('創建用戶失敗: $e');
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// 更新用戶名稱
  Future<User?> updateUserName(User currentUser, String name) async {
    if (name.trim().isEmpty) return null;

    _setSaving(true);
    try {
      final success = await _userRepository.updateUser(
        currentUser.id,
        name: name.trim(),
      );
      
      if (success) {
        final updatedUser = currentUser.copyWith(
          name: name.trim(),
          updatedAt: DateTime.now(),
        );
        return updatedUser;
      }
      return null;
    } catch (e) {
      debugPrint('更新用戶名稱失敗: $e');
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// 獲取當前用戶
  Future<User?> getCurrentUser() async {
    try {
      return await _userRepository.getCurrentUser();
    } catch (e) {
      debugPrint('獲取當前用戶失敗: $e');
      return null;
    }
  }

  /// 設置保存狀態
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }
}
