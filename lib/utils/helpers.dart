import 'package:flutter/material.dart';
import 'constants.dart';

// Format a DateTime to a readable date string like "15 Aug 2023"
String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

// Format a DateTime to a readable time string like "7:30 PM"
String formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

// Format date and time together like "15 Aug 2023, 7:30 PM"
String formatDateTime(DateTime date) {
  return '${formatDate(date)}, ${formatTime(date)}';
}

// Check if a date is today
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

// Check if a date falls within this week (next 7 days from today)
bool isThisWeek(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfWeek = today.add(const Duration(days: 7));
  final dateOnly = DateTime(date.year, date.month, date.day);
  return dateOnly.isAfter(today.subtract(const Duration(days: 1))) &&
      dateOnly.isBefore(endOfWeek);
}

// Get the color for a given priority string
Color getPriorityColor(String priority) {
  return priorityColors[priority] ?? Colors.green;
}

// Get the icon for a given category string
IconData getCategoryIcon(String category) {
  return categoryIcons[category] ?? Icons.more_horiz;
}
