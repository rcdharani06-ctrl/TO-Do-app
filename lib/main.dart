import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service and timezone data
  await NotificationService.instance.init();
  // Request notification permission (Android 13+)
  await NotificationService.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageService _storageService = StorageService();
  ThemeMode _themeMode = ThemeMode.system;
  String _themeModeString = 'system';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load saved theme preference on startup
  Future<void> _loadTheme() async {
    final mode = await _storageService.loadThemeMode();
    setState(() {
      _themeModeString = mode;
      _themeMode = _stringToThemeMode(mode);
    });
  }

  // Update and save theme preference
  void _setThemeMode(String mode) {
    setState(() {
      _themeModeString = mode;
      _themeMode = _stringToThemeMode(mode);
    });
    _storageService.saveThemeMode(mode);
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        currentThemeMode: _themeModeString,
        onThemeModeChanged: _setThemeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
