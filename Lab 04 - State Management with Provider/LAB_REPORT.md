# Mobile Application Development (MAD) • Lab Report 04
## State Management using Provider & Consumer in Flutter

---

### 📋 Student Information
- **Student Name:** Maaz Ali
- **Roll Number:** 3143
- **Degree Program:** Bachelor of Science in Computer Science (BSCS)
- **Semester:** 8th Semester
- **Course:** Mobile Application Development (MAD)
- **Lab Date:** October 1, 2026

---

## 1. 🎯 Lab Objectives
1. Understand the limitations of ephemeral state (`setState`) in large-scale mobile applications.
2. Master application-wide state management using the `provider` package (`ChangeNotifierProvider`, `Consumer`, `Provider.of`).
3. Decouple business logic from UI presentation layers.
4. Implement reactive UI updates where only subscribed child widgets rebuild upon state notifications.

---

## 2. 🧠 Theoretical Background & Architecture

### 2.1 Provider Architecture Pattern
In Flutter, the `provider` library is the official recommended approach for state management:
- **`ChangeNotifier`**: A class that provides change notification to its listeners via `notifyListeners()`.
- **`ChangeNotifierProvider`**: The widget that provides an instance of a `ChangeNotifier` to its descendants.
- **`Consumer<T>`**: Obtains `Provider<T>` from its ancestor and passes value to builder widget whenever `notifyListeners()` fires.

```mermaid
graph TD
    subgraph State Layer
        CP["CounterProvider (ChangeNotifier)"]
        CP -->|notifyListeners()| Bus["Notification Stream"]
    end

    subgraph Widget Tree
        Root["MaterialApp (wrapped in ChangeNotifierProvider)"]
        Root --> Screen["CounterScreen"]
        Screen --> StaticUI["AppBar / Static Layout"]
        Screen --> Cons["Consumer<CounterProvider>"]
        Cons --> ReactiveWidget["Text (Display Counter)"]
    end

    Bus -.->|Trigger Rebuild| Cons
```

---

## 3. 📂 Project Structure

```
Lab 04 - State Management with Provider/
├── counter_app_provider_consumer/
│   ├── lib/
│   │   ├── main.dart             <-- App Entry Point wrapped with ChangeNotifierProvider
│   │   ├── counter_provider.dart <-- Business Logic & ChangeNotifier
│   │   └── counter_screen.dart   <-- UI Layer with Consumer & FAB Actions
│   └── pubspec.yaml
└── assets/
    └── img1.jpg
```

---

## 4. 💻 Source Code Breakdown

### 4.1 State Model (`counter_provider.dart`)
```dart
import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}
```

### 4.2 Entry Point with Provider (`main.dart`)
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: const MyApp(),
    ),
  );
}
```

### 4.3 UI Consumer (`counter_screen.dart`)
```dart
Consumer<CounterProvider>(
  builder: (context, counterProvider, child) {
    return Text(
      '${counterProvider.count}',
      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    );
  },
)
```

---

## 5. 🚀 Execution & Verification Guide

### Running `counter_app_provider_consumer`:
```bash
cd "MAD BSCS 8TH SEMESTER/Lab 04 - State Management with Provider/counter_app_provider_consumer"
flutter pub get
flutter run -d linux # Or -d chrome
```

---

## 6. 🏁 Lab Conclusion
By implementing the Provider pattern, we separated UI rendering from state mutation logic. This improved app maintainability, eliminated unnecessary widget rebuilds, and established scalable state architecture.
