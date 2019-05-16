import 'package:ble_test/utils/FileManager.dart';
import 'package:rxdart/subjects.dart';

class LogManager {
  factory LogManager() => _getInstance();
  static LogManager get instance => _getInstance();
  static LogManager _instance;
  LogManager._internal() {
    // 初始化
    print('init logManager');
    fileManager = FileManager(FileNames.log);
  }
  static LogManager _getInstance() {
    if (_instance == null) {
      _instance = new LogManager._internal();
    }
    return _instance;
  }

  FileManager fileManager;
  List<String> _logs;
  final logSubject = BehaviorSubject<List<String>>.seeded([]);

  Future init() async {
    String logContent = await fileManager.read() ?? '';
    this._logs = logContent.isEmpty ? [] : logContent.split('||');
    this.logSubject.add(this._logs);
    return;
  }

  Future append(String message) async {
    this._logs.add(message);
    String newContent = this._logs.join('||');
    logSubject.add(this._logs);
    await fileManager.write(newContent);
    return;
  }

  Future clear() async {
    await fileManager.write('');
    this._logs.clear();
    this.logSubject.add(this._logs);
    return;
  }

  void dispose() {
    this.logSubject?.close();
  }
}