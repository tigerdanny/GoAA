import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// 導入表格定義
import 'tables.dart';

// 導入查詢類
import 'queries/user_queries.dart';
import 'queries/group_queries.dart';
import 'queries/expense_queries.dart';
import 'queries/settlement_queries.dart';
import 'queries/invitation_queries.dart';

part 'database.g.dart';

// ================================
// 資料庫類
// ================================

@DriftDatabase(tables: [
  Users,
  Groups,
  GroupMembers,
  Expenses,
  ExpenseSplits,
  Settlements,
  Invitations,
  DailyQuotes,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // 建立所有表格
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 處理從版本1到版本2的升級
        if (from < 2) {
          // 如果需要添加新表格或修改表格，在這裡處理
          // 目前我們重新創建所有表格
          await m.createAll();
        }
      },
      beforeOpen: (details) async {
        // 啟用外鍵約束
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ================================
  // 查詢類實例
  // ================================
  
  late final UserQueries userQueries = UserQueries(this);
  late final GroupQueries groupQueries = GroupQueries(this);
  late final ExpenseQueries expenseQueries = ExpenseQueries(this);
  late final SettlementQueries settlementQueries = SettlementQueries(this);
  late final InvitationQueries invitationQueries = InvitationQueries(this);

  // ================================
  // 向後兼容的方法（可選，便於遷移）
  // ================================
  
  Future<User?> getCurrentUser() => userQueries.getCurrentUser();
  Future<User?> findUserByCode(String userCode) => userQueries.findUserByCode(userCode);
}

// ================================
// 資料庫連接設置
// ================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 確保在Android上使用最新的sqlite3
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      
      // 設置臨時目錄
      final cacheDir = await getTemporaryDirectory();
      sqlite3.tempDirectory = cacheDir.path;
      
      debugPrint('🔧 Android SQLite3 workaround applied');
      debugPrint('📂 Temp directory: ${cacheDir.path}');
    }

    // 獲取應用程式文檔目錄
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'goaa_database.db'));
    
    debugPrint('📂 Database path: ${file.path}');
    debugPrint('📂 Database exists: ${file.existsSync()}');

    // 確保目錄存在
    if (!dbFolder.existsSync()) {
      await dbFolder.create(recursive: true);
      debugPrint('📂 Created database directory: ${dbFolder.path}');
    }

    // 測試寫入權限
    final testFile = File(p.join(dbFolder.path, '.write_test'));
    try {
      await testFile.writeAsString('test');
      await testFile.delete();
      debugPrint('✅ Storage permission verified');
    } catch (e) {
      debugPrint('❌ Storage permission test failed: $e');
      throw Exception('無法寫入應用目錄，請檢查存儲權限: $e');
    }

    // 創建原生資料庫連接
    final database = NativeDatabase.createInBackground(
      file,
      logStatements: true, // 開發階段啟用 SQL 日誌
      setup: (database) {
        // 設置 SQLite 參數
        database.execute('PRAGMA foreign_keys = ON');
        database.execute('PRAGMA journal_mode = WAL');
        database.execute('PRAGMA synchronous = NORMAL');
        database.execute('PRAGMA cache_size = 10000');
        database.execute('PRAGMA temp_store = MEMORY');
        
        debugPrint('✅ SQLite PRAGMA settings applied');
      },
    );

    debugPrint('✅ Database connection created successfully');
    return database;
  });
} 
