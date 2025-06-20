

/// 表單驗證服務
class ValidationService {
  /// 驗證用戶名稱
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入用戶名稱';
    }

    final trimmedValue = value.trim();
    
    // 檢查長度（最多10個繁體中文字符或20個英文字符）
    if (_getStringLength(trimmedValue) > 10) {
      return '用戶名稱不能超過10個字符';
    }

    // 檢查危險字符（防止SQL注入和XSS攻擊）
    if (_containsDangerousCharacters(trimmedValue)) {
      return '用戶名稱包含不允許的字符';
    }

    // 檢查是否只包含空白字符
    if (trimmedValue.isEmpty) {
      return '用戶名稱不能只包含空格';
    }

    return null;
  }

  /// 驗證電子郵件
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 電子郵件為選填
    }

    final trimmedValue = value.trim();
    
    // 基本的電子郵件格式驗證
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return '請輸入有效的電子郵件地址';
    }

    // 檢查長度
    if (trimmedValue.length > 255) {
      return '電子郵件地址過長';
    }

    return null;
  }

  /// 驗證手機號碼
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 手機號碼為選填
    }

    final trimmedValue = value.trim();
    
    // 移除所有非數字字符進行驗證
    final numbersOnly = trimmedValue.replaceAll(RegExp(r'[^\d]'), '');
    
    // 檢查是否為有效的台灣手機號碼格式
    if (numbersOnly.length < 10 || numbersOnly.length > 15) {
      return '請輸入有效的手機號碼';
    }

    // 台灣手機號碼格式檢查
    final taiwanMobileRegex = RegExp(r'^09\d{8}$');
    final internationalRegex = RegExp(r'^\+?[1-9]\d{8,14}$');
    
    if (!taiwanMobileRegex.hasMatch(numbersOnly) && 
        !internationalRegex.hasMatch(trimmedValue.replaceAll(RegExp(r'[^\d+]'), ''))) {
      return '請輸入有效的手機號碼格式';
    }

    return null;
  }

  /// 計算字符串長度（中文字符計為1個字符）
  static int _getStringLength(String text) {
    double length = 0;
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      // 中文字符範圍 (簡化判斷)
      if (codeUnit >= 0x4e00 && codeUnit <= 0x9fff) {
        length += 1; // 中文字符計為1個字符
      } else if (codeUnit >= 0x3400 && codeUnit <= 0x4dbf) {
        length += 1; // 擴展A區中文字符
      } else if (codeUnit >= 0x20000 && codeUnit <= 0x2a6df) {
        length += 1; // 擴展B區中文字符
      } else {
        length += 0.5; // 英文字符計為0.5個字符
      }
    }
    return length.ceil();
  }

  /// 檢查是否包含危險字符
  static bool _containsDangerousCharacters(String text) {
    // SQL注入關鍵字
    final sqlKeywords = [
      'select', 'insert', 'update', 'delete', 'drop', 'create', 'alter',
      'union', 'exec', 'execute', 'script', 'declare', 'cursor'
    ];

    // XSS相關字符
    final xssPatterns = [
      '<script', '</script>', '<iframe', '</iframe>', 'javascript:',
      'vbscript:', 'onload=', 'onerror=', 'onclick=', 'onmouseover='
    ];

    // 其他危險字符
    final dangerousChars = ['\'', '"', ';', '--', '/*', '*/', '\\'];

    final lowerText = text.toLowerCase();

    // 檢查SQL關鍵字
    for (String keyword in sqlKeywords) {
      if (lowerText.contains(keyword)) {
        return true;
      }
    }

    // 檢查XSS模式
    for (String pattern in xssPatterns) {
      if (lowerText.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    // 檢查危險字符
    for (String char in dangerousChars) {
      if (text.contains(char)) {
        return true;
      }
    }

    return false;
  }

  /// 清理用戶輸入
  static String sanitizeInput(String input) {
    return input.trim()
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(';', '')
        .replaceAll(RegExp(r'\s+'), ' '); // 合併多個空格
  }

  /// 檢查是否為有效的用戶代碼格式（UUID格式，32位十六進制字符）
  static bool isValidUserCode(String userCode) {
    final regex = RegExp(r'^[a-fA-F0-9]{32}$');
    return regex.hasMatch(userCode);
  }

  /// 格式化手機號碼顯示
  static String formatPhoneNumber(String phone) {
    final numbersOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbersOnly.length == 10 && numbersOnly.startsWith('09')) {
      // 台灣手機號碼格式: 0912-345-678
      return '${numbersOnly.substring(0, 4)}-${numbersOnly.substring(4, 7)}-${numbersOnly.substring(7)}';
    }
    
    return phone; // 其他格式直接返回
  }
}
