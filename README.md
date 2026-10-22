# 📱 Mobile Application Development (MAD) — BSCS 8th Semester

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://pub.dev/packages/sqflite)
[![Provider](https://img.shields.io/badge/State%20Management-Provider-blue?style=for-the-badge)](https://pub.dev/packages/provider)

A comprehensive university repository for the **Mobile Application Development (BSCS 8th Semester)** course. This repository contains complete lab implementations, full-stack client-server integrations, state management patterns, local persistence solutions, an integrated Open-Ended Lab project, and interactive viva/exam revision materials.

---

## 📑 Table of Contents
- [Repository Overview](#-repository-overview)
- [Course Modules & Lab Breakdown](#-course-modules--lab-breakdown)
  - [Lab 01: Flutter Fundamentals & Profile UI](#lab-01-flutter-fundamentals--profile-ui)
  - [Lab 02: Gestures & Form Validation](#lab-02-gestures--form-validation)
  - [Lab 03: Navigation, Lists & REST API (Client + Server)](#lab-03-navigation-lists--rest-api-client--server)
  - [Lab 04: State Management with Provider](#lab-04-state-management-with-provider)
  - [Lab 05: SharedPreferences & Local Storage](#lab-05-sharedpreferences--local-storage)
  - [Module 06: Flutter SQLite Local Database CRUD](#module-06-flutter-sqlite-local-database-crud)
  - [Open-Ended Lab (OEL): Content Creator Studio](#open-ended-lab-oel-content-creator-studio)
- [Exam & Viva Revision Guides](#-exam--viva-revision-guides)
- [Directory Structure](#-directory-structure)
- [Getting Started & Installation](#-getting-started--installation)
- [Author & Academic Credits](#-author--academic-credits)

---

## 🚀 Repository Overview

This repository documents the entire practical journey of developing cross-platform mobile applications using Flutter and Dart, organized into progressive weekly milestones:

1. **Foundations**: Flutter widget tree architecture, declarative UI paradigms, and responsive layouts.
2. **User Interaction**: Gesture recognition, form handling, input validation, and user feedback.
3. **Networking**: Asynchronous programming (`async`/`await`), HTTP networking (`http` package), JSON parsing, and mock REST API backend.
4. **State Management**: Scalable reactive state management using the Provider architecture (`ChangeNotifier`, `Consumer`).
5. **Persistence**:
   - Lightweight key-value storage with `shared_preferences`.
   - Structured relational database operations using `sqflite` (SQLite CRUD).
6. **Capstone / Open-Ended Lab**: An integrated real-world app combining local DB, state management, shared preferences, and external REST APIs into a cohesive dashboard.

---

## 📂 Course Modules & Lab Breakdown

### [Lab 01: Flutter Fundamentals & Profile UI](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2001%20-%20Flutter%20Fundamentals%20%26%20Profile%20UI)
- **Concepts**: Flutter project structure, `main()` entry point, `StatelessWidget` vs `StatefulWidget`, `Scaffold`, `AppBar`, `Column`, `Row`, `Container`, `CircleAvatar`, and asset bundling.
- **Projects**:
  - `my_first_app`: Introductory Flutter starter app.
  - `profile_screen`: Clean portfolio/profile UI demonstrating structured layouts and asset rendering.
- **Documentation**: [Lab 01 Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2001%20-%20Flutter%20Fundamentals%20%26%20Profile%20UI/LAB_REPORT.md)

### [Lab 02: Gestures & Form Validation](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2002%20-%20Gestures%20%26%20Form%20Validation)
- **Concepts**: User input events, `GestureDetector` (taps, double taps, long presses), `InkWell` ripple animations, `Form` widget, `GlobalKey<FormState>`, and `TextFormField` validation logic.
- **Projects**:
  - `gesture_detector_example`: Interactive gesture listeners and event handling.
  - `form_example`: Comprehensive user registration and login form with live error validation.
- **Documentation**: [Lab 02 Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2002%20-%20Gestures%20%26%20Form%20Validation/LAB_REPORT.md)

### [Lab 03: Navigation, Lists & REST API (Client + Server)](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2003%20-%20Navigation%20Lists%20%26%20REST%20API%20Client)
- **Concepts**: Multi-screen navigation with `Navigator.push` and `Navigator.pop`, lazy list rendering with `ListView.builder`, grid presentations with `GridView.builder`, REST API consumption via `http.get`, JSON decoding (`jsonDecode`), and asynchronous UI handling with `FutureBuilder`.
- **Projects**:
  - `nav_list_view_and_grid_view`: Interactive dual-view navigation and layout demos.
  - `api_list_app`: Live REST API consumer fetching remote post collections.
  - [`Lab 03 - REST API Backend Server`](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2003%20-%20REST%20API%20Backend%20Server): Dedicated local Node.js / `json-server` mock backend.
- **Documentation**: [Lab 03 Client Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2003%20-%20Navigation%20Lists%20%26%20REST%20API%20Client/LAB_REPORT.md) & [Backend Server Guide](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2003%20-%20REST%20API%20Backend%20Server/LAB_REPORT.md)

### [Lab 04: State Management with Provider](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2004%20-%20State%20Management%20with%20Provider)
- **Concepts**: Avoiding prop-drilling and unnecessary widget rebuilds using Provider. Utilizing `ChangeNotifier`, `ChangeNotifierProvider`, and fine-grained `Consumer<T>` widgets for optimal performance.
- **Projects**:
  - `counter_app_provider_consumer`: Decoupled counter architecture showcasing clean UI/business logic separation.
- **Documentation**: [Lab 04 Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2004%20-%20State%20Management%20with%20Provider/LAB_REPORT.md)

### [Lab 05: SharedPreferences & Local Storage](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2005%20-%20SharedPreferences%20%26%20Local%20Storage)
- **Concepts**: Asynchronous key-value persistence using `SharedPreferences`. Storing booleans, strings, ints, string lists, and serialized JSON payloads.
- **Projects**:
  - `Task_1_Theme_Preference`: Persistent Dark/Light theme toggler across application restarts.
  - `Task_2_User_Login_Session`: User auth state simulation and session clearing.
  - `Task_3_Multi_Data_Profile_Counter`: Multi-field user profile caching and counter tracking.
  - `Task_4_Todo_Notes_JSON_List`: Persistent notes and to-do list with JSON encoding/decoding.
  - `shared_preferences_tasks_hub`: Centralized hub launching all Lab 05 sub-applications.
- **Documentation**: [Lab 05 Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/Lab%2005%20-%20SharedPreferences%20%26%20Local%20Storage/LAB_REPORT.md)

### [Module 06: Flutter SQLite Local Database CRUD](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/flutter_sqlite_crud)
- **Concepts**: Relational database storage on device via `sqflite` (with `sqflite_common_ffi` support for desktop/Linux/Windows). Database singleton pattern, table schema migrations, parameterized queries, and full CRUD operations (Create, Read, Update, Delete).
- **Documentation**: [SQLite CRUD Report](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/flutter_sqlite_crud/LAB_REPORT.md)

### [Open-Ended Lab (OEL): Content Creator Studio](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/open_ended_lab)
- **Scenario**: **Content Creator Studio & Analytics Tracker**
- **Integrated Pillars**:
  1. **SQLite CRUD**: Persists video/post titles, platforms (YouTube, Instagram, TikTok), and views count.
  2. **Provider State Management**: Dynamic recalculation of total videos and total views with instant UI reactivity.
  3. **SharedPreferences**: Remembers the creator's profile handle across sessions.
  4. **REST API Trends Screen**: Live ideas generator fetching suggestions from remote endpoint with loading states.
  5. **Cross-Platform Compatibility**: Full execution support across Linux Desktop, Web, and Mobile.
  6. **Backup All-in-One File**: Includes [`all_in_one_runnable.dart`](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/open_ended_lab/lib/all_in_one_runnable.dart) for quick examiner demonstrations.

---

## 📚 Exam & Viva Revision Guides

This repository includes custom study and viva preparation materials:

| Document | Format | Description |
|---|---|---|
| **[Open-Ended Lab Viva Guide](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/open_ended_lab_viva_guide.html)** | Interactive HTML | Roman Urdu & English viva revision guide tailored specifically for the Content Creator Studio OEL. Covers architecture, DB helper methods, Provider flows, and common examiner questions. |
| **[MAD Quiz Topper Paper Guide](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/MAD_QUIZ_TOPPER_PAPER_GUIDE.md)** | Markdown | High-yield conceptual exam summary covering lifecycle methods, widget composition, state management theories, and database patterns. |
| **[Interactive Quiz Study Guide](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/quiz_study_guide.html)** | Interactive HTML | Visual revision cheat sheet with quick-reference code cards and architecture diagrams. |
| **[Quiz Prep Code Samples](file:///home/maazzalii/Desktop/100%20days%20of%20code/98-%20mobile%20application%20universty/MAD%20BSCS%208TH%20SEMESTER/quiz_prep_code)** | Dart Scripts | 6 standalone runnable scripts demonstrating stateful counters, Provider, SharedPreferences, SQLite helper, lists & grids, and form validation. |

---

## 🌲 Directory Structure

```text
MAD-BSCS-8TH-SEMESTER/
├── Lab 01 - Flutter Fundamentals & Profile UI/
│   ├── my_first_app/
│   ├── profile_screen/
│   └── LAB_REPORT.md
├── Lab 02 - Gestures & Form Validation/
│   ├── gesture_detector_example/
│   ├── form_example/
│   └── LAB_REPORT.md
├── Lab 03 - Navigation Lists & REST API Client/
│   ├── nav_list_view_and_grid_view/
│   ├── api_list_app/
│   └── LAB_REPORT.md
├── Lab 03 - REST API Backend Server/
│   ├── db.json
│   ├── package.json
│   └── README.md
├── Lab 04 - State Management with Provider/
│   ├── counter_app_provider_consumer/
│   └── LAB_REPORT.md
├── Lab 05 - SharedPreferences & Local Storage/
│   ├── shared_preferences_tasks_hub/
│   ├── Task_1_Theme_Preference/
│   ├── Task_2_User_Login_Session/
│   ├── Task_3_Multi_Data_Profile_Counter/
│   ├── Task_4_Todo_Notes_JSON_List/
│   └── README.md
├── flutter_sqlite_crud/
│   ├── lib/
│   ├── pubspec.yaml
│   └── LAB_REPORT.md
├── open_ended_lab/
│   ├── lib/
│   │   ├── database/db_helper.dart
│   │   ├── models/content_item.dart
│   │   ├── providers/content_provider.dart
│   │   ├── screens/content_dashboard_screen.dart
│   │   ├── screens/api_trends_screen.dart
│   │   ├── all_in_one_runnable.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
├── quiz_prep_code/
│   ├── 1_stateful_widget_counter.dart
│   ├── 2_provider_counter_app.dart
│   ├── 3_shared_preferences_session.dart
│   ├── 4_sqflite_crud_helper.dart
│   ├── 5_list_and_grid_navigation.dart
│   └── 6_form_validation_paper.dart
├── open_ended_lab_viva_guide.html
├── quiz_study_guide.html
├── MAD_QUIZ_TOPPER_PAPER_GUIDE.md
└── README.md
```

---

## 🛠️ Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`v3.0.0` or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code / Antigravity with Flutter extensions
- (Optional for Lab 03 backend) [Node.js & npm](https://nodejs.org)

### Running any Lab Project
1. Clone the repository:
   ```bash
   git clone https://github.com/MaazzAlii/MAD-BSCS-8TH-SEMESTER.git
   cd "MAD-BSCS-8TH-SEMESTER"
   ```

2. Navigate to the desired lab folder (e.g., Open-Ended Lab):
   ```bash
   cd open_ended_lab
   ```

3. Fetch dependencies:
   ```bash
   flutter pub get
   ```

4. Run the application:
   ```bash
   # Run standard multi-file entry point
   flutter run

   # Or run direct standalone runnable file
   flutter run -t lib/all_in_one_runnable.dart
   ```

---

## 👨‍💻 Author & Academic Credits
- **Course**: Mobile Application Development (MAD)
- **Program**: BS Computer Science (BSCS 8th Semester)
- **Repository Maintainer**: [Maaz Ali](https://github.com/MaazzAlii)
