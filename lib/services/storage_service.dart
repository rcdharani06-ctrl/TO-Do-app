import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _themeModeKey = 'theme_mode';

  // Save the list of tasks to shared_preferences
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString(_tasksKey, encodedData);
  }

  // Load the list of tasks from shared_preferences
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_tasksKey);

    if (tasksString != null) {
      final List<dynamic> decodedData = jsonDecode(tasksString);
      return decodedData.map((json) => Task.fromJson(json)).toList();
    }
    return [];
  }

  // Save the user's theme preference ('light', 'dark', or 'system')
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  // Load the user's theme preference
  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }
}
