import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/database.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/user_id_service.dart';
import '../../core/services/validation_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/avatar_widget.dart';
import 'widgets/profile_form.dart';
import 'widgets/user_info_display.dart';

/// 個人檔案頁面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final UserRepository _userRepository = UserRepository();
  final AvatarService _avatarService = AvatarService();
  final UserIdService _userIdService = UserIdService();
  
  User? _currentUser;
  String? _avatarPath;
  String? _avatarType;
  String? _userId;
  String? _userCode;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // 獲取用戶ID和代碼
      _userId = await _userIdService.getUserId();
      _userCode = await _userIdService.getUserCode();
      
      // 獲取當前用戶資料
      _currentUser = await _userRepository.getCurrentUser();
      
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _emailController.text = _currentUser!.email ?? '';
        _phoneController.text = _currentUser!.phone ?? '';
        _avatarType = _currentUser!.avatarType;
        _avatarPath = _currentUser!.avatarSource;
      } else {
        // 如果沒有用戶資料，設置預設值
        _avatarType = 'man_0';
      }
    } catch (e) {
      debugPrint('載入用戶資料失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入用戶資料失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final name = ValidationService.sanitizeInput(_nameController.text);
      final email = _emailController.text.trim().isEmpty 
          ? null : _emailController.text.trim();
      final phone = _phoneController.text.trim().isEmpty 
          ? null : _phoneController.text.trim();

      if (_currentUser != null) {
        // 更新現有用戶
        await _userRepository.updateUser(
          _currentUser!.id,
          name: name,
          email: email,
          phone: phone,
          avatarType: _avatarType,
          avatarSource: _avatarPath,
        );
      } else {
        // 創建新用戶
        await _userRepository.createUser(
          userCode: _userCode!,
          name: name,
          email: email,
          phone: phone,
          avatarType: _avatarType!,
          avatarSource: _avatarPath,
          isCurrentUser: true,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('個人資料已儲存'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // 重新載入資料
        await _loadUserData();
      }
    } catch (e) {
      debugPrint('儲存用戶資料失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changeAvatar() async {
    HapticFeedback.lightImpact();
    
    final result = await _avatarService.showAvatarPicker(context);
    if (result != null) {
      setState(() {
        if (result.startsWith('/')) {
          // 自定義頭像路徑
          _avatarPath = result;
          _avatarType = null;
        } else {
          // 預設頭像類型
          _avatarType = result;
          _avatarPath = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.personalInfo ?? '個人檔案'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveUserProfile,
              child: Text(
                l10n?.save ?? '儲存',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 頭像部分
                      AvatarWidget(
                        avatarType: _avatarType,
                        avatarPath: _avatarPath,
                        onTap: _changeAvatar,
                      ),
                      const SizedBox(height: 32),
                      
                      // 用戶ID信息
                      if (_userId != null && _userCode != null)
                        UserInfoDisplay(
                          userId: _userId!,
                          userCode: _userCode!,
                        ),
                      const SizedBox(height: 24),
                      
                      // 表單
                      ProfileForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                      ),
                      const SizedBox(height: 32),
                      
                      // 儲存按鈕
                      _buildSaveButton(l10n),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSaveButton(AppLocalizations? l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveUserProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n?.save ?? '儲存',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
