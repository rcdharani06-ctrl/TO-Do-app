class Task {
  String id;
  String title;
  String description;
  String category;
  String priority; // 'high', 'medium', 'low'
  DateTime? dueDate;
  DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.priority = 'low',
    this.dueDate,
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert a Task to a Map so it can be saved in JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create a Task from a Map when reading from JSON
  // Handles V1 data gracefully by providing defaults for new fields
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'Personal',
      priority: json['priority'] ?? 'low',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
