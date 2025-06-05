import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../widgets/index.dart';

/// 首頁交互服務
/// 處理首頁相關的所有交互邏輯
class HomeInteractionService {
  /// 進入群組
  static void enterGroup(BuildContext context, Group group) {
    // 導航到群組詳情頁面
    // 實現群組詳情頁面導航
    debugPrint('進入群組: ${group.name}');
  }

  /// 顯示 QR Code
  static void showQRCode(BuildContext context, User currentUser) {
    QRCodeDialog.show(context, currentUser);
  }

  /// 掃描 QR Code
  static void scanQRCode(BuildContext context) {
    QRCodeScanner.scan(context);
  }

  /// 顯示快速操作選單
  static void showQuickActions(BuildContext context) {
    QuickActionsSheet.show(context);
  }

  /// 打開選單抽屜
  static void openDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    debugPrint('正在打開選單抽屜');
    scaffoldKey.currentState?.openDrawer();
  }
} 
