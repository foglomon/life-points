import 'dart:io';
import 'dart:async';
import 'dart:convert'; // Add this import for JSON support
import 'package:path_provider/path_provider.dart';

class UserInfo {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json'); // Use .json extension
  }

  Future<Map<String, dynamic>> readData() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      // Return default data if no data is found or error occurs
      return {'username': 'User', 'points': 0};
    }
  }

  Future<File> writeData(Map<String, dynamic> data) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(data));
  }
}

// Utility function to fetch data
Future<dynamic> fetchValue(String key) async {
  final userInfo = UserInfo();
  final data = await userInfo.readData();
  return data[key];
}