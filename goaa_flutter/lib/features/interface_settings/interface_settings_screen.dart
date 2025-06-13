import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/index.dart';

/// 介面設定頁面
class InterfaceSettingsScreen extends StatefulWidget {
  const InterfaceSettingsScreen({super.key});

  @override
  State<InterfaceSettingsScreen> createState() => _InterfaceSettingsScreenState();
}

class _InterfaceSettingsScreenState extends State<InterfaceSettingsScreen> {
  // 介面设定状态
  bool _darkMode = false;
  bool _useSystemTheme = true;
  String _fontSize = 'medium';
  String _colorTheme = 'default';
  bool _hapticFeedback = true;
  bool _animations = true;
  bool _showBalance = true;
  String _dateFormat = 'yyyy/MM/dd';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const InterfaceSettingsAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设定
              ThemeSettingsSection(
                useSystemTheme: _useSystemTheme,
                darkMode: _darkMode,
                colorTheme: _colorTheme,
                onUseSystemThemeChanged: (value) => setState(() => _useSystemTheme = value),
                onDarkModeChanged: (value) => setState(() => _darkMode = value),
                onColorThemeChanged: (value) => setState(() => _colorTheme = value!),
              ),
              const SizedBox(height: 24),
              
              // 字体设定
              FontSettingsSection(
                fontSize: _fontSize,
                onFontSizeChanged: (value) => setState(() => _fontSize = value!),
              ),
              const SizedBox(height: 24),
              
              // 交互设定
              InteractionSettingsSection(
                hapticFeedback: _hapticFeedback,
                animations: _animations,
                onHapticFeedbackChanged: (value) => setState(() => _hapticFeedback = value),
                onAnimationsChanged: (value) => setState(() => _animations = value),
              ),
              const SizedBox(height: 24),
              
              // 显示设定
              DisplaySettingsSection(
                showBalance: _showBalance,
                dateFormat: _dateFormat,
                onShowBalanceChanged: (value) => setState(() => _showBalance = value),
                onDateFormatChanged: (value) => setState(() => _dateFormat = value!),
              ),
              const SizedBox(height: 32),
              
              // 重置设定
              ResetSettingsSection(
                onReset: _resetSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _darkMode = false;
      _useSystemTheme = true;
      _fontSize = 'medium';
      _colorTheme = 'default';
      _hapticFeedback = true;
      _animations = true;
      _showBalance = true;
      _dateFormat = 'yyyy/MM/dd';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('介面設定已重置為預設值'),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 
