import 'package:counter_app_provider_consumer/counter_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────
      appBar: AppBar(
        title: const Text(
          'Counter App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),

      // ── Background ──────────────────────────────────────────
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFEDE7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // ── Header Image ──────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/img1.jpg',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Counter Card ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Count',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<CounterProvider>(
                        builder: (context, counter, child) {
                          return Text(
                            '${counter.count}',
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              height: 1,
                            ),
                          );
                        },
                      ), // Consumer
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Action Buttons ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decrement
                    _ActionButton(
                      label: 'Decrement',
                      icon: Icons.remove_circle_outline,
                      color: const Color(0xFFEF5350),
                      onPressed: () =>
                          context.read<CounterProvider>().decrement(),
                    ),
                    // Reset
                    _ActionButton(
                      label: 'Reset',
                      icon: Icons.refresh,
                      color: const Color(0xFF78909C),
                      onPressed: () =>
                          context.read<CounterProvider>().reset(),
                    ),
                    // Increment
                    _ActionButton(
                      label: 'Increment',
                      icon: Icons.add_circle_outline,
                      color: const Color(0xFF42A5F5),
                      onPressed: () =>
                          context.read<CounterProvider>().increment(),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Network Image ─────────────────────────────
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Featured Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.pexels.com/photos/36209439/pexels-photo-36209439.jpeg',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF42A5F5),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable Action Button Widget ──────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 6,
            shadowColor: color.withOpacity(0.5),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}