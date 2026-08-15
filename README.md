# TaskFlow - Flutter To-Do App

A clean, beginner-friendly Flutter To-Do application with advanced task management features.

## Description

This project is a well-structured To-Do application built with Flutter and Material 3. It uses `shared_preferences` for local data persistence — no backend, no Firebase, no APIs. Tasks are stored on the device and remain available after the app is closed and reopened.

## Features

- **Categories**: Assign tasks to Study, Work, Personal, or Other
- **Priority Levels**: High, Medium, or Low with color indicators
- **Due Date & Time**: Set optional due dates and times for each task
- **Tabs**: View tasks organized by Today, Upcoming, and Completed
- **Search**: Quickly find tasks by title
- **Sort**: Sort by Due Date, Priority, or Alphabetically
- **Swipe Actions**: Swipe right to complete, swipe left to delete
- **Task Details**: Tap any task to view full details
- **Progress Indicator**: See how many tasks you've completed with a progress bar
- **Beautiful Empty States**: Friendly messages when a tab has no tasks
- **Theme Support**: Choose Light, Dark, or System theme
- **Settings Page**: Theme selector, clear completed tasks, app info
- **Local Storage**: All data persists between app restarts

## Technologies Used

- **Framework:** Flutter / Dart
- **UI:** Material 3
- **Local Storage:** `shared_preferences`

## Project Structure

## 📂 Project Structure

```text
lib/
├── main.dart
│   └── Application entry point and theme configuration
│
├── models/
│   └── task.dart
│       └── Task data model and task properties
│
├── screens/
│   ├── home_screen.dart
│   │   └── Main dashboard with task tabs, search, and sorting
│   │
│   ├── task_detail_screen.dart
│   │   └── Displays complete task information
│   │
│   ├── add_edit_task_screen.dart
│   │   └── Add and edit task form
│   │
│   └── settings_screen.dart
│       └── Application settings and theme configuration
│
├── widgets/
│   ├── task_card.dart
│   │   └── Reusable task card UI
│   │
│   ├── task_stats.dart
│   │   └── Task statistics and progress indicator
│   │
│   ├── empty_state.dart
│   │   └── Empty-state UI for screens without tasks
│   │
│   └── custom_chip.dart
│       └── Reusable category and priority chip
│
├── services/
│   └── storage_service.dart
│       └── Local task storage using SharedPreferences
│
└── utils/
    ├── constants.dart
    │   └── Application-wide constants
    │
    └── helpers.dart
        └── Date formatting and utility functions

## Installation Instructions

1. Ensure you have [Flutter installed](https://docs.flutter.dev/get-started/install).
2. Clone this repository:
   ```bash
   git clone <repository-url>
   ```
```markdown
3. Navigate into the project directory:
   ```bash
   cd TO-Do-app
4. Install dependencies:
   ```bash
   flutter pub get
   ```

## How to Run the Project

1. Start your preferred emulator or connect a device.
2. Run the application:
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Home Screen
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/c8312c8d-3a0f-4263-8b5b-c2df6b07a23a" />
### Add Task
<img width="1080" height="2400" alt="Screenshot_20260815_103530" src="https://github.com/user-attachments/assets/4a970856-4b3f-432d-862b-75f16fe0c859" />



## Future Improvements

- Task reminders and notifications
- Subtasks / checklists
- Task reordering with drag and drop
- Data export/import
