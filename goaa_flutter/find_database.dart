// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  print('=== GOAA 資料庫檔案位置查找 ===\n');

  // 根據 database.dart，資料庫檔案名為 'goaa_database.db'
  const dbFileName = 'goaa_database.db';
  
  // 可能的資料庫位置
  final possiblePaths = <String>[];
  
  try {
    // 1. 當前目錄
    possiblePaths.add(p.join(Directory.current.path, dbFileName));
    
    // 2. 構建目錄（Windows Debug）
    possiblePaths.add(p.join(Directory.current.path, 'build', 'windows', 'x64', 'runner', 'Debug', dbFileName));
    
    // 3. 構建目錄（Windows Release）  
    possiblePaths.add(p.join(Directory.current.path, 'build', 'windows', 'x64', 'runner', 'Release', dbFileName));
    
    // 4. 用戶文檔目錄（Windows）
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      possiblePaths.add(p.join(userProfile, 'Documents', dbFileName));
    }
    
    // 5. AppData目錄（Windows）
    final appData = Platform.environment['APPDATA'];
    if (appData != null) {
      possiblePaths.add(p.join(appData, 'com.goaa.splitbill.goaa_flutter', dbFileName));
    }
    
    print('搜尋可能的資料庫位置...\n');
    
    bool found = false;
    for (int i = 0; i < possiblePaths.length; i++) {
      final path = possiblePaths[i];
      final file = File(path);
      
      print('${i + 1}. 檢查: $path');
      
      if (await file.exists()) {
        final stat = await file.stat();
        print('   ✅ 找到！檔案大小: ${(stat.size / 1024).toStringAsFixed(2)} KB');
        print('   📅 修改時間: ${stat.modified}');
        found = true;
      } else {
        print('   ❌ 不存在');
      }
      print('');
    }
    
    if (!found) {
      print('📝 未找到資料庫檔案。這可能表示：');
      print('   • 應用還沒有運行過');
      print('   • 資料庫初始化失敗');
      print('   • 資料庫位置與預期不同');
      print('\n💡 建議：');
      print('   1. 運行 Flutter 應用一次');
      print('   2. 檢查應用日誌中的資料庫初始化信息');
      print('   3. 確保應用有權限寫入檔案系統');
      print('\n🔍 實際資料庫位置（Android 設備上）：');
      print('   /data/data/com.goaa.splitbill.goaa_flutter/app_flutter/goaa_database.db');
      print('   或');
      print('   /storage/emulated/0/Android/data/com.goaa.splitbill.goaa_flutter/files/Documents/goaa_database.db');
    }
    
  } catch (e) {
    print('❌ 搜尋過程中發生錯誤: $e');
  }
  
  print('\n=== 搜尋完成 ===');
} 
