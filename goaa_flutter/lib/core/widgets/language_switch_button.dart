import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// 語言切換按鈕組件
/// 提供完整的語言選擇界面
class LanguageSwitchButton extends StatelessWidget {
  final bool showLabel;
  final MainAxisSize mainAxisSize;
  
  const LanguageSwitchButton({
    super.key,
    this.showLabel = false,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLanguageSelector(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: mainAxisSize,
                children: [
                  Icon(
                    Icons.language,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      languageService.currentLanguageDisplayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.expand_more,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 顯示語言選擇器
  void _showLanguageSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(l10n: l10n),
    );
  }
}

/// 語言選擇底部面板
class LanguageSelectorSheet extends StatelessWidget {
  final AppLocalizations? l10n;
  
  const LanguageSelectorSheet({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // 標題
              Text(
                l10n?.language ?? '語言',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              
              // 繁體中文選項
              _buildLanguageOption(
                context: context,
                languageService: languageService,
                locale: const Locale('zh'),
                title: l10n?.languageTraditionalChinese ?? '繁體中文',
                isSelected: languageService.isTraditionalChinese,
              ),
              
              const SizedBox(height: 12),
              
              // 英文選項
              _buildLanguageOption(
                context: context,
                languageService: languageService,
                locale: const Locale('en'),
                title: l10n?.languageEnglish ?? 'English',
                isSelected: languageService.isEnglish,
              ),
              
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  /// 構建語言選項
  Widget _buildLanguageOption({
    required BuildContext context,
    required LanguageService languageService,
    required Locale locale,
    required String title,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          try {
            await languageService.changeLanguage(locale);
            if (context.mounted) {
              Navigator.pop(context);
            }
          } catch (e) {
            debugPrint('❌ 語言切換失敗: $e');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 語言圖標
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.language,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // 語言文字
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              
              // 選中指示器
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 緊湊型語言切換按鈕
/// 用於應用欄等空間受限的場景
class CompactLanguageSwitchButton extends StatelessWidget {
  const CompactLanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleLanguage(context, languageService),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  languageService.isTraditionalChinese ? '中' : 'EN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 快速切換語言
  void _toggleLanguage(BuildContext context, LanguageService languageService) {
    HapticFeedback.lightImpact();
    final newLocale = languageService.isTraditionalChinese 
        ? const Locale('en') 
        : const Locale('zh');
    languageService.changeLanguage(newLocale);
  }
} 
