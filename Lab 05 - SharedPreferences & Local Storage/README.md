# Oct 7 Class Code • Flutter SharedPreferences Tasks

This repository contains all university class tasks and practice projects for **SharedPreferences in Flutter**.

---

## 📁 Project Structure

```
Lab 05 - SharedPreferences & Local Storage/
│
├── shared_preferences_tasks_hub/   <-- Full Flutter Project (Interactive Multi-Task Hub)
│   ├── lib/
│   │   ├── main.dart                       <-- Navigation Hub with all 4 tasks
│   │   └── tasks/
│   │       ├── task1_theme_mode.dart       <-- Task 1: Dark / Light Mode
│   │       ├── task2_login_session.dart    <-- Task 2: Login Session & Remember Me
│   │       ├── task3_user_profile_counter.dart <-- Task 3: Multi-Type Data & Counter
│   │       └── task4_todo_persistence.dart <-- Task 4: Persistent To-Do List (JSON)
│   └── pubspec.yaml
│
├── Task_1_Theme_Preference/                <-- Standalone Single-File Task 1
│   └── lib/main.dart
│
├── Task_2_User_Login_Session/              <-- Standalone Single-File Task 2
│   └── lib/main.dart
│
├── Task_3_Multi_Data_Profile_Counter/      <-- Standalone Single-File Task 3
│   └── lib/main.dart
│
└── Task_4_Todo_Notes_JSON_List/            <-- Standalone Single-File Task 4
    └── lib/main.dart
```

---

## 📝 Tasks Breakdown

### 🎯 Task 1: Theme Preference (Dark & Light Mode)
- **Concept**: Saving `bool` preference using `SharedPreferences.setBool('is_dark_mode', value)`.
- **Features**: Toggle switch in AppBar and Settings tile, persistent theme across restarts.

### 🎯 Task 2: User Login & Session Persistence
- **Concept**: Session handling with `is_logged_in`, `saved_username`, and `remember_me`.
- **Features**: Direct login state check on startup, Remember Me checkbox, and clean logout.

### 🎯 Task 3: Multi-Data Profile & Counter Persistence
- **Concept**: Storing all primitive data types (`int`, `double`, `String`, `bool`).
- **Features**: Counter that persists increments, User Profile form with volume slider and notifications toggle, and `prefs.clear()`.

### 🎯 Task 4: Persistent To-Do Notes List (JSON / List Serialization)
- **Concept**: Storing collections/objects using `jsonEncode()` and `jsonDecode()`.
- **Features**: Add, complete, and delete todo items with instant SharedPreferences sync.

---

## 🚀 How to Run

Navigate to the project and run:
```bash
cd shared_preferences_tasks_hub
flutter pub get
flutter run
```
