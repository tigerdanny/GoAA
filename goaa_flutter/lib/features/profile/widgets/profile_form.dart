import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/validation_service.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 手機號碼格式化器：自動插入破折號
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 移除所有非數字字符
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 如果長度超過10位，截斷
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }
    
    // 根據長度格式化
    String formattedText = '';
    if (newText.length >= 4) {
      formattedText = '${newText.substring(0, 4)}-';
      if (newText.length >= 7) {
        formattedText += '${newText.substring(4, 7)}-';
        if (newText.length > 7) {
          formattedText += newText.substring(7);
        }
      } else {
        formattedText += newText.substring(4);
      }
    } else {
      formattedText = newText;
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

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
        _buildTextField(
          controller: nameController,
          label: '${l10n?.name ?? '使用者名稱'} *',
          icon: Icons.person_outline,
          isRequired: true,
          maxLength: 20,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'''[<>"';\\]''')), // 過濾危險字符
          ],
          validator: ValidationService.validateUsername,
          helpText: '最多10個中文字符或20個英文字符',
          selectAllOnTap: true, // 點擊時全選文字
        ),
        const SizedBox(height: 16),
        
        // 電子郵件（選填）
        _buildTextField(
          controller: emailController,
          label: l10n?.email ?? '電子郵件',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: ValidationService.validateEmail,
          helpText: '選填，用於接收重要通知',
        ),
        const SizedBox(height: 16),
        
        // 手機號碼（選填）
        _buildTextField(
          controller: phoneController,
          label: '手機號碼',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            _PhoneNumberFormatter(),
          ],
          validator: ValidationService.validatePhone,
          helpText: '選填，格式：0912-345-678',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? helpText,
    bool selectAllOnTap = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            validator: validator,
            onTap: selectAllOnTap && controller.text.isNotEmpty 
                ? () => controller.selection = TextSelection(
                    baseOffset: 0, 
                    extentOffset: controller.text.length
                  )
                : null,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 20
              ),
              counterText: '', // 隱藏字符計數器
            ),
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              helpText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
