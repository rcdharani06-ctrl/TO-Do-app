# Flutter To-Do App (V2)

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

```
lib/
├── main.dart                         # App entry point and theme management
├── models/
│   └── task.dart                     # Task data model
├── screens/
│   ├── home_screen.dart              # Main screen with tabs, search, sort
│   ├── task_detail_screen.dart       # Full task detail view
│   ├── add_edit_task_screen.dart     # Form for adding/editing tasks
│   └── settings_screen.dart          # App settings
├── widgets/
│   ├── task_card.dart                # Individual task card
│   ├── task_stats.dart               # Progress bar widget
│   ├── empty_state.dart              # Empty state illustrations
│   └── custom_chip.dart              # Reusable colored chip
├── services/
│   └── storage_service.dart          # Local storage management
└── utils/
    ├── constants.dart                # App-wide constants
    └── helpers.dart                  # Date and utility helpers
```

## Installation Instructions

1. Ensure you have [Flutter installed](https://docs.flutter.dev/get-started/install).
2. Clone this repository:
   ```bash
   git clone <repository-url>
   ```
3. Navigate into the project directory:
   ```bash
   cd todo_app
   ```
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

## Screenshots

> Add screenshots here.

## Future Improvements

- Task reminders and notifications
- Subtasks / checklists
- Task reordering with drag and drop
- Data export/import
