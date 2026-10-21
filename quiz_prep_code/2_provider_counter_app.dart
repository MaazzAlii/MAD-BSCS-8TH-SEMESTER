import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================================
// 🎓 WHY IS PROVIDER DIFFERENT FROM STATEFULWIDGET?
// In StatefulWidget (Template A), state is tied inside the UI class.
// In Provider (Template B), we SEPARATE state into a standalone class (ChangeNotifier)
// and make the UI a lightweight StatelessWidget!
// ============================================================================

// ============================================================================
// 🔴 [PART 1: THE BUSINESS LOGIC CLASS] (extends ChangeNotifier)
// ============================================================================
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // ⭐ Key line: Tells all Consumer widgets to rebuild!
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// ============================================================================
// 🟢 [PART 2: ROOT INJECTION] (ChangeNotifierProvider wraps MaterialApp)
// Notice how main() is still the standard entry point, just wrapped with Provider!
// ============================================================================
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ProviderCounterScreen(),
      ),
    ),
  );
}

// ============================================================================
// 🟢 [PART 3: THE UI SCREEN] (StatelessWidget - 60% standard Scaffold structure!)
// ============================================================================
class ProviderCounterScreen extends StatelessWidget {
  const ProviderCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 Standard Scaffold & AppBar identical to every question!
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider State Management'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Count from Provider:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),

            // 🔴 [DYNAMIC UI CONSUMPTION] - Consumer listens to changes!
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Text(
                  '${counter.count}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔴 [DYNAMIC BUTTON TRIGGERS] - Teacher's exact syntax: context.read<T>()!
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CounterProvider>().decrement(),
                  child: const Text('Decrement'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.read<CounterProvider>().reset(),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.read<CounterProvider>().increment(),
                  child: const Text('Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
      // Action button using the teacher's clean 1-line syntax:
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterProvider>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
