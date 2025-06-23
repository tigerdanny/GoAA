import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/validation_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'form_field_builder.dart';
import 'phone_number_formatter.dart';

/// 個人資料表單組件
class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.personalInfo ?? '個人資訊',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        // 使用者名稱（必填）
        ProfileFieldBuilder.buildTextField(
          controller: nameController,
          label: '${l10n?.name ?? '使用者名稱'} *',
          icon: Icons.person_outline,
          isRequired: true,
          maxLength: 20,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'''[<>"';\\]''')),
          ],
          validator: ValidationService.validateUsername,
          helpText: '最多10個中文字符或20個英文字符',
          selectAllOnTap: true,
        ),
        const SizedBox(height: 16),
        
        // 電子郵件（選填）
        ProfileFieldBuilder.buildTextField(
          controller: emailController,
          label: l10n?.email ?? '電子郵件',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: ValidationService.validateEmail,
          helpText: '選填，用於接收重要通知',
        ),
        const SizedBox(height: 16),
        
        // 手機號碼（選填）
        ProfileFieldBuilder.buildTextField(
          controller: phoneController,
          label: '手機號碼',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            PhoneNumberFormatter(),
          ],
          validator: ValidationService.validatePhone,
          helpText: '選填，格式：0912-345-678',
        ),
      ],
    );
  }
} 
