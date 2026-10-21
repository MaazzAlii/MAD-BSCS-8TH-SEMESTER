import 'package:flutter/material.dart';

// ============================================================================
// 🟢 [60% UNIVERSAL SKELETON] - IDENTICAL ON ALMOST EVERY FLUTTER EXAM QUESTION
// Write this exact main() and class MyApp skeleton first!
// ============================================================================
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CounterScreen(),
  ));
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  // ==========================================================================
  // 🔴 [40% QUESTION-SPECIFIC LOGIC] - ONLY MEMORIZE THIS FOR STATEFULWIDGET
  // 1. Declare state variable
  // 2. Modify state variable inside setState(() { ... })
  // ==========================================================================
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++; // Rebuilds the UI with new value
    });
  }

  void _decrement() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  // ==========================================================================
  // 🟢 [60% UNIVERSAL SKELETON] - SCAFFOLD & APPBAR (SAME IN ALL UI QUESTIONS)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StatefulWidget Counter (setState)'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔴 [40% QUESTION DISPLAY] - Display the variable
            const Text(
              'Current Count:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 🔴 [40% QUESTION ACTION BUTTONS]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decrement,
                  child: const Text('Decrement'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
