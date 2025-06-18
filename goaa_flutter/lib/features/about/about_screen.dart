import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/index.dart';

/// 關於應用頁面 - 簡潔版本
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 應用Logo和基本信息
              AppHeaderWidget(),
              SizedBox(height: 48),
              
              // 設計理念
              DesignPhilosophyWidget(),
              SizedBox(height: 32),
              
              // 開發資訊
              DevelopmentInfoWidget(),
              SizedBox(height: 32),
              
              // License信息
              LicenseInfoWidget(),
              SizedBox(height: 48),
              
              // 感謝訊息
              ThankYouMessageWidget(),
            ],
          ),
        ),
      ),
    );
  }
}



