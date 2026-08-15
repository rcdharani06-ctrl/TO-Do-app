import 'package:flutter/material.dart';

// Available categories for tasks
const List<String> taskCategories = [
  'Study',
  'Work',
  'Personal',
  'Other',
];

// Available priority levels
const List<String> taskPriorities = [
  'high',
  'medium',
  'low',
];

// Map priority levels to their display colors
const Map<String, Color> priorityColors = {
  'high': Colors.red,
  'medium': Colors.orange,
  'low': Colors.green,
};

// Map priority levels to display labels
const Map<String, String> priorityLabels = {
  'high': 'High',
  'medium': 'Medium',
  'low': 'Low',
};

// Map categories to their icons
const Map<String, IconData> categoryIcons = {
  'Study': Icons.school,
  'Work': Icons.work,
  'Personal': Icons.person,
  'Other': Icons.more_horiz,
};
