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

class TaskInfo {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.json');
  }

  Future<List<Map<String, dynamic>>> readTasks() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      // Return empty list if no tasks are found or error occurs
      return [];
    }
  }

  Future<File> writeTasks(List<Map<String, dynamic>> tasks) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(tasks));
  }

  Future<File> addTask(Map<String, dynamic> task) async {
    List<Map<String, dynamic>> tasks = await readTasks();
    tasks.add(task);
    return writeTasks(tasks);
  }
}

// Utility function to fetch data
Future<dynamic> fetchValue(String key) async {
  final userInfo = UserInfo();
  final data = await userInfo.readData();
  return data[key];
}
