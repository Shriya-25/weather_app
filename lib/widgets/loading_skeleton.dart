import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.15),
      highlightColor: Colors.white.withValues(alpha: 0.35),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            _box(height: 22, width: 170),
            const SizedBox(height: 12),
            _box(height: 110, width: 110, radius: 55),
            const SizedBox(height: 12),
            _box(height: 76, width: 190),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _box(height: 90, width: 0)),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 90, width: 0)),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 90, width: 0)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => _box(height: 110, width: 74),
              ),
            ),
            const SizedBox(height: 24),
            _box(height: 320, width: double.infinity),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double height,
    required double width,
    double radius = 18,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
