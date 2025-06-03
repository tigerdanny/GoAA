import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// 關於應用頁面
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.about ?? '關於應用'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 應用Logo
              _buildAppLogo(),
              const SizedBox(height: 32),
              
              // 應用信息
              _buildAppInfo(l10n),
              const SizedBox(height: 32),
              
              // 開發者信息
              _buildDeveloperInfo(l10n, context),
              const SizedBox(height: 32),
              
              // 聯繫按鈕
              _buildContactButtons(l10n, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/images/goaa_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAppInfo(AppLocalizations? l10n) {
    return Column(
      children: [
        Text(
          l10n?.appName ?? 'GOAA分帳神器',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.appDescription ?? '跨平台分帳應用，讓分帳變得簡單優雅',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${l10n?.version ?? "版本"} 1.0.0',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo(AppLocalizations? l10n, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.developer ?? '開發者',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person,
            l10n?.developerName ?? 'Danny Wang',
            context,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.business,
            '獨立開發者',
            context,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_city,
            '台灣',
            context,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            l10n?.developmentDateValue ?? '2025年6月',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactButtons(AppLocalizations? l10n, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _contactDeveloper(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.email_outlined),
            label: Text(
              l10n?.contactDeveloper ?? '聯繫開發者',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPrivacyPolicy(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.privacy_tip_outlined, size: 20),
                label: Text(l10n?.privacy ?? '隱私政策'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showTermsOfService(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.description_outlined, size: 20),
                label: Text(l10n?.terms ?? '使用條款'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _contactDeveloper() {
    HapticFeedback.lightImpact();
    //實現聯繫開發者功能（打開郵件應用）
  }

  void _showPrivacyPolicy(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('隱私政策'),
        content: const SingleChildScrollView(
          child: Text(
            'GOAA分帳神器尊重並保護您的隱私。我們不會收集、存儲或分享您的個人敏感信息。所有數據均存儲在您的設備本地。\n\n如有任何疑問，請聯繫開發者。',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('了解', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('使用條款'),
        content: const SingleChildScrollView(
          child: Text(
            'GOAA分帳神器是一款免費的分帳應用。使用本應用即表示您同意以下條款：\n\n1. 本應用僅供個人非商業用途\n2. 請合理使用，不得用於非法目的\n3. 數據安全由用戶自行負責\n4. 開發者不承擔數據丟失責任\n\n感謝您的使用！',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('同意', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
} 
