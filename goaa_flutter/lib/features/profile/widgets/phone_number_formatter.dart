import 'package:flutter/services.dart';

/// 手機號碼格式化器：自動插入破折號
class PhoneNumberFormatter extends TextInputFormatter {
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
