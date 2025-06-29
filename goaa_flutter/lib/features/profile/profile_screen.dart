import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';
import 'package:goaa_flutter/features/home/home_screen.dart';
import 'controllers/profile_controller.dart';
import 'widgets/profile_app_bar.dart';
import 'widgets/profile_avatar_section.dart';
import 'widgets/profile_form.dart';
import 'widgets/profile_save_button.dart';

/// 個人資料頁面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    bool success;
    if (_controller.currentUser != null) {
      // 更新現有用戶 - 包含邮箱和手机号码
      success = await _controller.updateUserInfo(
        name: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
      );
    } else {
      // 創建新用戶（用戶代碼將自動生成）
      success = await _controller.createUser(
        name: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProfileAppBar(
        isLoading: _controller.isLoading,
        isSaving: _controller.isSaving,
        hasCurrentUser: _controller.currentUser != null,
        onSave: _saveProfile,
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
                      // 頭像區域
                      ProfileAvatarSection(
                        avatarPath: _controller.avatarPath,
                        onTap: _changeAvatar,
                      ),
                      
                      // 個人資料表單
                      ProfileForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 保存按鈕
                      ProfileSaveButton(
                        isSaving: _controller.isSaving,
                        hasCurrentUser: _controller.currentUser != null,
                        onPressed: _saveProfile,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 移除個人識別資訊顯示
                      // 用戶ID和用戶代碼已經在其他地方（如設置頁面）提供查看功能
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
