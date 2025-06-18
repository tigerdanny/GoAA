import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:goaa_flutter/core/database/repositories/user_repository.dart';
import 'package:goaa_flutter/core/database/database.dart';
import 'package:goaa_flutter/core/services/avatar_service.dart';

/// 個人資料控制器
class ProfileController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AvatarService _avatarService = AvatarService();
  
  User? _currentUser;
  bool _isLoading = false;
  bool _isSaving = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get userName => _currentUser?.name;
  String? get userCode => _currentUser?.userCode;
  
  /// 獲取頭像路徑（優先使用自定義頭像，否則使用預設頭像）
  String? get avatarPath {
    if (_currentUser?.avatarSource != null && _currentUser!.avatarSource!.isNotEmpty) {
      return _currentUser!.avatarSource;
    }
    if (_currentUser?.avatarType != null && _currentUser!.avatarType.isNotEmpty) {
      return 'assets/images/${_currentUser!.avatarType}.png';
    }
    return null;
  }

  /// 初始化
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('初始化個人資料失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用戶名稱
  Future<bool> updateUserName(String name) async {
    if (_currentUser == null || name.trim().isEmpty) return false;

    _setSaving(true);
    try {
      final success = await _userRepository.updateUser(
        _currentUser!.id,
        name: name.trim(),
      );
      
      if (success) {
        _currentUser = _currentUser!.copyWith(
          name: name.trim(),
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('更新用戶名稱失敗: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// 更新用戶代碼 - 注意：UserRepository 不支持更新 userCode
  Future<bool> updateUserCode(String userCode) async {
    // 由於 UserRepository.updateUser 不支持更新 userCode，
    // 這個功能可能需要在數據庫層面添加支持
    debugPrint('警告：當前不支持更新用戶代碼');
    return false;
  }

  /// 更新頭像
  Future<bool> updateAvatar(String? avatarPath, {bool isCustom = false}) async {
    if (_currentUser == null) return false;

    _setSaving(true);
    try {
      final success = await _userRepository.updateUser(
        _currentUser!.id,
        avatarType: isCustom ? _currentUser!.avatarType : avatarPath,
        avatarSource: isCustom ? avatarPath : null,
      );
      
      if (success) {
        _currentUser = _currentUser!.copyWith(
          avatarType: isCustom ? _currentUser!.avatarType : (avatarPath ?? 'male_01'),
          avatarSource: isCustom ? Value(avatarPath) : const Value(null),
          updatedAt: DateTime.now(),
        );
        
        // 同時保存到 AvatarService
        if (avatarPath != null) {
          await AvatarService.saveUserAvatar(avatarPath);
        } else {
          await AvatarService.clearUserAvatar();
        }
        
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('更新頭像失敗: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// 選擇頭像
  Future<void> selectAvatar(BuildContext context) async {
    try {
      final selectedAvatar = await _avatarService.showAvatarPicker(context);
      if (selectedAvatar != null) {
        // 判斷是否為自定義頭像（通常自定義頭像路徑包含文件擴展名）
        final isCustom = selectedAvatar.contains('.') && 
                        (selectedAvatar.endsWith('.jpg') || 
                         selectedAvatar.endsWith('.png') || 
                         selectedAvatar.endsWith('.jpeg'));
        await updateAvatar(selectedAvatar, isCustom: isCustom);
      }
    } catch (e) {
      debugPrint('選擇頭像失敗: $e');
    }
  }

  /// 創建新用戶
  Future<bool> createUser({
    required String name,
    required String userCode,
    String avatarType = 'male_01',
    String? avatarSource,
  }) async {
    if (name.trim().isEmpty || userCode.trim().isEmpty) return false;

    _setSaving(true);
    try {
      final userId = await _userRepository.createUser(
        userCode: userCode.trim(),
        name: name.trim(),
        avatarType: avatarType,
        avatarSource: avatarSource,
        isCurrentUser: true,
      );

      if (userId > 0) {
        // 重新獲取創建的用戶
        _currentUser = await _userRepository.getCurrentUser();
        
        // 保存頭像到 AvatarService
        if (avatarSource != null) {
          await AvatarService.saveUserAvatar(avatarSource);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('創建用戶失敗: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// 刷新用戶數據
  Future<void> refresh() async {
    await initialize();
  }

  /// 設置加載狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 設置保存狀態
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }
} 
