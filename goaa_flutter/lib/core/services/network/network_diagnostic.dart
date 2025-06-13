import 'dart:io';

class NetworkDiagnostic {
  static Future<String> diagnose() async {
    try {
      final google = await InternetAddress.lookup('google.com');
      if (google.isNotEmpty) return 'Google DNS 正常';
    } catch (_) {}
    return '網路異常，請檢查連線';
  }
} 
