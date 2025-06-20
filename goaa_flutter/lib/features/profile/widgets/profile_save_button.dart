import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 個人資料保存按鈕組件
class ProfileSaveButton extends StatelessWidget {
  final bool isSaving;
  final bool hasCurrentUser;
  final VoidCallback onPressed;

  const ProfileSaveButton({
    super.key,
    required this.isSaving,
    required this.hasCurrentUser,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                hasCurrentUser ? '更新資料' : '完成設置',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 
