import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _themeModeKey = 'theme_mode';
  static const String _defaultCategoryKey = 'default_category';
  static const String _defaultPriorityKey = 'default_priority';
  static const String _defaultSortKey = 'default_sort';
  static const String _showCompletedTasksKey = 'show_completed_tasks';
  static const String _taskRemindersKey = 'task_reminders';

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

  // Default Category ('Study', 'Work', 'Personal', 'Other')
  Future<void> saveDefaultCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCategoryKey, category);
  }

  Future<String> loadDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCategoryKey) ?? 'Personal';
  }

  // Default Priority ('low', 'medium', 'high')
  Future<void> saveDefaultPriority(String priority) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultPriorityKey, priority);
  }

  Future<String> loadDefaultPriority() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultPriorityKey) ?? 'low';
  }

  // Default Sort Order ('date', 'priority', 'alphabetical')
  Future<void> saveDefaultSort(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSortKey, sort);
  }

  Future<String> loadDefaultSort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultSortKey) ?? 'date';
  }

  // Show Completed Tasks
  Future<void> saveShowCompletedTasks(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCompletedTasksKey, show);
  }

  Future<bool> loadShowCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showCompletedTasksKey) ?? true;
  }

  // Task Reminders
  Future<void> saveTaskReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_taskRemindersKey, enabled);
  }

  Future<bool> loadTaskReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_taskRemindersKey) ?? false;
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
