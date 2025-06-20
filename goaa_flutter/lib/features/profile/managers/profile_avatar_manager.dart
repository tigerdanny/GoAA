import 'package:flutter/material.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/database.dart';
import '../../../core/services/avatar_service.dart';

/// 個人資料頭像管理器
class ProfileAvatarManager extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AvatarService _avatarService = AvatarService();
  
  // 臨時頭像存儲（用於初次創建用戶時）
  String? _tempAvatarPath;
  bool _tempIsCustomAvatar = false;
  bool _isSaving = false;

  // Getters
  String? get tempAvatarPath => _tempAvatarPath;
  bool get tempIsCustomAvatar => _tempIsCustomAvatar;
  bool get isSaving => _isSaving;
  bool get hasTempAvatar => _tempAvatarPath != null && _tempAvatarPath!.isNotEmpty;

  /// 獲取頭像路徑（優先使用臨時頭像，然後是用戶頭像）
  String? getAvatarPath(User? currentUser) {
    // 如果有臨時頭像（初次創建用戶時），優先使用臨時頭像
    if (_tempAvatarPath != null && _tempAvatarPath!.isNotEmpty) {
      return _tempAvatarPath;
    }
    
    // 如果有用戶資料，使用用戶的頭像
    if (currentUser?.avatarSource != null && currentUser!.avatarSource!.isNotEmpty) {
      return currentUser.avatarSource;
    }
    if (currentUser?.avatarType != null && currentUser!.avatarType.isNotEmpty) {
      return 'assets/images/${currentUser.avatarType}.png';
    }
    return null;
  }

  /// 選擇頭像
  Future<void> selectAvatar(BuildContext context, User? currentUser) async {
    try {
      final selectedAvatar = await _avatarService.showAvatarPicker(context);
      if (selectedAvatar != null) {
        // 判斷是否為自定義頭像（通常自定義頭像路徑包含文件擴展名）
        final isCustom = selectedAvatar.contains('.') && 
                        (selectedAvatar.endsWith('.jpg') || 
                         selectedAvatar.endsWith('.png') || 
                         selectedAvatar.endsWith('.jpeg'));
        
        if (currentUser != null) {
          // 如果已有用戶，直接更新頭像
          await updateAvatar(currentUser, selectedAvatar, isCustom: isCustom);
        } else {
          // 如果沒有用戶（初次創建），先暫存頭像
          _tempAvatarPath = selectedAvatar;
          _tempIsCustomAvatar = isCustom;
          debugPrint('🔄 暫存頭像: $_tempAvatarPath (自定義: $_tempIsCustomAvatar)');
          notifyListeners(); // 通知UI更新
        }
      }
    } catch (e) {
      debugPrint('選擇頭像失敗: $e');
    }
  }

  /// 更新用戶頭像
  Future<bool> updateAvatar(User currentUser, String? avatarPath, {bool isCustom = false}) async {
    _setSaving(true);
    try {
      final success = await _userRepository.updateUser(
        currentUser.id,
        avatarType: isCustom ? currentUser.avatarType : avatarPath,
        avatarSource: isCustom ? avatarPath : null,
      );
      
      if (success) {
        // 同時保存到 AvatarService
        if (avatarPath != null) {
          await AvatarService.saveUserAvatar(avatarPath);
        } else {
          await AvatarService.clearUserAvatar();
        }
      }
      return success;
    } catch (e) {
      debugPrint('更新頭像失敗: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// 獲取創建用戶時的頭像參數
  Map<String, dynamic> getAvatarParamsForCreation(String defaultAvatarType) {
    if (_tempAvatarPath != null && _tempAvatarPath!.isNotEmpty) {
      if (_tempIsCustomAvatar) {
        return {
          'avatarType': defaultAvatarType,
          'avatarSource': _tempAvatarPath,
        };
      } else {
        return {
          'avatarType': _tempAvatarPath!,
          'avatarSource': null,
        };
      }
    }
    
    return {
      'avatarType': defaultAvatarType,
      'avatarSource': null,
    };
  }

  /// 清除臨時頭像
  void clearTempAvatar() {
    _tempAvatarPath = null;
    _tempIsCustomAvatar = false;
    notifyListeners();
  }

  /// 設置保存狀態
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }
}
