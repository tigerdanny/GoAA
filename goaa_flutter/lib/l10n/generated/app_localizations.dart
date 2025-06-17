import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 應用程式名稱
  ///
  /// In zh, this message translates to:
  /// **'GOAA分帳神器'**
  String get appName;

  /// 應用程式描述
  ///
  /// In zh, this message translates to:
  /// **'跨平台分帳應用，讓分帳變得簡單優雅'**
  String get appDescription;

  /// Good morning greeting
  ///
  /// In zh, this message translates to:
  /// **'早安，{name}'**
  String goodMorning(String name);

  /// Good afternoon greeting
  ///
  /// In zh, this message translates to:
  /// **'午安，{name}'**
  String goodAfternoon(String name);

  /// Good evening greeting
  ///
  /// In zh, this message translates to:
  /// **'晚安，{name}'**
  String goodEvening(String name);

  /// Good night greeting
  ///
  /// In zh, this message translates to:
  /// **'深夜好，{name}'**
  String goodNight(String name);

  /// 用戶代碼顯示
  ///
  /// In zh, this message translates to:
  /// **'用戶代碼：{code}'**
  String userCode(String code);

  /// 我的群組標題
  ///
  /// In zh, this message translates to:
  /// **'我的群組'**
  String get myGroups;

  /// 參與群組統計
  ///
  /// In zh, this message translates to:
  /// **'參與群組'**
  String get participatedGroups;

  /// 總支出統計
  ///
  /// In zh, this message translates to:
  /// **'總支出'**
  String get totalExpenses;

  /// 快速分帳按鈕
  ///
  /// In zh, this message translates to:
  /// **'快速分帳'**
  String get quickBilling;

  /// 快速操作標題
  ///
  /// In zh, this message translates to:
  /// **'快速操作'**
  String get quickActions;

  /// 添加支出按鈕
  ///
  /// In zh, this message translates to:
  /// **'添加支出'**
  String get addExpense;

  /// 創建群組按鈕
  ///
  /// In zh, this message translates to:
  /// **'創建群組'**
  String get createGroup;

  /// 掃描收據按鈕
  ///
  /// In zh, this message translates to:
  /// **'掃描收據'**
  String get scanReceipt;

  /// 結算記錄按鈕
  ///
  /// In zh, this message translates to:
  /// **'結算記錄'**
  String get settlementRecords;

  /// 查看全部按鈕
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// 成員數量單位
  ///
  /// In zh, this message translates to:
  /// **'位成員'**
  String get members;

  /// 已結清狀態
  ///
  /// In zh, this message translates to:
  /// **'已結清'**
  String get settled;

  /// 有活動狀態
  ///
  /// In zh, this message translates to:
  /// **'有活動'**
  String get hasActivity;

  /// 無活動狀態
  ///
  /// In zh, this message translates to:
  /// **'無活動'**
  String get noActivity;

  /// 天前時間格式
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String timeAgo_days(int count);

  /// 小時前時間格式
  ///
  /// In zh, this message translates to:
  /// **'{count}小時前'**
  String timeAgo_hours(int count);

  /// 分鐘前時間格式
  ///
  /// In zh, this message translates to:
  /// **'{count}分鐘前'**
  String timeAgo_minutes(int count);

  /// 剛才時間格式
  ///
  /// In zh, this message translates to:
  /// **'剛才'**
  String get timeAgo_justNow;

  /// 貨幣符號
  ///
  /// In zh, this message translates to:
  /// **'\$'**
  String get currency;

  /// 金額格式
  ///
  /// In zh, this message translates to:
  /// **'{currency}{amount} NT'**
  String moneyFormat(String currency, String amount);

  /// 正數金額格式
  ///
  /// In zh, this message translates to:
  /// **'+{currency}{amount} NT'**
  String positiveMoneyFormat(String currency, String amount);

  /// 負數金額格式
  ///
  /// In zh, this message translates to:
  /// **'-{currency}{amount} NT'**
  String negativeMoneyFormat(String currency, String amount);

  /// 預設使用者名稱
  ///
  /// In zh, this message translates to:
  /// **'使用者名稱'**
  String get userName;

  /// 用戶
  ///
  /// In zh, this message translates to:
  /// **'用戶'**
  String get user;

  /// 不可用狀態
  ///
  /// In zh, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// 室友分攤群組名稱
  ///
  /// In zh, this message translates to:
  /// **'室友分攤'**
  String get roommateBilling;

  /// 室友分攤群組描述
  ///
  /// In zh, this message translates to:
  /// **'與室友一起分攤日常開支'**
  String get roommateDescription;

  /// 購買日用品支出標題
  ///
  /// In zh, this message translates to:
  /// **'購買日用品'**
  String get groceryShopping;

  /// 購買日用品支出描述
  ///
  /// In zh, this message translates to:
  /// **'衛生紙、洗衣精等'**
  String get groceryDescription;

  /// 室友小王名稱
  ///
  /// In zh, this message translates to:
  /// **'室友小王'**
  String get roommateXiaoWang;

  /// 室友小李名稱
  ///
  /// In zh, this message translates to:
  /// **'室友小李'**
  String get roommateXiaoLi;

  /// 載入中狀態
  ///
  /// In zh, this message translates to:
  /// **'載入中...'**
  String get loading;

  /// 通知功能提示
  ///
  /// In zh, this message translates to:
  /// **'通知功能開發中...'**
  String get notifications;

  /// 數據載入錯誤
  ///
  /// In zh, this message translates to:
  /// **'加載數據失敗'**
  String get dataLoadError;

  /// 資料庫初始化成功
  ///
  /// In zh, this message translates to:
  /// **'資料庫初始化成功'**
  String get databaseInitSuccess;

  /// 資料庫初始化失敗
  ///
  /// In zh, this message translates to:
  /// **'資料庫初始化失敗'**
  String get databaseInitError;

  /// 語言設置
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get language;

  /// 繁體中文語言選項
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// 英文語言選項
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// 設置頁面標題
  ///
  /// In zh, this message translates to:
  /// **'設置'**
  String get settings;

  /// 用戶資料設置
  ///
  /// In zh, this message translates to:
  /// **'用戶資料'**
  String get userProfile;

  /// 帳務設定
  ///
  /// In zh, this message translates to:
  /// **'帳務設定'**
  String get accountSettings;

  /// 報表設定
  ///
  /// In zh, this message translates to:
  /// **'報表設定'**
  String get reports;

  /// 介面設定
  ///
  /// In zh, this message translates to:
  /// **'介面設定'**
  String get interface;

  /// 個人資訊設置
  ///
  /// In zh, this message translates to:
  /// **'個人資訊'**
  String get personalInfo;

  /// 姓名欄位
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get name;

  /// 電子郵件欄位
  ///
  /// In zh, this message translates to:
  /// **'電子郵件'**
  String get email;

  /// 電話號碼欄位
  ///
  /// In zh, this message translates to:
  /// **'電話號碼'**
  String get phone;

  /// 頭像設置
  ///
  /// In zh, this message translates to:
  /// **'頭像'**
  String get avatar;

  /// 預設貨幣設置
  ///
  /// In zh, this message translates to:
  /// **'預設貨幣'**
  String get defaultCurrency;

  /// 自動結算設置
  ///
  /// In zh, this message translates to:
  /// **'自動結算'**
  String get autoSettlement;

  /// 提醒設定
  ///
  /// In zh, this message translates to:
  /// **'提醒設定'**
  String get reminderSettings;

  /// 匯出資料功能
  ///
  /// In zh, this message translates to:
  /// **'匯出資料'**
  String get exportData;

  /// 備份與還原功能
  ///
  /// In zh, this message translates to:
  /// **'備份與還原'**
  String get backupRestore;

  /// 主題設定
  ///
  /// In zh, this message translates to:
  /// **'主題設定'**
  String get themeSettings;

  /// 深色模式設置
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// 字體大小設置
  ///
  /// In zh, this message translates to:
  /// **'字體大小'**
  String get fontSize;

  /// 關於應用
  ///
  /// In zh, this message translates to:
  /// **'關於應用'**
  String get about;

  /// 應用版本
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// 隱私政策
  ///
  /// In zh, this message translates to:
  /// **'隱私政策'**
  String get privacy;

  /// 使用條款
  ///
  /// In zh, this message translates to:
  /// **'使用條款'**
  String get terms;

  /// 客服支援
  ///
  /// In zh, this message translates to:
  /// **'客服支援'**
  String get support;

  /// 登出功能
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get logout;

  /// 儲存按鈕
  ///
  /// In zh, this message translates to:
  /// **'儲存'**
  String get save;

  /// 取消按鈕
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 編輯按鈕
  ///
  /// In zh, this message translates to:
  /// **'編輯'**
  String get edit;

  /// 功能開發中提示
  ///
  /// In zh, this message translates to:
  /// **'功能開發中...'**
  String get comingSoon;

  /// 啟用通知設置
  ///
  /// In zh, this message translates to:
  /// **'啟用通知'**
  String get enableNotifications;

  /// 帳單提醒設置
  ///
  /// In zh, this message translates to:
  /// **'帳單提醒'**
  String get billReminders;

  /// 結算提醒設置
  ///
  /// In zh, this message translates to:
  /// **'結算提醒'**
  String get settlementReminders;

  /// 開發者
  ///
  /// In zh, this message translates to:
  /// **'開發者'**
  String get developer;

  /// 開發者姓名
  ///
  /// In zh, this message translates to:
  /// **'Danny Wang'**
  String get developerName;

  /// 開發者電子郵件
  ///
  /// In zh, this message translates to:
  /// **'tiger.danny@gmail.com'**
  String get developerEmail;

  /// 開發時間
  ///
  /// In zh, this message translates to:
  /// **'開發時間'**
  String get developmentDate;

  /// 開發時間值
  ///
  /// In zh, this message translates to:
  /// **'2025年6月'**
  String get developmentDateValue;

  /// 應用資訊
  ///
  /// In zh, this message translates to:
  /// **'應用資訊'**
  String get appInfo;

  /// 聯繫開發者
  ///
  /// In zh, this message translates to:
  /// **'聯繫開發者'**
  String get contactDeveloper;

  /// 往左滑提示開啟側滑選單
  ///
  /// In zh, this message translates to:
  /// **'← 往左滑可打開選單'**
  String get swipeLeftForMenu;

  /// 選單標題
  ///
  /// In zh, this message translates to:
  /// **'選單'**
  String get menu;

  /// 好友資訊選單項目
  ///
  /// In zh, this message translates to:
  /// **'好友資訊'**
  String get friendsInfo;

  /// 預設用戶名稱
  ///
  /// In zh, this message translates to:
  /// **'用戶'**
  String get defaultUser;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
