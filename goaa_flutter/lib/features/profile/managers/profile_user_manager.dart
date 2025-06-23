import 'package:flutter/material.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/database.dart';
import '../../../core/services/avatar_service.dart';
import 'package:uuid/uuid.dart';

/// 個人資料用戶管理器
class ProfileUserManager extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  static const Uuid _uuid = Uuid();
  
  bool _isSaving = false;

  // Getters
  bool get isSaving => _isSaving;

  /// 創建新用戶（帶重試機制）
  Future<User?> createUser({
    required String name,
    String? userCode,
    String? email,
    String? phone,
    String avatarType = 'male_01',
    String? avatarSource,
  }) async {
    if (name.trim().isEmpty) return null;

    _setSaving(true);
    try {
      // 如果提供了用戶代碼，直接使用
      if (userCode?.trim().isNotEmpty == true) {
        return await _attemptCreateUser(
          userCode: userCode!.trim(),
          name: name.trim(),
          email: email,
          phone: phone,
          avatarType: avatarType,
          avatarSource: avatarSource,
        );
      }

      // 沒有提供用戶代碼時，嘗試多次生成唯一代碼
      for (int attempt = 1; attempt <= 5; attempt++) {
        final generatedCode = _generateNewUserCode();
        debugPrint('🔄 嘗試創建用戶 (第$attempt次): $generatedCode');
        
        try {
          final user = await _attemptCreateUser(
            userCode: generatedCode,
            name: name.trim(),
            email: email,
            phone: phone,
            avatarType: avatarType,
            avatarSource: avatarSource,
          );
          
          if (user != null) {
            debugPrint('✅ 用戶創建成功: ${user.name} (${user.userCode})');
            return user;
          }
        } catch (e) {
          debugPrint('⚠️ 第$attempt次嘗試失敗: $e');
          if (attempt == 5) {
            rethrow; // 最後一次嘗試失敗時拋出異常
          }
          // 其他嘗試失敗時繼續下一次
        }
      }
      
      debugPrint('❌ 所有嘗試都失敗，無法創建用戶');
      return null;
      
    } catch (e) {
      debugPrint('創建用戶失敗: $e');
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// 嘗試創建用戶的內部方法
  Future<User?> _attemptCreateUser({
    required String userCode,
    required String name,
    String? email,
    String? phone,
    required String avatarType,
    String? avatarSource,
  }) async {
    final userId = await _userRepository.createUser(
      userCode: userCode,
      name: name,
      email: email,
      phone: phone,
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

  /// 更新用戶信息（包含名稱、邮箱、手机号码等）
  Future<bool> updateUserInfo(User currentUser, {
    String? name,
    String? email,
    String? phone,
    String? avatarType,
    String? avatarSource,
  }) async {
    _setSaving(true);
    try {
      final success = await _userRepository.updateUser(
        currentUser.id,
        name: name?.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        avatarType: avatarType,
        avatarSource: avatarSource,
      );
      
      if (success) {
        debugPrint('✅ 用戶信息更新成功');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('更新用戶信息失敗: $e');
      return false;
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

  /// 生成新的用戶代碼（每次調用都生成不同的UUID）
  String _generateNewUserCode() {
    return _uuid.v4().replaceAll('-', '');
  }

  /// 設置保存狀態
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }
}
