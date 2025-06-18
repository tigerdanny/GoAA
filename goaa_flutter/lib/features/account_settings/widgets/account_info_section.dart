import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goaa_flutter/core/theme/app_colors.dart';

/// 帳戶信息區塊
class AccountInfoSection extends StatelessWidget {
  final String? userName;
  final String? userCode;
  final String? avatarPath;
  final VoidCallback? onEditProfile;

  const AccountInfoSection({
    super.key,
    this.userName,
    this.userCode,
    this.avatarPath,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '帳戶信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 用戶頭像和基本信息
            Row(
              children: [
                // 頭像
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: avatarPath != null && avatarPath!.isNotEmpty
                      ? (avatarPath!.startsWith('assets/')
                          ? AssetImage(avatarPath!) as ImageProvider
                          : FileImage(File(avatarPath!)))
                      : null,
                  child: avatarPath == null || avatarPath!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // 用戶信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? '未設置',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${userCode ?? '未設置'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 編輯按鈕
                IconButton(
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit),
                  tooltip: '編輯個人資料',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
