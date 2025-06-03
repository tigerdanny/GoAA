// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'GOAA分帳神器';

  @override
  String get appDescription => '跨平台分帳應用，讓分帳變得簡單優雅';

  @override
  String goodMorning(String name) {
    return '早安，$name';
  }

  @override
  String userCode(String code) {
    return '用戶代碼：$code';
  }

  @override
  String get myGroups => '我的群組';

  @override
  String get participatedGroups => '參與群組';

  @override
  String get totalExpenses => '總支出';

  @override
  String get quickBilling => '快速分帳';

  @override
  String get quickActions => '快速操作';

  @override
  String get addExpense => '添加支出';

  @override
  String get createGroup => '創建群組';

  @override
  String get scanReceipt => '掃描收據';

  @override
  String get settlementRecords => '結算記錄';

  @override
  String get viewAll => '查看全部';

  @override
  String get members => '位成員';

  @override
  String get settled => '已結清';

  @override
  String get hasActivity => '有活動';

  @override
  String get noActivity => '無活動';

  @override
  String timeAgo_days(int count) {
    return '$count天前';
  }

  @override
  String timeAgo_hours(int count) {
    return '$count小時前';
  }

  @override
  String timeAgo_minutes(int count) {
    return '$count分鐘前';
  }

  @override
  String get timeAgo_justNow => '剛才';

  @override
  String get currency => '\$';

  @override
  String moneyFormat(String currency, String amount) {
    return '$currency$amount';
  }

  @override
  String positiveMoneyFormat(String currency, String amount) {
    return '+$currency$amount';
  }

  @override
  String negativeMoneyFormat(String currency, String amount) {
    return '-$currency$amount';
  }

  @override
  String get userName => '使用者名稱';

  @override
  String get user => '用戶';

  @override
  String get notAvailable => 'N/A';

  @override
  String get roommateBilling => '室友分攤';

  @override
  String get roommateDescription => '與室友一起分攤日常開支';

  @override
  String get groceryShopping => '購買日用品';

  @override
  String get groceryDescription => '衛生紙、洗衣精等';

  @override
  String get roommateXiaoWang => '室友小王';

  @override
  String get roommateXiaoLi => '室友小李';

  @override
  String get loading => '載入中...';

  @override
  String get notifications => '通知功能開發中...';

  @override
  String get dataLoadError => '加載數據失敗';

  @override
  String get databaseInitSuccess => '資料庫初始化成功';

  @override
  String get databaseInitError => '資料庫初始化失敗';

  @override
  String get language => '語言';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get settings => '設置';

  @override
  String get userProfile => '用戶資料';

  @override
  String get accountSettings => '帳務設定';

  @override
  String get reports => '報表設定';

  @override
  String get interface => '介面設定';

  @override
  String get personalInfo => '個人資訊';

  @override
  String get name => '姓名';

  @override
  String get email => '電子郵件';

  @override
  String get phone => '電話號碼';

  @override
  String get avatar => '頭像';

  @override
  String get defaultCurrency => '預設貨幣';

  @override
  String get autoSettlement => '自動結算';

  @override
  String get reminderSettings => '提醒設定';

  @override
  String get exportData => '匯出資料';

  @override
  String get backupRestore => '備份與還原';

  @override
  String get themeSettings => '主題設定';

  @override
  String get darkMode => '深色模式';

  @override
  String get fontSize => '字體大小';

  @override
  String get about => '關於應用';

  @override
  String get version => '版本';

  @override
  String get privacy => '隱私政策';

  @override
  String get terms => '使用條款';

  @override
  String get support => '客服支援';

  @override
  String get logout => '登出';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '編輯';

  @override
  String get comingSoon => '功能開發中...';

  @override
  String get enableNotifications => '啟用通知';

  @override
  String get billReminders => '帳單提醒';

  @override
  String get settlementReminders => '結算提醒';

  @override
  String get developer => '開發者';

  @override
  String get developerName => 'Danny Wang';

  @override
  String get developerEmail => 'tiger.danny@gmail.com';

  @override
  String get developmentDate => '開發時間';

  @override
  String get developmentDateValue => '2025年6月';

  @override
  String get appInfo => '應用資訊';

  @override
  String get contactDeveloper => '聯繫開發者';
}
