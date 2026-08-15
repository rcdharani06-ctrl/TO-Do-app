import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// A polished, modern Settings screen for TaskFlow.
class SettingsScreen extends StatefulWidget {
  final String currentThemeMode;
  final ValueChanged<String> onThemeModeChanged;
  final VoidCallback onClearCompleted;
  final VoidCallback onClearAll;
  final VoidCallback? onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    required this.onClearCompleted,
    required this.onClearAll,
    this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();

  String _defaultCategory = 'Personal';
  String _defaultPriority = 'low';
  String _defaultSort = 'date';
  bool _showCompletedTasks = true;
  bool _taskReminders = false;
  bool _isLoading = true;

  static const String _githubUrl =
      'https://github.com/rcdharani06-ctrl/TO-Do-app';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final category = await _storageService.loadDefaultCategory();
    final priority = await _storageService.loadDefaultPriority();
    final sort = await _storageService.loadDefaultSort();
    final showCompleted = await _storageService.loadShowCompletedTasks();
    final reminders = await _storageService.loadTaskReminders();

    if (mounted) {
      setState(() {
        _defaultCategory = category;
        _defaultPriority = priority;
        _defaultSort = sort;
        _showCompletedTasks = showCompleted;
        _taskReminders = reminders;
        _isLoading = false;
      });
    }
  }

  void _notifySettingsChanged() {
    if (widget.onSettingsChanged != null) {
      widget.onSettingsChanged!();
    }
  }

  // --- Actions ---

  Future<void> _updateCategory(String category) async {
    setState(() => _defaultCategory = category);
    await _storageService.saveDefaultCategory(category);
    _notifySettingsChanged();
  }

  Future<void> _updatePriority(String priority) async {
    setState(() => _defaultPriority = priority);
    await _storageService.saveDefaultPriority(priority);
    _notifySettingsChanged();
  }

  Future<void> _updateSort(String sort) async {
    setState(() => _defaultSort = sort);
    await _storageService.saveDefaultSort(sort);
    _notifySettingsChanged();
  }

  Future<void> _updateShowCompleted(bool value) async {
    setState(() => _showCompletedTasks = value);
    await _storageService.saveShowCompletedTasks(value);
    _notifySettingsChanged();
  }

  Future<void> _updateTaskReminders(bool value) async {
    setState(() => _taskReminders = value);
    await _storageService.saveTaskReminders(value);
  }

  Future<void> _launchGitHubRepo() async {
    final uri = Uri.parse(_githubUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showUrlFallbackDialog();
      }
    } catch (_) {
      _showUrlFallbackDialog();
    }
  }

  void _showUrlFallbackDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GitHub Repository'),
        content: SelectableText(_githubUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showThemeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Choose Theme',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              _buildRadioOption(
                label: 'System Default',
                subtitle: 'Follow system theme settings',
                value: 'system',
                groupValue: widget.currentThemeMode,
                onChanged: (val) {
                  widget.onThemeModeChanged(val!);
                  Navigator.pop(ctx);
                },
              ),
              _buildRadioOption(
                label: 'Light',
                subtitle: 'Bright & clear interface',
                value: 'light',
                groupValue: widget.currentThemeMode,
                onChanged: (val) {
                  widget.onThemeModeChanged(val!);
                  Navigator.pop(ctx);
                },
              ),
              _buildRadioOption(
                label: 'Dark',
                subtitle: 'Sleek & high-contrast dark theme',
                value: 'dark',
                groupValue: widget.currentThemeMode,
                onChanged: (val) {
                  widget.onThemeModeChanged(val!);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Default Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              ...taskCategories.map(
                (cat) => ListTile(
                  leading: Icon(getCategoryIcon(cat), color: Theme.of(context).colorScheme.primary),
                  title: Text(cat),
                  trailing: _defaultCategory == cat
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _updateCategory(cat);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriorityDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Default Priority',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              ...taskPriorities.map(
                (p) => ListTile(
                  leading: Icon(Icons.flag, color: getPriorityColor(p)),
                  title: Text(priorityLabels[p]!),
                  trailing: _defaultPriority == p
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _updatePriority(p);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    final sortOptions = [
      {'key': 'date', 'label': 'Due Date', 'icon': Icons.calendar_today},
      {'key': 'priority', 'label': 'Priority', 'icon': Icons.flag},
      {'key': 'alphabetical', 'label': 'Alphabetical', 'icon': Icons.sort_by_alpha},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Select Default Sort Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              ...sortOptions.map(
                (opt) => ListTile(
                  leading: Icon(opt['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
                  title: Text(opt['label'] as String),
                  trailing: _defaultSort == opt['key']
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _updateSort(opt['key'] as String);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCompletedConfirmation() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            const Text('Clear Completed Tasks'),
          ],
        ),
        content: const Text(
          'Are you sure?\nThis action cannot be undone and will permanently delete all completed tasks.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClearCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed tasks cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue),
            SizedBox(width: 8),
            Text('Export Tasks'),
          ],
        ),
        content: const Text(
          'Task export will be available in a future version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: colorScheme.error),
            const SizedBox(width: 8),
            const Text('Clear All Tasks'),
          ],
        ),
        content: const Text(
          'Are you sure?\nThis action cannot be undone and will permanently delete ALL tasks in the application.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All tasks cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.task_alt, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('About TaskFlow'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TaskFlow is a simple and modern Flutter task management application designed for intuitive daily productivity.',
            ),
            SizedBox(height: 12),
            Text(
              'Version 2.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOpenSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.code_rounded, color: Colors.purple),
            SizedBox(width: 8),
            Text('Open Source'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TaskFlow is built using Flutter and open-source packages including:',
            ),
            SizedBox(height: 8),
            Text('• shared_preferences\n• flutter_local_notifications\n• timezone\n• permission_handler\n• url_launcher'),
            SizedBox(height: 12),
            Text(
              'Released under the MIT License.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- Helper Helpers ---

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  String _getSortLabel(String key) {
    switch (key) {
      case 'priority':
        return 'Priority';
      case 'alphabetical':
        return 'Alphabetical';
      case 'date':
      default:
        return 'Due Date';
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Appearance Section
              _buildSectionHeader('Appearance', Icons.palette_outlined),
              _buildSectionCard([
                ListTile(
                  leading: Icon(Icons.brightness_6_outlined, color: colorScheme.primary),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeLabel(widget.currentThemeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showThemeDialog,
                ),
              ]),

              const SizedBox(height: 16),

              // 2. Task Preferences Section
              _buildSectionHeader('Task Preferences', Icons.tune_outlined),
              _buildSectionCard([
                ListTile(
                  leading: Icon(
                    getCategoryIcon(_defaultCategory),
                    color: colorScheme.primary,
                  ),
                  title: const Text('Default Category'),
                  subtitle: Text(_defaultCategory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showCategoryDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: getPriorityColor(_defaultPriority),
                  ),
                  title: const Text('Default Priority'),
                  subtitle: Text(priorityLabels[_defaultPriority] ?? 'Low'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPriorityDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.sort_outlined, color: colorScheme.primary),
                  title: const Text('Default Sort Order'),
                  subtitle: Text(_getSortLabel(_defaultSort)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSortDialog,
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: Icon(Icons.task_alt_outlined, color: colorScheme.primary),
                  title: const Text('Show Completed Tasks'),
                  subtitle: const Text('Display completed tasks in list'),
                  value: _showCompletedTasks,
                  onChanged: _updateShowCompleted,
                ),
              ]),

              const SizedBox(height: 16),

              // 3. Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications_outlined),
              _buildSectionCard([
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active_outlined, color: colorScheme.primary),
                  title: const Text('Task Reminders'),
                  subtitle: const Text('Reminder notifications will be available in a future version.'),
                  value: _taskReminders,
                  onChanged: _updateTaskReminders,
                ),
              ]),

              const SizedBox(height: 16),

              // 4. Data Management Section
              _buildSectionHeader('Data Management', Icons.storage_outlined),
              _buildSectionCard([
                ListTile(
                  leading: Icon(Icons.cleaning_services_outlined, color: Colors.orange.shade600),
                  title: const Text('Clear Completed Tasks'),
                  subtitle: const Text('Delete all tasks marked as done'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showClearCompletedConfirmation,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.download_outlined, color: colorScheme.primary),
                  title: const Text('Export Tasks'),
                  subtitle: const Text('Backup task data to local storage'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showExportDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
                  title: Text(
                    'Clear All Tasks',
                    style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Permanently remove all task records'),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.error),
                  onTap: _showClearAllConfirmation,
                ),
              ]),

              const SizedBox(height: 16),

              // 5. About Section
              _buildSectionHeader('About', Icons.info_outline),
              _buildSectionCard([
                // Branding Header Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.task_alt, color: colorScheme.onPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'TaskFlow',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'v2.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A simple and modern Flutter task management application.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: const Text('About TaskFlow'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutAppDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.code, color: colorScheme.primary),
                  title: const Text('Open Source'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showOpenSourceDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.open_in_new, color: colorScheme.primary),
                  title: const Text('GitHub Repository'),
                  subtitle: const Text(_githubUrl),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _launchGitHubRepo,
                ),
              ]),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () => onChanged(value),
    );
  }
}
