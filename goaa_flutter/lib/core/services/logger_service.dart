import 'package:logging/logging.dart';

/// 日誌服務
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  
  late final Logger _logger;
  static const String _loggerName = 'GOAA';

  LoggerService._internal() {
    _logger = Logger(_loggerName);
    _setupLogger();
  }

  /// 設置日誌
  void _setupLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  /// 記錄信息
  void info(String message) {
    _logger.info(message);
  }

  /// 記錄警告
  void warning(String message) {
    _logger.warning(message);
  }

  /// 記錄錯誤
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  /// 記錄調試信息
  void debug(String message) {
    _logger.fine(message);
  }
} 
