import 'package:flutter/foundation.dart';
import 'package:goaa_flutter/core/database/repositories/user_repository.dart';
import 'package:goaa_flutter/core/database/database.dart';

/// 帳戶設置控制器
class AccountSettingsController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get userName => _currentUser?.name;
  String? get userCode => _currentUser?.userCode;
  String? get avatarType => _currentUser?.avatarType;
  String? get avatarSource => _currentUser?.avatarSource;
  
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
      debugPrint('初始化帳戶設置失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用戶信息
  Future<bool> updateUserInfo({
    String? name,
    String? email,
    String? phone,
    String? avatarType,
    String? avatarSource,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    try {
      final success = await _userRepository.updateUser(
        _currentUser!.id,
        name: name,
        email: email,
        phone: phone,
        avatarType: avatarType,
        avatarSource: avatarSource,
      );

      if (success) {
        // 重新獲取更新後的用戶數據
        _currentUser = await _userRepository.getCurrentUser();
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('更新用戶信息失敗: $e');
      return false;
    } finally {
      _setLoading(false);
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
} 
