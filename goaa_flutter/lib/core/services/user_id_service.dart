import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 用戶ID生成服務
/// 確保每個安裝的應用都有唯一的用戶ID
class UserIdService {
  static final UserIdService _instance = UserIdService._internal();
  factory UserIdService() => _instance;
  UserIdService._internal();

  static const String _userIdKey = 'user_id';
  static const String _userCodeKey = 'user_code';
  static const Uuid _uuid = Uuid();

  /// 獲取或生成用戶ID
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    if (userId == null || userId.isEmpty) {
      userId = await _generateUniqueUserId();
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
  }

  /// 獲取或生成用戶代碼（UUID格式）
  Future<String> getUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? userCode = prefs.getString(_userCodeKey);
    
    if (userCode == null || userCode.isEmpty) {
      userCode = await _generateUserCode();
      await prefs.setString(_userCodeKey, userCode);
    }
    
    return userCode;
  }

  /// 生成唯一的用戶ID
  Future<String> _generateUniqueUserId() async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPart = _uuid.v4().replaceAll('-', '').substring(0, 8);
      
      // 組合設備信息、時間戳和隨機部分
      final baseString = '${deviceInfo}_${timestamp}_$randomPart';
      
      // 生成最終的用戶ID（32位字符）
      return _uuid.v5(Namespace.oid.value, baseString).replaceAll('-', '');
    } catch (e) {
      // 如果獲取設備信息失敗，使用純隨機UUID
      return _uuid.v4().replaceAll('-', '');
    }
  }

  /// 生成用戶代碼（UUID格式）
  Future<String> _generateUserCode() async {
    // 生成UUID v4格式的用戶代碼（去掉連字符，保持32位字符）
    return _uuid.v4().replaceAll('-', '');
  }

  /// 獲取設備信息
  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return '${iosInfo.name}_${iosInfo.model}_${iosInfo.identifierForVendor}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        return '${windowsInfo.computerName}_${windowsInfo.userName}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        return '${linuxInfo.name}_${linuxInfo.id}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        return '${macInfo.computerName}_${macInfo.hostName}';
      }
      
      return 'unknown_device';
    } catch (e) {
      // 如果無法獲取設備信息，返回隨機字符串
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 重新生成用戶ID（慎用）
  Future<String> regenerateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    return await getUserId();
  }

  /// 重新生成用戶代碼
  Future<String> regenerateUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCodeKey);
    return await getUserCode();
  }

  /// 清除所有用戶數據
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userCodeKey);
  }
}
