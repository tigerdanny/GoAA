import 'package:flutter/material.dart';
import 'avatar_widget.dart';

/// 個人資料頭像區域組件
class ProfileAvatarSection extends StatelessWidget {
  final String? avatarPath;
  final VoidCallback onTap;

  const ProfileAvatarSection({
    super.key,
    required this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        
        // 頭像區域
        AvatarWidget(
          avatarPath: avatarPath,
          size: 120,
          onTap: onTap,
        ),
        
        const SizedBox(height: 48),
      ],
    );
  }
} 
