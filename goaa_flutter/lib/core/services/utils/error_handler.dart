import '../logger_service.dart';

class ErrorHandler {
  static final LoggerService _logger = LoggerService();

  static void handleError(Object error, [StackTrace? stackTrace]) {
    _logger.error('錯誤發生', error, stackTrace);
  }
} 
