import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'interface_setting_items.dart';

/// 字体设置区段组件
class FontSettingsSection extends StatelessWidget {
  final String fontSize;
  final ValueChanged<String?> onFontSizeChanged;

  const FontSettingsSection({
    super.key,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: '字體設定'),
        const SizedBox(height: 16),
        
        DropdownCard(
          title: '字體大小',
          subtitle: '調整應用內文字大小',
          value: fontSize,
          items: const [
            DropdownMenuItem(value: 'small', child: Text('小字體')),
            DropdownMenuItem(value: 'medium', child: Text('標準字體')),
            DropdownMenuItem(value: 'large', child: Text('大字體')),
            DropdownMenuItem(value: 'extra_large', child: Text('超大字體')),
          ],
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              onFontSizeChanged(value);
            }
          },
        ),
      ],
    );
  }
} 
