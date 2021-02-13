import 'package:logger/logger.dart';

final logger = LoggerService(level: Level.warning);

class LoggerService {
  static final _loggerService = LoggerService._internal();

  final Logger _logger;

  factory LoggerService({Level level}) {
    if (level != null) {
      Logger.level = level;
    }
    return _loggerService;
  }

  LoggerService._internal()
      : _logger = Logger(
          printer: PrettyPrinter(),
        );

  void verbose(dynamic msg) => _logger.v(msg);
  void debug(dynamic msg) => _logger.d(msg);
  void info(dynamic msg) => _logger.i(msg);
  void warning(dynamic msg) => _logger.w(msg);
  void error(dynamic msg) => _logger.e(msg);
  void wtf(dynamic msg) => _logger.wtf(msg);
}
