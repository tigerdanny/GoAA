import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 語言管理服務
/// 負責管理應用程式的語言設置和切換
class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();
  
  static const String _languageKey = 'app_language';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  /// 支援的語言列表
  static const List<Locale> supportedLocales = [
    Locale('zh'), // 繁體中文
    Locale('en'), // 英文
  ];
  
  /// 目前語言
  Locale _currentLocale = const Locale('zh'); // 預設繁體中文
  
  /// 獲取目前語言
  Locale get currentLocale => _currentLocale;
  
  /// 🚀 初始化語言服務（重新設計使用 async/await）
  Future<void> initializeAsync() async {
    try {
      final savedLanguage = await _storage.read(key: _languageKey);
      if (savedLanguage != null) {
        final locale = Locale(savedLanguage);
        if (supportedLocales.contains(locale)) {
          _currentLocale = locale;
        }
      } else {
        // 如果沒有保存的語言設置，使用系統語言
        final systemLocale = ui.PlatformDispatcher.instance.locale;
        if (supportedLocales.any((locale) => locale.languageCode == systemLocale.languageCode)) {
          _currentLocale = Locale(systemLocale.languageCode);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 初始化語言服務失敗: $e');
      // 使用預設語言
      _currentLocale = const Locale('zh');
      notifyListeners();
    }
  }

  /// 🚀 保留同步版本以兼容性
  void initialize() {
    initializeAsync();
  }
  
  /// 🚀 切換語言（重新設計使用 async/await）
  Future<void> changeLanguage(Locale locale) async {
    if (supportedLocales.contains(locale) && _currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
      try {
        await _storage.write(key: _languageKey, value: locale.languageCode);
      } catch (e) {
        debugPrint('❌ 保存語言設置失敗: $e');
      }
    }
  }
  
    /// 切換到繁體中文（簡化版）
  Future<void> switchToTraditionalChinese() {
    return changeLanguage(const Locale('zh'));
  }

  /// 切換到英文（簡化版）
  Future<void> switchToEnglish() {
    return changeLanguage(const Locale('en'));
  }
  
  /// 獲取語言顯示名稱
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '繁體中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }
  
  /// 獲取目前語言顯示名稱
  String get currentLanguageDisplayName => getLanguageDisplayName(_currentLocale);
  
  /// 是否為繁體中文
  bool get isTraditionalChinese => _currentLocale.languageCode == 'zh';
  
  /// 是否為英文
  bool get isEnglish => _currentLocale.languageCode == 'en';
} 
