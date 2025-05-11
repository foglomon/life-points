import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class UserInfo {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return ''; // Return empty string if no data is found
    }
  }

  Future<File> writeData(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }
}

// Utility function to fetch username
Future<String> fetchUsername() async {
  final userInfo = UserInfo();
  String name = await userInfo.readData();
  return name.isNotEmpty ? name : "User"; // Default to "User" if no name is found
}