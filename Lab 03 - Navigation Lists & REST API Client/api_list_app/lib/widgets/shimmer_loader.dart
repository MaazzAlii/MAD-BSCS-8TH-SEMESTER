import 'package:flutter/material.dart';

/// Simple skeleton loader — no external package needed
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({super.key});

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: 8,
        itemBuilder: (ctx, i) => _SkeletonCard(opacity: _anim.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;
  const _SkeletonCard({required this.opacity});

  Widget _box(double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(48, 48, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(double.infinity, 14),
                  _box(160, 12),
                  _box(double.infinity, 10),
                  _box(double.infinity, 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
