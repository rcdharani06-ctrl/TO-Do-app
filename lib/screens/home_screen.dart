import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_stats.dart';
import '../widgets/empty_state.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentThemeMode;
  final ValueChanged<String> onThemeModeChanged;

  const HomeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService.instance;
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'priority', 'alphabetical'
  bool _showCompletedTasks = true;
  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load tasks and preferences from local storage and re-schedule notifications
  Future<void> _loadTasks() async {
    final tasks = await _storageService.loadTasks();
    final defaultSort = await _storageService.loadDefaultSort();
    final showCompleted = await _storageService.loadShowCompletedTasks();
    setState(() {
      _tasks = tasks;
      _sortBy = defaultSort;
      _showCompletedTasks = showCompleted;
    });
    // Re-schedule notifications for all incomplete tasks with future due dates
    await _notificationService.rescheduleAll(_tasks);
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
    // Schedule notification for the new task
    _notificationService.scheduleTaskNotification(task);
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    _saveTasks();
    // Cancel notification for the deleted task
    _notificationService.cancelTaskNotification(task.id);
  }

  void _toggleTaskCompletion(Task task, bool? value) {
    setState(() {
      task.isCompleted = value ?? false;
    });
    _saveTasks();
    // Cancel or re-schedule notification based on completion state
    if (task.isCompleted) {
      _notificationService.cancelTaskNotification(task.id);
    } else {
      _notificationService.scheduleTaskNotification(task);
    }
  }

  void _clearCompletedTasks() {
    // Cancel notifications for completed tasks before removing them
    for (final task in _tasks.where((t) => t.isCompleted)) {
      _notificationService.cancelTaskNotification(task.id);
    }
    setState(() {
      _tasks.removeWhere((t) => t.isCompleted);
    });
    _saveTasks();
  }

  void _clearAllTasks() {
    // Cancel all scheduled notifications before wiping tasks
    for (final task in _tasks) {
      _notificationService.cancelTaskNotification(task.id);
    }
    setState(() {
      _tasks.clear();
    });
    _storageService.clearAllTasks();
  }

  // Filter tasks into "Today" tab
  List<Task> get _todayTasks {
    return _filterAndSort(
      _tasks.where((t) =>
          !t.isCompleted &&
          t.dueDate != null &&
          isToday(t.dueDate!)),
    );
  }

  // Filter tasks into "Upcoming" tab (not completed, not today)
  List<Task> get _upcomingTasks {
    return _filterAndSort(
      _tasks.where((t) =>
          !t.isCompleted &&
          (t.dueDate == null || !isToday(t.dueDate!))),
    );
  }

  // Filter tasks into "Completed" tab
  List<Task> get _completedTasks {
    if (!_showCompletedTasks) return [];
    return _filterAndSort(_tasks.where((t) => t.isCompleted));
  }

  // Apply search query and sort to a filtered iterable
  List<Task> _filterAndSort(Iterable<Task> tasks) {
    var result = tasks.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sort
    switch (_sortBy) {
      case 'priority':
        const order = {'high': 0, 'medium': 1, 'low': 2};
        result.sort((a, b) =>
            (order[a.priority] ?? 2).compareTo(order[b.priority] ?? 2));
        break;
      case 'alphabetical':
        result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'date':
      default:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
    }
    return result;
  }

  Future<void> _navigateToAddTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
    if (newTask != null) {
      _addTask(newTask);
    }
  }

  Future<void> _navigateToTaskDetail(Task task) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onDelete: () => _deleteTask(task),
          onToggle: () =>
              _toggleTaskCompletion(task, !task.isCompleted),
        ),
      ),
    );
    // Refresh after returning from the detail page
    if (result != null) {
      setState(() {});
      _saveTasks();
      // Re-schedule notification in case the task was edited
      if (!task.isCompleted) {
        _notificationService.cancelTaskNotification(task.id);
        _notificationService.scheduleTaskNotification(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  currentThemeMode: widget.currentThemeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                  onClearCompleted: _clearCompletedTasks,
                  onClearAll: _clearAllTasks,
                  onSettingsChanged: _loadTasks,
                ),
              ),
            ).then((_) => _loadTasks());
          },
        ),
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('My Tasks'),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          // Sort menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18,
                        color: _sortBy == 'date'
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Due Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(Icons.flag,
                        size: 18,
                        color: _sortBy == 'priority'
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Priority'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'alphabetical',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 18,
                        color: _sortBy == 'alphabetical'
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Alphabetical'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          TaskStats(
            totalTasks: totalTasks,
            completedTasks: completedTasks,
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(
                  _todayTasks,
                  emptyIcon: Icons.today,
                  emptyTitle: 'No tasks for today!',
                  emptySubtitle:
                      'Add a task and set its due date to today.',
                ),
                _buildTaskList(
                  _upcomingTasks,
                  emptyIcon: Icons.upcoming,
                  emptyTitle: 'No upcoming tasks',
                  emptySubtitle:
                      'Add a task and get things done.',
                ),
                _buildTaskList(
                  _completedTasks,
                  emptyIcon: Icons.check_circle_outline,
                  emptyTitle: 'No completed tasks yet',
                  emptySubtitle:
                      'Complete your tasks to see them here.',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(
    List<Task> tasks, {
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggleCompletion: (value) =>
              _toggleTaskCompletion(task, value),
          onDelete: () => _deleteTask(task),
          onTap: () => _navigateToTaskDetail(task),
        );
      },
    );
  }
}
