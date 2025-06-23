import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/database/database.dart';
import '../managers/profile_avatar_manager.dart';
import '../managers/profile_user_manager.dart';

/// 個人資料控制器 - 重構版
class ProfileController extends ChangeNotifier {
  // 管理器
  final ProfileAvatarManager _avatarManager = ProfileAvatarManager();
  final ProfileUserManager _userManager = ProfileUserManager();
  
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSaving => _avatarManager.isSaving || _userManager.isSaving;
  String? get userName => _currentUser?.name;
  String? get userCode => _currentUser?.userCode;
  
  // 頭像管理器相關
  ProfileAvatarManager get avatarManager => _avatarManager;
  ProfileUserManager get userManager => _userManager;
  
  /// 獲取頭像路徑（委託給頭像管理器）
  String? get avatarPath => _avatarManager.getAvatarPath(_currentUser);

  /// 初始化
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentUser = await _userManager.getCurrentUser();
      
      // 設置管理器的監聽器
      _avatarManager.addListener(_onManagerChanged);
      _userManager.addListener(_onManagerChanged);
      
      notifyListeners();
    } catch (e) {
      debugPrint('初始化個人資料失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 管理器狀態變化處理
  void _onManagerChanged() {
    notifyListeners();
  }

  /// 更新用戶名稱（委託給用戶管理器）
  Future<bool> updateUserName(String name) async {
    if (_currentUser == null) return false;
    
    final updatedUser = await _userManager.updateUserName(_currentUser!, name);
    if (updatedUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 更新用戶信息（包含名稱、邮箱、手机号码等）
  Future<bool> updateUserInfo({
    String? name,
    String? email,
    String? phone,
    String? avatarType,
    String? avatarSource,
  }) async {
    if (_currentUser == null) return false;
    
    final success = await _userManager.updateUserInfo(_currentUser!, 
      name: name,
      email: email,
      phone: phone,
      avatarType: avatarType,
      avatarSource: avatarSource,
    );
    
    if (success) {
      // 重新獲取更新後的用戶數據
      await refresh();
      return true;
    }
    return false;
  }

  /// 更新頭像（委託給頭像管理器）
  Future<bool> updateAvatar(String? avatarPath, {bool isCustom = false}) async {
    if (_currentUser == null) return false;
    
    final success = await _avatarManager.updateAvatar(_currentUser!, avatarPath, isCustom: isCustom);
    if (success) {
      // 重新獲取用戶數據以確保同步
      await refresh();
    }
    return success;
  }

  /// 選擇頭像（委託給頭像管理器）
  Future<void> selectAvatar(BuildContext context) async {
    await _avatarManager.selectAvatar(context, _currentUser);
    if (_currentUser != null && !_avatarManager.hasTempAvatar) {
      // 如果有用戶且不是臨時頭像，刷新用戶數據
      await refresh();
    }
  }

  /// 創建新用戶（整合頭像管理器和用戶管理器）
  Future<bool> createUser({
    required String name,
    String? userCode,
    String? email,
    String? phone,
    String avatarType = 'male_01',
    String? avatarSource,
  }) async {
    if (name.trim().isEmpty) return false;

    // 獲取頭像參數（如果有臨時頭像的話）
    final avatarParams = _avatarManager.getAvatarParamsForCreation(avatarType);
    final finalAvatarType = avatarParams['avatarType'] as String;
    final finalAvatarSource = avatarParams['avatarSource'] as String?;
    
    debugPrint('🎯 創建用戶 - name: $name, avatarType: $finalAvatarType, avatarSource: $finalAvatarSource');

    // 創建用戶
    final newUser = await _userManager.createUser(
      name: name,
      userCode: userCode,
      email: email,
      phone: phone,
      avatarType: finalAvatarType,
      avatarSource: finalAvatarSource,
    );

    if (newUser != null) {
      _currentUser = newUser;
      
      // 清除臨時頭像
      _avatarManager.clearTempAvatar();
      
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 刷新用戶數據
  Future<void> refresh() async {
    _setLoading(true);
    try {
      _currentUser = await _userManager.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('刷新用戶數據失敗: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 設置加載狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _avatarManager.removeListener(_onManagerChanged);
    _userManager.removeListener(_onManagerChanged);
    _avatarManager.dispose();
    _userManager.dispose();
    super.dispose();
  }
} 
