// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GOAA Bill Splitter';

  @override
  String get appDescription =>
      'Cross-platform bill splitting app that makes splitting bills simple and elegant';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String goodNight(String name) {
    return 'Good night, $name';
  }

  @override
  String userCode(String code) {
    return 'User Code: $code';
  }

  @override
  String get myGroups => 'My Groups';

  @override
  String get participatedGroups => 'Groups Joined';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get quickBilling => 'Quick Split';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get createGroup => 'Create Group';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get settlementRecords => 'Settlement Records';

  @override
  String get viewAll => 'View All';

  @override
  String get members => ' members';

  @override
  String get settled => 'Settled';

  @override
  String get hasActivity => 'Active';

  @override
  String get noActivity => 'No Activity';

  @override
  String timeAgo_days(int count) {
    return '$count days ago';
  }

  @override
  String timeAgo_hours(int count) {
    return '$count hours ago';
  }

  @override
  String timeAgo_minutes(int count) {
    return '$count minutes ago';
  }

  @override
  String get timeAgo_justNow => 'Just now';

  @override
  String get currency => '\$';

  @override
  String moneyFormat(String currency, String amount) {
    return '$currency$amount NT';
  }

  @override
  String positiveMoneyFormat(String currency, String amount) {
    return '+$currency$amount NT';
  }

  @override
  String negativeMoneyFormat(String currency, String amount) {
    return '-$currency$amount NT';
  }

  @override
  String get userName => 'Username';

  @override
  String get user => 'User';

  @override
  String get notAvailable => 'N/A';

  @override
  String get roommateBilling => 'Roommate Bills';

  @override
  String get roommateDescription => 'Split daily expenses with roommates';

  @override
  String get groceryShopping => 'Grocery Shopping';

  @override
  String get groceryDescription => 'Toilet paper, detergent, etc.';

  @override
  String get roommateXiaoWang => 'Roommate Wang';

  @override
  String get roommateXiaoLi => 'Roommate Li';

  @override
  String get loading => 'Loading...';

  @override
  String get notifications => 'Notification feature under development...';

  @override
  String get dataLoadError => 'Failed to load data';

  @override
  String get databaseInitSuccess => 'Database initialized successfully';

  @override
  String get databaseInitError => 'Database initialization failed';

  @override
  String get language => 'Language';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get userProfile => 'User Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get reports => 'Reports';

  @override
  String get interface => 'Interface';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get avatar => 'Avatar';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get autoSettlement => 'Auto Settlement';

  @override
  String get reminderSettings => 'Reminders';

  @override
  String get exportData => 'Export Data';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get themeSettings => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get fontSize => 'Font Size';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get terms => 'Terms of Service';

  @override
  String get support => 'Support';

  @override
  String get logout => 'Logout';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get comingSoon => 'Coming Soon...';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get billReminders => 'Bill Reminders';

  @override
  String get settlementReminders => 'Settlement Reminders';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'Danny Wang';

  @override
  String get developerEmail => 'tiger.danny@gmail.com';

  @override
  String get developmentDate => 'Development Date';

  @override
  String get developmentDateValue => 'June 2025';

  @override
  String get appInfo => 'App Information';

  @override
  String get contactDeveloper => 'Contact Developer';

  @override
  String get swipeLeftForMenu => '← Swipe left to open menu';

  @override
  String get menu => 'Menu';

  @override
  String get friendsInfo => 'Friends';

  @override
  String get defaultUser => 'User';
}
