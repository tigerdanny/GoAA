import 'package:flutter/services.dart';

/// 手機號碼格式化器：自動插入破折號，支援正確的刪除操作
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 取得舊值和新值的純數字字符
    String oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String newDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 如果長度超過10位，截斷
    if (newDigits.length > 10) {
      newDigits = newDigits.substring(0, 10);
    }
    
    // 檢測是否為刪除操作
    bool isDeleting = newDigits.length < oldDigits.length;
    
    // 根據長度格式化
    String formattedText = _formatPhoneNumber(newDigits);
    
    // 計算游標位置
    int cursorPosition;
    if (isDeleting) {
      // 刪除操作：將游標放在合適的位置
      cursorPosition = _calculateCursorPositionForDeletion(oldValue, newValue, formattedText);
    } else {
      // 輸入操作：將游標放在末尾
      cursorPosition = formattedText.length;
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
  
  /// 格式化手機號碼
  String _formatPhoneNumber(String digits) {
    if (digits.length <= 4) {
      return digits;
    } else if (digits.length <= 7) {
      return '${digits.substring(0, 4)}-${digits.substring(4)}';
    } else {
      return '${digits.substring(0, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
    }
  }
  
  /// 計算刪除操作時的游標位置
  int _calculateCursorPositionForDeletion(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    String formattedText,
  ) {
    // 取得原始游標位置
    int oldCursorPos = oldValue.selection.baseOffset;
    
    // 如果游標在連字號後面，調整位置
    if (oldCursorPos > 0 && oldCursorPos < oldValue.text.length) {
      String charAtCursor = oldValue.text[oldCursorPos - 1];
      if (charAtCursor == '-') {
        // 如果刪除的是連字號前的數字，游標應該往前移
        oldCursorPos--;
      }
    }
    
    // 計算在新格式化文本中的對應位置
    int newCursorPos = 0;
    int digitCount = 0;
    String newDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    for (int i = 0; i < formattedText.length && digitCount < newDigits.length; i++) {
      if (formattedText[i] != '-') {
        digitCount++;
      }
      newCursorPos = i + 1;
    }
    
    return newCursorPos.clamp(0, formattedText.length);
  }
} 
