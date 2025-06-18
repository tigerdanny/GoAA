import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/features/home/home_screen.dart';
import 'package:goaa_flutter/l10n/generated/app_localizations.dart';
import 'controllers/profile_controller.dart';
import 'widgets/avatar_widget.dart';
import 'widgets/profile_form.dart';
import 'widgets/user_info_display.dart';

/// 個人資料頁面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.addListener(_onControllerChanged);
    _initializeProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 初始化個人資料
  Future<void> _initializeProfile() async {
    await _controller.initialize();
    
    // 如果有現有用戶，填充表單
    if (_controller.currentUser != null) {
      _nameController.text = _controller.userName ?? '';
      _userCodeController.text = _controller.userCode ?? '';
      _emailController.text = _controller.currentUser?.email ?? '';
      _phoneController.text = _controller.currentUser?.phone ?? '';
    }
  }

  /// 控制器狀態變化處理
  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 保存個人資料
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final userCode = _userCodeController.text.trim();

    bool success;
    if (_controller.currentUser != null) {
      // 更新現有用戶
      success = await _controller.updateUserName(name);
      // 注意：userCode 更新被禁用了，所以跳過
    } else {
      // 創建新用戶
      success = await _controller.createUser(
        name: name,
        userCode: userCode,
        avatarType: 'male_01', // 默認頭像
      );
    }

    if (success && mounted) {
      _showSuccessMessage();
      _navigateNext();
    } else if (mounted) {
      _showErrorMessage();
    }
  }

  /// 顯示成功訊息
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('個人資料已儲存'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// 顯示錯誤訊息
  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('儲存失敗，請重試'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// 導航到下一頁
  void _navigateNext() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  /// 更換頭像
  Future<void> _changeAvatar() async {
    HapticFeedback.lightImpact();
    await _controller.selectAvatar(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.userProfile ?? '個人資料'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
              )
            : null,
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      
                      // 頭像區域
                      AvatarWidget(
                        avatarPath: _controller.avatarPath,
                        size: 120,
                        onTap: _changeAvatar,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        '點擊更換頭像',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 個人資料表單
                      ProfileForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 保存按鈕
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _controller.isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _controller.isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _controller.currentUser != null ? '更新資料' : '完成設置',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 用戶信息顯示（如果有現有用戶）
                      if (_controller.currentUser != null)
                        UserInfoDisplay(
                          userId: _controller.currentUser!.id.toString(),
                          userCode: _controller.currentUser!.userCode,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
