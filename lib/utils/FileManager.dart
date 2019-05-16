import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum FileNames {
  log
}

const Map<FileNames, String> FileNameString = {
  FileNames.log: 'log',
};

class FileManager {
  final FileNames fileName;
  FileManager(this.fileName);

  Future<bool> write(String content) async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDir.path;

    File file = File('$documentsPath/${FileNameString[fileName]}');
    if (!file.existsSync()) {
      file.createSync();
    }

    File newFile = await file.writeAsString(content);
    return newFile.existsSync();
  }

  Future<String> read() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDir.path;

    File file = File('$documentsPath/${FileNameString[fileName]}');
    if (!file.existsSync()) {
      return null;
    } else {
      return file.readAsStringSync();
    }
  }
}